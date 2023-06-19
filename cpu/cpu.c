#include <stdio.h>
#include <commons/log.h>

t_log *logger;

int main(int argc, char *argv[])
{
    logger = log_create("./bin/cpu.log", "cpu", true, LOG_LEVEL_TRACE);

    log_warning(logger, "Falta implementar el modulo cpu");
    log_trace(logger, "Se ejecuto el modulo cpu con %i parametros", argc - 1);

    for(int i = 1; i < argc; i++)
    {
        log_trace(logger, "%i° parametro: %s", i, argv[i]);
    }

    return 0;
}