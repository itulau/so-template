#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

void* ejecutar_en_un_thread(void* args)
{
    for(int i = 0; i < 5; i++)
    {
        printf("Trabajando en el thread %i...\n", *(int*)args);
        sleep(*(int*)args);
    }
}

int main(int argc, char *argv[])
{
    pthread_t thread1;
    pthread_t thread2;

    int param1 = 1;
    int param2 = 2;

    printf("Voy a iniciar los threads...\n");
    pthread_create(&thread1, NULL, ejecutar_en_un_thread, &param1);
    pthread_create(&thread2, NULL, ejecutar_en_un_thread, &param2);
    printf("Se iniciaron los dos threads\n");

    printf("Espero a que finalicen los dos threads\n");
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);

    printf("Los threads finalizaron\n");

    return 0;
}