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

# Estos targets no estan relacionados a ningun archivo, entonces los agrego a PHONY para que no se cacheen
.PHONY: build run

# Carpeta donde se guardaran los modulos compilados
OUTPUT = build

#: {modulo=<nombre de modulo>} - Compilar un modulo
build:
	@if [ "$(modulo)" = "" ]; then \
		echo "Error: modulo no definido. Intenta ejecutar: make build modulo=<nombre de modulo>\n"; \
		exit 1; \
	fi

	@echo "Compilando $(modulo)..."
	@echo "------------------------------"
	@echo "Archivos a buildear: $(wildcard ./$(modulo)/*.c)"

	mkdir $(OUTPUT)
	gcc -o $(OUTPUT)/$(modulo) $(wildcard ./$(modulo)/*)

#: {modulo=<nombre de modulo>} - Ejecuta un modulo previamente compilado
run:
	@if [ "$(modulo)" = "" ]; then \
		echo "Error: modulo no definido. Intenta ejecutar: make run modulo=<nombre de modulo>\n"; \
		exit 1; \
	fi

	@if [ ! -e $(OUTPUT)/$(modulo) ]; then \
		echo "Error: $(modulo) no fue compilado. Intenta: make build modulo=$(modulo)"; \
		exit 1; \
	fi

	@echo "Ejecutando $(modulo)..."
	@echo "---------------------------"
	@./$(OUTPUT)/$(modulo)
	
