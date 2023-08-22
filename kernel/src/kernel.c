#include <stdio.h>
#include <commons/log.h>
#include <shared/estructuras.h>

t_log *logger;

int main(int argc, char *argv[])
{
    logger = log_create("kernel/logs/kernel.log", "kernel", true, LOG_LEVEL_TRACE);

    log_warning(logger, "Falta implementar el modulo kernel");
    log_trace(logger, "Se ejecuto el modulo kernel con %i parametros", argc - 1);

    for(int i = 1; i < argc; i++)
    {
        log_trace(logger, "%i° parametro: %s", i, argv[i]);
    }

    // Poner breakpoint
    // como podras ver se puede entrar a la definicion de las funciones
    int num1 = 7;
    int num2 = 9;
    int suma = sumar(num1, num2);

    log_trace(logger, "%i + %i = %i", num1, num2, suma);

    return 0;
}