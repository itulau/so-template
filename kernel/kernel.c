#include <stdio.h>
#include <commons/log.h>

t_log *logger;

int main(int argc, char *argv[])
{
    logger = log_create("./bin/kernel.log", "kernel", true, LOG_LEVEL_INFO);

    log_warning(logger, "Falta implementar el modulo kernel");
    log_trace(logger, "Se ejecuto el modulo kernel con %i parametros", argc - 1);

    for(int i = 1; i < argc; i++)
    {
        log_trace(logger, "%i° parametro: %s", i, argv[i]);
    }

    return 0;
}