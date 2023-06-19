# ----------------------------------------
# ----------------VARIABLES---------------
# ----------------------------------------

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
BUILD_DIR=bin
# Carpeta donde se encuentra el modulo shared (archivos compartidos)
SHARED_DIR=shared

# ----------------------------------------
# -----------------TARGETS----------------
# ----------------------------------------

# Si ejecutas make sin ningun target que se muestre un listado de targets
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
		echo "make run modulo=${RED}$(modulo)${NC} $(parametros)"; \
		echo "                ${RED}^ El modulo $(modulo) no esta compilado.${NC}\n\n"; \
		echo "Para compilarlo ejecute:\n\t${GREEN}make $(modulo)${NC}\n\n"; \
		exit 1; \
	fi

	@echo "Ejecutando ${GREEN}$(modulo)${NC}..."
	@echo "${GREEN}⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄${NC}"
	@echo ""
	@./$(BUILD_DIR)/$(modulo) $(parametros)
	@echo ""
	@echo "${GREEN}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"
	@echo "${GREEN}$(modulo)${NC} finalizo su ejecucion"

#: Elimina todos los binarios compilados
clean:
	@rm -rf $(BUILD_DIR)

# Target que ayuda a compilar un modulo, no deberia ejecutarse por si solo (utilizar make cpu, make kernel, etc para compilar los modulos)
build:
	@if [ "$(modulo)" = "" ]; then \
		echo "Error:"; \
		echo "make build modulo=<modulo>"; \
		echo "           ${RED}^^^^^^^^^^^^^^^ Falta definir modulo${NC}\n\n"; \
		echo "Ejemplo: ${GREEN}make build modulo=cpu${NC}\n\n"; \
		exit 1; \
	fi

	@if [ "$(modulo)" = "$(SHARED_DIR)" ]; then \
		echo "El modulo ${RED}$(SHARED_DIR)${NC} no es necesario compilarlo, es incluido cuando se compila cualquier otro modulo\n"; \
		exit 1; \
	fi

	@if [ ! -e $(modulo) ]; then \
		echo "El modulo ${RED}$(modulo)${NC} no existe.\n"; \
		exit 1; \
	fi

	@mkdir -p $(BUILD_DIR)

	@echo "Compilando ${GREEN}$(modulo)${NC}..."
	@echo "${GREEN}⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄${NC}"
	@echo ""
	@echo "gcc -o $(BUILD_DIR)/$(modulo) $(wildcard ./$(modulo)/*.c) $(wildcard ./$(SHARED_DIR)/*.c)"
	@if gcc -o $(BUILD_DIR)/$(modulo) $(wildcard ./$(modulo)/*.c) $(wildcard ./$(SHARED_DIR)/*.c); then \
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