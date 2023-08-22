#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#ifndef CLIENT_H_
#define CLIENT_H_
#include<stdlib.h>
#include<commons/log.h>
#include<commons/string.h>
#include<commons/config.h>
#include<readline/readline.h>

#include <stdio.h>
#include "../../shared/safe-alloc.h"
#include "utils.h"


t_log* iniciar_logger(void);
t_config* iniciar_config(void);
char* leer_consola(t_log*);
void paquete(int, char*);
void terminar_programa(int, t_log*, t_config*, char* lineas);

#endif /* CLIENT_H_ */
