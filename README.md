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

## Ejecutar con parametros

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

Instalar la extension de [C/C++](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools) para VSCode.

Instalar **gdb** 
```
sudo apt-get install gdb
```

En **VSCode** agregar breakpoints en algun modulo y presionar F5, elegir el modulo a debuggear y agregar parametros si es necesario.

## Agregar mas modulos

>Reemplazar `<modulo>` con el nombre del modulo a agregar

1. Crear carpeta y archivo con el nombre del modulo `<modulo>/<modulo>.c`
2. Agregar el modulo a las opciones en `.vscode/launch.json`, dentro de 
`inputs > options`.
```json
...
"inputs": [
    {
        "id": "modulo",
        "type": "pickString",
        "description": "Seleccione modulo para debuggear",
        "options": [
            "cpu",
            "kernel",
            <modulo>
        ],
        "default": "cpu"
    },
    ...
```