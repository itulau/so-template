#include "utils.h"

t_log* logger;

void* serializar_paquete(t_paquete* paquete, int bytes)
{
	void * magic = malloc(bytes);
	if (magic == NULL) {
		log_error(logger, "no se pudo reservar espacio para el paquete");
		abort();
	}
	int desplazamiento = 0;

	memcpy(magic + desplazamiento, &(paquete->codigo_operacion), sizeof(int));
	desplazamiento+= sizeof(int);
	memcpy(magic + desplazamiento, &(paquete->buffer->size), sizeof(int));
	desplazamiento+= sizeof(int);
	memcpy(magic + desplazamiento, paquete->buffer->stream, paquete->buffer->size);
	desplazamiento+= paquete->buffer->size;

	return magic;
}

int crear_conexion(char *ip, char* puerto)
{
	struct addrinfo hints;
	struct addrinfo *server_info;

	memset(&hints, 0, sizeof(hints));
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_flags = AI_PASSIVE;

	getaddrinfo(ip, puerto, &hints, &server_info);

	// Ahora vamos a crear el socket.
	int socket_cliente = socket(server_info->ai_family, server_info->ai_socktype, server_info->ai_protocol);

	if (socket_cliente == -1) {
		log_error(logger, "no se pudo crear el socket");
		abort();
	}

	// Ahora que tenemos el socket, vamos a conectarlo
	if(connect(socket_cliente, server_info->ai_addr, server_info->ai_addrlen) == -1) {
		log_error(logger, "no se pudo conectar el socket");
		abort();
	}

	freeaddrinfo(server_info);

	return socket_cliente;
}

void enviar_mensaje(char* mensaje, int socket_cliente)
{
	t_paquete* paquete = malloc(sizeof(t_paquete));

	if (paquete == NULL) {
		log_error(logger, "no se pudo reservar espacio para el paquete");
		abort();
	}

	paquete->codigo_operacion = MENSAJE;
	paquete->buffer = malloc(sizeof(t_buffer));

	if (paquete->buffer == NULL) {
		log_error(logger, "no se pudo reservar espacio para el buffer del paquete");
		abort();
	}

	paquete->buffer->size = strlen(mensaje) + 1;
	paquete->buffer->stream = malloc(paquete->buffer->size);

	if (paquete->buffer->stream == NULL) {
		log_error(logger, "no se pudo reservar espacio para el stream del buffer del paquete");
		abort();
	}

	memcpy(paquete->buffer->stream, mensaje, paquete->buffer->size);

	int bytes = paquete->buffer->size + 2*sizeof(int);

	void* a_enviar = serializar_paquete(paquete, bytes);

	if (send(socket_cliente, a_enviar, bytes, 0) == -1) {
		log_error(logger, "Ocurrio un error al enviar el mensaje");
		abort();
	}

	free(a_enviar);
	eliminar_paquete(paquete);
}


void crear_buffer(t_paquete* paquete)
{
	paquete->buffer = malloc(sizeof(t_buffer));
	paquete->buffer->size = 0;
	paquete->buffer->stream = NULL;
}

t_paquete* crear_paquete(void)
{
	t_paquete* paquete = malloc(sizeof(t_paquete));

	if (paquete == NULL) {
		log_error(logger, "no se pudo reservar espacio para el paquete");
		abort();
	}
	
	paquete->codigo_operacion = PAQUETE;
	crear_buffer(paquete);
	return paquete;
}

void agregar_a_paquete(t_paquete* paquete, void* valor, int tamanio)
{
	paquete->buffer->stream = realloc(paquete->buffer->stream, paquete->buffer->size + tamanio + sizeof(int));

	if (paquete->buffer->stream == NULL) {
		log_error(logger, "no se pudo reservar espacio para agregar al paquete el valor");
		abort();
	}

	memcpy(paquete->buffer->stream + paquete->buffer->size, &tamanio, sizeof(int));
	memcpy(paquete->buffer->stream + paquete->buffer->size + sizeof(int), valor, tamanio);

	paquete->buffer->size += tamanio + sizeof(int);
}

void enviar_paquete(t_paquete* paquete, int socket_cliente)
{
	int bytes = paquete->buffer->size + 2*sizeof(int);
	void* a_enviar = serializar_paquete(paquete, bytes);

	if (send(socket_cliente, a_enviar, bytes, 0) == -1) {
		log_error(logger, "No se pudo enviar el paquete");
		abort();
	}

	free(a_enviar);
}

void eliminar_paquete(t_paquete* paquete)
{
	free(paquete->buffer->stream);
	free(paquete->buffer);
	free(paquete);
}

void liberar_conexion(int socket_cliente)
{
	close(socket_cliente);
}
