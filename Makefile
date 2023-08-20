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

# Carpeta donde se guardaran los modulos compilados
BUILD_DIR = bin
# Carpeta donde se encuentra el modulo shared (archivos compartidos)
SHARED_DIR = shared
# Link al repo de las commons
COMMONS_REPO = https://github.com/sisoputnfrba/so-commons-library.git
# Bibliotecas que se linkearan al compilar los modulos
LIBS = -lcommons
# Parametros para valgrind
VALGRIND_PARAMS = -s --leak-check=full --track-origins=yes

# ----------------------------------------
# -----------------TARGETS----------------
# ----------------------------------------

# Si ejecutas make sin ningun target que se muestre un listado de targets
default: help

#- Modulos -#

#: Compilar todos los modulos
all: cpu kernel

#: Compilar modulo kernel
kernel: 
	@make build modulo=$@

#: Compilar modulo cpu
cpu: 
	@make build modulo=$@

#- Ejecutar un modulo -#

# Checkeos que se deben hacer antes de ejecutar un modulo
prerun:
	@if [ "$(modulo)" = "" ]; then \
		echo "make run modulo=<modulo> [parametros=<parametros...>]"; \
		echo "         ${RED}^^^^^^^^^^^^^^^ Falta definir modulo${NC}\n\n"; \
		echo "Ejemplo: ${CYAN}make run modulo=cpu${NC}\n\n"; \
		exit 1; \
	fi

	@if [ ! -e $(BUILD_DIR)/$(modulo) ]; then \
		echo "make run modulo=${RED}$(modulo)${NC} $(parametros)"; \
		echo "                ${RED}^ El modulo $(modulo) no esta compilado.${NC}\n"; \
		read -p "$$(echo "¿Desea compilar y volver a ejecutar el modulo $(modulo)? (y/n): ")" yn; \
		case $$yn in \
			[Yy]* ) make $(modulo); exit 0;; \
			* ) echo "\n${RED}Debe compilar el modulo $(modulo) para poder ejecutarlo:\n\t${NC}make $(modulo)\n\n"; exit 1;; \
		esac; \
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


#: Ejecuta un modulo con parametros
#: modulo=<nombre modulo> [parametros='<parametros...>']
#: Ej: make run modulo=cpu parametros='param1 param2'
#: 
run: prerun
	@./$(BUILD_DIR)/$(modulo) $(parametros); \
	make postrun RESULT="$$?";

#: Ejecuta un modulo con valgrind - sudo apt install valgrind
#: modulo=<nombre modulo> [parametros='<parametros...>']
#: Ej: make valgrind modulo=cpu parametros='param1 param2'
valgrind: prerun
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

	@echo "${GREEN}==================================${NC}"
	@echo "Compilando ${GREEN}$(modulo)${NC}..."
	@echo "${GREEN}⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄${NC}"
	@echo ""
	@echo "gcc -g $(wildcard ./$(modulo)/*.c) $(wildcard ./$(SHARED_DIR)/*.c) -o $(BUILD_DIR)/$(modulo) $(LIBS)"
	@gcc -g $(wildcard ./$(modulo)/*.c) $(wildcard ./$(SHARED_DIR)/*.c) -o $(BUILD_DIR)/$(modulo) $(LIBS); \
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


