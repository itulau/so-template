#: Mostrar listado de comandos disponibles
help:
	@echo "Comandos disponibles"
	@echo "--------------------"
	@echo ""
	@sed '1s;^;\n;' Makefile \
	| perl -pe 's/#[^:^-](.*)\n//g' \
	| grep -zoP "((\n#:.*)+\n[^:]+:|\n#- (.*) -#)" \
	| perl -pe 's/\0/\n/g' \
	| perl -0777 -pe 's/((#: (.*)\n)+)(.*):/make $$4$$1\n/g' \
	| perl -0777 -pe 's/\n#: /\n	 ###/g' \
	| perl -0777 -pe 's/#: / ###/g' \
	| perl -0777 -pe 's/#- (.*) -#/$$1:###/g' \
	| column -t -s '###'

# Definimos los targets que no estan relacionados a ningun archivo
.PHONY: build run

# Definimos colores para marcar cosas
GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m

# Carpeta donde se guardaran los modulos compilados
BUILD_DIR = build

#: <modulo> - Compilar un modulo
build: modulo := $(word 2, $(MAKECMDGOALS))
build:
	@if [ "$(modulo)" = "" ]; then \
		echo "Defina modulo: make build <modulo>\n"; \
		exit 1; \
	fi

	@if [ "$(modulo)" = "shared" ]; then \
		echo "El modulo shared no es necesario compilarlo, es incluido cuando se compila cualquier otro modulo"; \
		exit 1; \
	fi

	@if [ ! -e $(modulo) ]; then \
		echo "Error, la carpeta $(modulo) no existe.\n"; \
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

#: <modulo> <parametros...> - Ejecuta un modulo previamente compilado con parametros
run: modulo := $(word 2, $(MAKECMDGOALS))
run: parametros := $(filter-out run $(modulo), $(MAKECMDGOALS))
run:
	@if [ "$(modulo)" = "" ]; then \
		echo "Defina modulo: make run <modulo> <parametros...>\n"; \
		exit 1; \
	fi

	@if [ ! -e $(BUILD_DIR)/$(modulo) ]; then \
		echo "Error, modulo $(modulo) no fue compilado. Para compilarlo ejecute: make build $(modulo)\n"; \
		exit 1; \
	fi

	@echo "Ejecutando ${GREEN}$(modulo)${NC}..."
	@echo "${GREEN}⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄⌄${NC}"
	@echo ""
	@./$(BUILD_DIR)/$(modulo) $(parametros)
	@echo ""
	@echo "${GREEN}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^${NC}"
	@echo "${GREEN}$(modulo)${NC} finalizo su ejecucion"

# Hack para que si el target no existe no diga nada
%:
	@: