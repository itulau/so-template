#include <stdio.h>
#include "../shared/estructuras.h"

int main(int argc, char *argv[])
{
    int pcb = crear_pcb();
    printf("Modulo kernel!\n");
    printf("pcb: %i\n", pcb);
    return 0;
}