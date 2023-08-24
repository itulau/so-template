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
CYAN=\033[0;36m
RED=\033[0;31m
NC=\033[0m

# PWD
PWD = $(shell pwd)
# Carpeta donde se guardaran los modulos compilados
BUILD_DIR = bin
# Carpeta donde se encuentra el modulo shared (archivos compartidos)
SHARED_DIR = shared
# Link al repo de las commons
COMMONS_REPO = https://github.com/sisoputnfrba/so-commons-library.git
# Parametros para la compilacion
# -I path donde se encuentran los include de shared
# -L path donde se encuentra la bilbioteca shared compilada
# -rpath deja marcado en el ejecutable la ubicacion de la biblioteca shared
BUILD_PARAMS = -I$(PWD) -L$(PWD)/bin -Wl,-rpath=$(PWD)/bin -lcommons -lshared -lreadline
# Parametros para valgrind
VALGRIND_PARAMS = -s --leak-check=full --track-origins=yes

# ----------------------------------------
# -----------------TARGETS----------------
# ----------------------------------------

# Si ejecutas make sin ningun target que se muestre un listado de targets
.DEFAULT_GOAL := help

# Para que makefile no entre en un loop infinito cuando se intenta buildear un modulo
$(MAKEFILE_LIST): ;

#- Modulos -#

# Buildear cualquier modulo
%:
	@make build modulo=$@

#: Compilar todos los modulos
all: shared $(shell find . -maxdepth 1 -type d ! -name '.*' ! -name '$(BUILD_DIR)' -printf '%f\n')
	

#: Compilar la biblioteca shared
shared: SOURCES := $(shell find $(SHARED_DIR) -name "*.c")
shared:
	@mkdir -p $(BUILD_DIR)
	@echo "${CYAN}==================================${NC}"
	@echo "Compilando la bilbioteca ${CYAN}shared${NC}..."
	@echo "${CYAN}⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄${NC}"
	@echo ""
	gcc -g -shared -o $(BUILD_DIR)/libshared.so -fPIC $(SOURCES)
	@echo ""
	@echo "${CYAN}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"
	@echo "Compilacion de ${CYAN}shared${NC} finalizada"

# Checkeos que se deben hacer antes de ejecutar un modulo
prerun:
	@if [ "$(modulo)" = "" ]; then \
		echo "make run modulo=<modulo> [parametros=<parametros...>]"; \
		echo "         ${RED}^^^^^^^^^^^^^^^ Falta definir modulo${NC}\n\n"; \
		echo "Ejemplo: ${CYAN}make run modulo=client${NC}\n\n"; \
		exit 1; \
	fi

	@echo "${CYAN}==================================${NC}"
	@if [ "$(parametros)" = "" ]; then \
		echo "Ejecutando ${CYAN}$(modulo)${NC} sin parametros..."; \
	else \
		echo "Ejecutando ${CYAN}$(modulo)${NC} con parametros ${CYAN}$(parametros)${NC}"; \
	fi
	@echo "${CYAN}⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄${NC}"
	@echo ""

postrun: RESULT=0
postrun:
	@if [ "$(RESULT)" = "0" ] ; then \
		echo ""; \
		echo "${CYAN}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"; \
		echo "${CYAN}$(modulo)${NC} finalizo su ejecucion exitosamente!"; \
	else \
		echo ""; \
		echo "${RED}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"; \
		echo "${RED}$(modulo)${NC} finalizo su ejecucion con error $(RESULT)!"; \
	fi


#- Ejecutar un modulo -#

#: Ejecuta un modulo con parametros
#: Ej: make run modulo=client parametros='param1 param2'
#: 
run: shared $(modulo) prerun
	@./$(BUILD_DIR)/$(modulo) $(parametros); \
	make postrun RESULT="$$?";

#: Ejecuta un modulo con valgrind
#: Ej: make valgrind modulo=client parametros='param1 param2'
valgrind: shared $(modulo) prerun
	@valgrind $(VALGRIND_PARAMS) ./$(BUILD_DIR)/$(modulo) $(parametros); \
	make postrun RESULT="$$?";

#- Utiles -#

#: Descarga e instala las biblioteca commons de la catedra
install-commons:
	@COMMONS_TEMP_DIR=$$(mktemp -d); \
	git clone $(COMMONS_REPO) $$COMMONS_TEMP_DIR; \
	( cd $$COMMONS_TEMP_DIR && make install ); \
	rm -rf $$COMMONS_TEMP_DIR;

#: Desinstala biblioteca commons de la catedra
uninstall-commons:
	sudo rm -f /usr/lib/libcommons.so
	sudo rm -rf /usr/include/commons

#: Elimina los binarios compilados y los logs
clean:
	rm -rf $(BUILD_DIR)

# Target que ayuda a compilar un modulo, no deberia ejecutarse por si solo (utilizar make client, make server, etc para compilar los modulos)
build: SOURCES := $(shell find $(modulo) -name "*.c")
build:
	@if [ "$(modulo)" = "" ]; then \
		echo "Error:"; \
		echo "make build modulo=<modulo>"; \
		echo "           ${RED}^^^^^^^^^^^^^^^ Falta definir modulo${NC}\n\n"; \
		echo "Ejemplo: ${GREEN}make build modulo=client${NC}\n\n"; \
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

	@echo "${GREEN}==================================${NC}"
	@echo "Compilando ${GREEN}$(modulo)${NC}..."
	@echo "${GREEN}⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄${NC}"
	@echo ""
	@echo "gcc -g $(SOURCES) -o $(BUILD_DIR)/$(modulo) $(BUILD_PARAMS)"
	@gcc -g $(SOURCES) -o $(BUILD_DIR)/$(modulo) $(BUILD_PARAMS); \
	if [ "$$?" = "0" ] ; then \
		echo ""; \
		echo "${GREEN}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"; \
		echo "Modulo ${GREEN}$(modulo)${NC} compilado exitosamente! Correr ejecutando ${GREEN}make run modulo=$(modulo)${NC}"; \
	else \
		echo ""; \
		echo "${RED}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"; \
		echo "ERROR AL COMPILAR MODULO ${RED}$(modulo)${NC}!"; \
	fi

#: Mostrar listado de comandos disponibles
help: SHELL:=/bin/bash
help:
	@linea_horizontal=$$(eval printf '%.0s-' {1..$$(tput cols)}); \
    export linea_horizontal; \
	sed '1s;^;\n;' Makefile \
	| perl -pe 's/#[^:^-](.*)\n//g' \
	| grep -zoP "((\n#:.*)+\n[^:]+:|\n#-(.*)-#)" \
	| perl -pe 's/\0/\n/g' \
	| perl -0777 -pe 's/((#: (.*)\n)+)(.*):/ make $$4$$1\n/g' \
	| perl -0777 -pe 's/\n#: /\n|||/g' \
	| perl -0777 -pe 's/#: /|||/g' \
	| column --table \
			 --separator '|||' \
			 --output-width $$(tput cols) \
			 --table-columns C1,C2,C3,C4 \
			 --table-hide C2,C3 \
			 --table-wrap C4 \
			 --table-noheadings \
	| perl -0777 -pe 's/-#(\s*)\n#-/\n/g' \
	| perl -0777 -pe 's/#-([^-#]*)-#(\s*)\n/$$ENV{linea_horizontal}\n$$1\n$$ENV{linea_horizontal}\n/g' \


