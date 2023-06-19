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

# Carpeta donde se guardaran los modulos compilados
BUILD_DIR = build

#: <modulo> - Compilar un modulo
build: modulo := $(word 2, $(MAKECMDGOALS))
build:
	@if [ "$(modulo)" = "" ]; then \
		echo "Defina modulo: make build <modulo>\n"; \
		exit 1; \
	fi

	@if [ ! -e $(modulo) ]; then \
		echo "Error: modulo $(modulo) no existe. Recuerde que debe existir la carpeta para el modulo\n"; \
		exit 1; \
	fi

	@echo "Compilando $(modulo)..."
	@echo "------------------------------"
	mkdir -p $(BUILD_DIR)
	gcc -o $(BUILD_DIR)/$(modulo) $(wildcard ./$(modulo)/*)

#: <modulo> <parametros...> - Ejecuta un modulo previamente compilado con parametros
run: modulo := $(word 2, $(MAKECMDGOALS))
run: parametros := $(filter-out run $(modulo), $(MAKECMDGOALS))
run:
	@if [ "$(modulo)" = "" ]; then \
		echo "Defina modulo: make run <modulo> <parametros...>\n"; \
		exit 1; \
	fi

	@if [ ! -e $(BUILD_DIR)/$(modulo) ]; then \
		echo "Error: modulo $(modulo) no fue compilado. Intenta ejecutar: make build $(modulo)\n"; \
		exit 1; \
	fi

	@echo "Ejecutando $(modulo)..."
	@echo "---------------------------"
	@./$(BUILD_DIR)/$(modulo) $(parametros)

# Hack para que si el target no existe no diga nada
%:
	@: