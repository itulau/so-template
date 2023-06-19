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

# ----------------------------------------
# -----------------TARGETS----------------
# ----------------------------------------

# Si ejecutas make sin ningun target que se muestre un listado de targets
default: help

#- Compilacion -#

#: Compilar todos los modulos
all: cpu kernel

#: Compilar modulo kernel
kernel: commons
	@make build modulo=$@

#: Compilar modulo cpu
cpu: commons
	@make build modulo=$@

#- Ejecucion -#

#: Ejecuta un modulo con parametros
#: modulo=<nombre modulo> [parametros='<parametros...>']
run:
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
	@./$(BUILD_DIR)/$(modulo) $(parametros); \
	RESULT=$$?; \
	if [ "$$RESULT" = "0" ] ; then \
		echo ""; \
		echo "${CYAN}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"; \
		echo "${CYAN}$(modulo)${NC} finalizo su ejecucion exitosamente!"; \
	else \
		echo ""; \
		echo "${RED}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"; \
		echo "${RED}$(modulo)${NC} finalizo su ejecucion con error $$RESULT!"; \
	fi

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

	@echo "${GREEN}==================================${NC}"
	@echo "Compilando ${GREEN}$(modulo)${NC}..."
	@echo "${GREEN}⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄${NC}"
	@echo ""
	@echo "gcc -o $(BUILD_DIR)/$(modulo) $(wildcard ./$(modulo)/*.c) $(wildcard ./$(SHARED_DIR)/*.c) $(LIBS)"
	@gcc -o $(BUILD_DIR)/$(modulo) $(wildcard ./$(modulo)/*.c) $(wildcard ./$(SHARED_DIR)/*.c) $(LIBS); \
	if [ "$$?" = "0" ] ; then \
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
	@echo "\nComandos disponibles:"
	@echo "---------------------"
	@sed '1s;^;\n;' Makefile \
	| perl -pe 's/#[^:^-](.*)\n//g' \
	| grep -zoP "((\n#:.*)+\n[^:]+:|\n#- (.*) -#)" \
	| perl -pe 's/\0/\n/g' \
	| perl -0777 -pe 's/((#: (.*)\n)+)(.*):/make $$4$$1\n/g' \
	| perl -0777 -pe 's/\n#: /\n###/g' \
	| perl -0777 -pe 's/#: /###/g' \
	| perl -0777 -pe 's/#- (.*) -#/###\n$$1:###\n###/g' \
	| column -t -s '###'
	@echo "\n---------------------\n"