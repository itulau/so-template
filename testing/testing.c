#include <stdio.h>
#include <stdlib.h>
#include <commons/log.h>
#include <commons/config.h>
#include <readline/readline.h>

int main(int argc, char *argv[])
{
    t_config* config = config_create("tp0.config");
    if (config == NULL) {
        abort();
    }

    t_log* log = log_create("testing/tp0.log", "TP-0", true, LOG_LEVEL_INFO);
    if (log == NULL) {
        abort();
    }

    char * valor = config_get_string_value(config, "CLAVE");
    log_info(log, "%s!", valor);
    config_destroy(config);
    log_destroy(log);
}