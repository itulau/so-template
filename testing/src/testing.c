#include <stdio.h>
#include <stdlib.h>
#include <commons/log.h>
#include <commons/config.h>
#include <readline/readline.h>

int main(int argc, char *argv[])
{
    t_list* valores = list_create();
    char* valor = malloc(16);
    snprintf(valor, 16, "hola como estas");
	list_add(valores, valor);

    printf("%s\n", valor);

    list_destroy(valores);
    printf("%s\n", valor);
}