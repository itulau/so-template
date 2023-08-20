## Quick Start

Instalar las commons

```
make install-commons
```

Compilar los modulos

```
make all
```

Ejecutar el modulo cpu

```
make run modulo=cpu
```

## Parametros

Todos los comandos para ejecutar un modulo aceptan el argumento **parametros**

```
make run modulo=cpu parametros="arg1 arg2 config/cpu.config etc"
```

## Valgrind

Instalar **valgrind** 
```
sudo apt-get install valgrind
```

Ejecutar un modulo usando valgrind 

```
make valgrind modulo=cpu
```

## Debug

Instalar la extension de [Native Debug](https://marketplace.visualstudio.com/items?itemName=webfreak.debug) para VSCode.

Instalar **gdbserver** 
```
sudo apt-get install gdbserver
```

Ejecutar un modulo en modo debug 

```
make debug modulo=cpu
```

En **VSCode** agregar breakpoints en el codigo C del modulo ejecutado **(cpu/cpu.c)** y presionar F5.