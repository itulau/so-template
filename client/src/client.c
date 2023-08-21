#include "client.h"

int main(void)
{
	/*---------------------------------------------------PARTE 2-------------------------------------------------------------*/

	int conexion;
	char* ip;
	char* puerto;
	char* valor;

	t_log* logger;
	t_config* config;

	/* ---------------- LOGGING ---------------- */

	logger = iniciar_logger();

	// Usando el logger creado previamente
	// Escribi: "Hola! Soy un log"
	log_info(logger, "Hola! Soy un Log");

	/* ---------------- ARCHIVOS DE CONFIGURACION ---------------- */

	config = iniciar_config();

	// Usando el config creado previamente, leemos los valores del config y los 
	// dejamos en las variables 'ip', 'puerto' y 'valor'
	ip = config_get_string_value(config, "IP");
	puerto = config_get_string_value(config, "PUERTO");
	valor = config_get_string_value(config, "CLAVE");

	// Loggeamos el valor de config
	log_info(logger, "ip: %s, puerto: %s, valor: %s", ip, puerto, valor);


	/* ---------------- LEER DE CONSOLA ---------------- */

	char* leido_consola = leer_consola(logger);

	/*---------------------------------------------------PARTE 3-------------------------------------------------------------*/

	// ADVERTENCIA: Antes de continuar, tenemos que asegurarnos que el servidor esté corriendo para poder conectarnos a él

	// Creamos una conexión hacia el servidor
	conexion = crear_conexion(ip, puerto);

	// Enviamos al servidor el valor de CLAVE como mensaje
	enviar_mensaje(valor, conexion);

	// Armamos y enviamos el paquete
	paquete(conexion, leido_consola);

	terminar_programa(conexion, logger, config, leido_consola);

	/*---------------------------------------------------PARTE 5-------------------------------------------------------------*/
	// Proximamente
}

t_log* iniciar_logger(void)
{
	t_log* nuevo_logger = log_create("tp0.log", "TP-O", true, LOG_LEVEL_INFO);

	if(nuevo_logger == NULL) {
		abort();
	}

	return nuevo_logger;
}

t_config* iniciar_config(void)
{
	t_config* nuevo_config = config_create("client/cliente.config");

	if (nuevo_config == NULL) {
		abort();
	}

	return nuevo_config;
}

char* leer_consola(t_log* logger)
{
	char* leido_consola = malloc(1);
	*leido_consola = '\0';
	char* leido_linea;

	while ((leido_linea = readline("> ")) != NULL) {
        if (leido_linea[0] == '\0') {
            free(leido_linea);
            break;
        }

		log_info(logger, "%s", leido_linea);
		leido_consola = realloc(leido_consola, strlen(leido_consola) + strlen(leido_linea) + 1);
		if (leido_consola == NULL) {
			abort();
		}
        strcat(leido_consola, leido_linea);
		free(leido_linea);
    }
	return leido_consola;
}

void paquete(int conexion, char* lineas)
{
	// Ahora toca lo divertido!
	char* leido;
	t_paquete* paquete;

	paquete = crear_paquete();
	agregar_a_paquete(paquete, lineas, strlen(lineas) + 1);
	enviar_paquete(paquete, conexion);
	eliminar_paquete(paquete);
}

void terminar_programa(int conexion, t_log* logger, t_config* config, char* lineas)
{
	close(conexion);
	log_destroy(logger);
	config_destroy(config);
	free(lineas);
}
