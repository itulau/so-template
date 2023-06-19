# Flags para hacer que la ejecucion del makefile sea limpia
ifndef VERBOSE
MAKEFLAGS += --no-print-directory
MAKEFLAGS += --always-make
endif

# Definimos algunos colores para hacer mas bonitos los echos
GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m

# Carpeta donde se guardaran los modulos compilados
BUILD_DIR = build

# Si ejecutas make sin ningun target que se ejecute la ayuda
default: help

#- Compilacion de modulos -#

#: Compilar todos los modulos
all: cpu kernel

#: Compilar modulo kernel
kernel:
	@make build modulo=$@

#: Compilar modulo cpu
cpu:
	@make build modulo=$@

#- Extras -#

#: [modulo=<nombre modulo>] [parametros=<parametros...>] - Ejecuta un modulo previamente compilado con parametros
run:
	@if [ "$(modulo)" = "" ]; then \
		echo "make run modulo=<modulo> [parametros=<parametros...>]"; \
		echo "         ${RED}^^^^^^^^^^^^^^^ Falta definir modulo${NC}\n\n"; \
		echo "Ejemplo: ${GREEN}make run modulo=cpu${NC}\n\n"; \
		exit 1; \
	fi

	@if [ ! -e $(BUILD_DIR)/$(modulo) ]; then \
		echo "Error, modulo $(modulo) no fue compilado. Para compilarlo ejecute: make $(modulo)\n"; \
		exit 1; \
	fi

	@echo "Ejecutando ${GREEN}$(modulo)${NC}..."
	@echo "${GREEN}⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄${NC}"
	@echo ""
	@./$(BUILD_DIR)/$(modulo) $(parametros)
	@echo ""
	@echo "${GREEN}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"
	@echo "${GREEN}$(modulo)${NC} finalizo su ejecucion"

# Target que ayuda a compilar un modulo, no deberia ejecutarse por si solo (utilizar make cpu, make kernel, etc para compilar los modulos)
build:
	@if [ "$(modulo)" = "" ]; then \
		echo "make build modulo=<modulo>"; \
		echo "           ${RED}^^^^^^^^^^^^^^^ Falta definir modulo${NC}\n\n"; \
		echo "Ejemplo: ${GREEN}make build modulo=cpu${NC}\n\n"; \
		exit 1; \
	fi

	@if [ "$(modulo)" = "shared" ]; then \
		echo "El modulo shared no es necesario compilarlo, es incluido cuando se compila cualquier otro modulo\n"; \
		exit 1; \
	fi

	@if [ ! -e $(modulo) ]; then \
		echo "Error, el modulo $(modulo) no existe.\n"; \
		exit 1; \
	fi

	@mkdir -p $(BUILD_DIR)

	@echo "Compilando ${GREEN}$(modulo)${NC}..."
	@echo "${GREEN}⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄${NC}"
	@echo ""
	@echo "gcc -o $(BUILD_DIR)/$(modulo) $(wildcard ./$(modulo)/*.c) $(wildcard ./shared/*.c)"
	@if gcc -o $(BUILD_DIR)/$(modulo) $(wildcard ./$(modulo)/*.c) $(wildcard ./shared/*.c); then \
		echo ""; \
		echo "${GREEN}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"; \
		echo "Modulo ${GREEN}$(modulo)${NC} compilado exitosamente!"; \
	else \
		echo ""; \
		echo "${RED}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"; \
		echo "ERROR AL COMPILAR MODULO ${RED}$(modulo)${NC}!"; \
	fi

# Parsea este archivo de Makefile y lista los targets que tienen un "#:" como comentario
#: Mostrar listado de targets disponibles
help:
	@echo "\nTargets disponibles:"
	@echo "--------------------"
	@sed '1s;^;\n;' Makefile \
	| perl -pe 's/#[^:^-](.*)\n//g' \
	| grep -zoP "((\n#:.*)+\n[^:]+:|\n#- (.*) -#)" \
	| perl -pe 's/\0/\n/g' \
	| perl -0777 -pe 's/((#: (.*)\n)+)(.*):/make $$4$$1\n/g' \
	| perl -0777 -pe 's/\n#: /\n###/g' \
	| perl -0777 -pe 's/#: /###/g' \
	| perl -0777 -pe 's/#- (.*) -#/###\n$$1:###\n###/g' \
	| column -t -s '###'
	@echo "\n--------------------\n"