#!/bin/bash

# Definición de colores para las salidas en la terminal
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Configuración de la captura de la señal INT (Ctrl+C) para ejecutar la funcion Ctrl+C
trap ctrl_c INT

# Función que se ejecuta cuando se recibe la señal INT (Ctrl+C)
function ctrl_c() {
	echo -e "\n\n[${redColour}!${endColour}] Saliendo...\n"
	exit 1
}

# Obtención de la API KEY de URLScan.io desde el archivo credenciales.dat
# Definir API_KEY="API_KEY" en credenciales.dat
API_KEY=$(grep API_KEY credenciales.dat | awk -F '=' '{print $2}' | tr -d '"')

# Definir las variables para cada sitio web en un arreglo
sitios=("irsi.education" "n")

# Declarar un arreglo asociativo para almacenar los UUIDs de URLScan.io asociados a cada sitio
declare -A uuid_por_sitio

# Función para mostrar los sitios web
mostrar_sitios() {
	for sitio in "${sitios[@]}"; do
		echo -e "[${yellowColour}!${endColour}] Sitio web: ${blueColour}$sitio${endColour}"
	done
}

# Función para analizar con wafw00f
analizar_con_wafw00f() {
	for sitio in "${sitios[@]}"; do
		echo -e "[${greenColour}+${endColour}] Analizando el sitio $sitio con ${yellowColour}wafw00f${endColour}..."
		wafw00f $sitio | tee -a STDOUT.log
	done 2>>STDERR.log
	echo -e "[${greenColour}+${endColour}] Hora de ejecución: ${yellowColour}[$(date +'%Y-%m-%d %H:%M:%S')]${endColour}" | tee -a STDOUT.log >>STDERR.log
	printf "[${greenColour}+${endColour}] Resultados guardados en los archivos STDOUT.log y STDERR.log. Presiona 'Enter' para regresar al menú principal "
	read -r
}

# Función para analizar con nmap
analizar_con_nmap() {
	for sitio in "${sitios[@]}"; do
		echo -e "[${greenColour}+${endColour}] Analizando puertos abiertos en $sitio con ${yellowColour}nmap${endColour}..."
		nmap -Pn $sitio | tee -a STDOUT.log
	done 2>>STDERR.log
	echo -e "[${greenColour}+${endColour}] Hora de ejecución: ${yellowColour}[$(date +'%Y-%m-%d %H:%M:%S')]${endColour}" | tee -a STDOUT.log >>STDERR.log
	printf "[${greenColour}+${endColour}] Resultados guardados en los archivos STDOUT.log y STDERR.log. Presiona 'Enter' para regresar al menú principal "
	read -r
}

# Función para leer el log de errores
leer_log_errores() {
	local archivo="./STDERR.log"

	if [ -e "$archivo" ]; then
		echo -e "[${greenColour}+${endColour}] Contenido del archivo de log de errores: ${greenColour}$archivo${endColour} es: "
		echo " "
		cat "$archivo"
	else
		echo -e "[${redColour}!${endColour}] El archivo de log de errores ${redColour}$archivo${endColour} no existe."
	fi
}

# Función para enviar URLs a URLScan.io
enviar_a_urlscan() {
	{
		for sitio in "${sitios[@]}"; do
			echo -e "[${yellowColour}!${endColour}] Enviando $sitio a URLScan.io..."
			response=$(curl -s --request POST --url 'https://urlscan.io/api/v1/scan/' \
				--header "Content-Type: application/json" \
				--header "API-Key: $API_KEY" \
				--data "{\"url\": \"$sitio\", \"customagent\": \"US\"}")
			uuid=$(echo $response | jq -r '.uuid')

			if [ "$uuid" != "null" ]; then
				echo -e "[${greenColour}+${endColour}] UUID de URLScan.io para ${yellowColour}$sitio${endColour}: ${greenColour}$uuid${endColour}"
				uuid_por_sitio["$sitio"]=$uuid
			else
				echo -e "[${redColour}!${endColour}] Error al enviar ${yellowColour}$sitio${endColour} a URLScan.io. Respuesta: ${redColour}$response${endColour}"
			fi
		done
	} > >(tee -a STDOUT.log) 2>>STDERR.log

	echo -e "[${greenColour}+${endColour}] Hora de ejecución: ${yellowColour}[$(date +'%Y-%m-%d %H:%M:%S')]${endColour} Enviar a URLScan.io" | tee -a STDOUT.log | tee -a STDERR.log
	printf "[${greenColour}+${endColour}] Resultados guardados en los archivos STDOUT.log y STDERR.log. Presiona 'Enter' para regresar al menú principal "
	read -r
}

obtener_resultados_urlscan() {
	if [ ${#uuid_por_sitio[@]} -eq 0 ]; then
		echo -e "[${redColour}!${endColour}] No hay UUIDs disponibles. Primero debes enviar sitios a URLScan.io."
		return 1
	fi

	{
		for sitio in "${!uuid_por_sitio[@]}"; do
			uuid=${uuid_por_sitio[$sitio]}
			echo -e "[${greenColour}+${endColour}] Obteniendo resultados de URLScan.io para $sitio (UUID: $uuid)..."
			response=$(curl -s --request GET --url "https://urlscan.io/api/v1/result/$uuid/" \
				--header "API-Key: $API_KEY")

			if [ -n "$response" ]; then
				echo "$response" | tee -a STDOUT.log
			else
				echo -e "[${redColour}!${endColour}] No se pudo obtener resultados para $sitio (UUID: $uuid)"
			fi
		done
	} 2>>STDERR.log

	echo "[${greenColour}+${endColour}] Hora de ejecución: ${yellowColour}[$(date +'%Y-%m-%d %H:%M:%S')]${endColour} Obteniendo resultados de URLScan.io" | tee -a STDOUT.log | tee -a STDERR.log
	printf "[${greenColour}+${endColour}] Resultados guardados en los archivos STDOUT.log y STDERR.log. Presiona 'Enter' para regresar al menú principal "
	read -r
}

# Función para validar que las dependencias estén instaladas
validar_dependencias() {
	dependencias=("curl" "jq" "nmap" "wafw00f")

	for dep in "${dependencias[@]}"; do
		if command -v "$dep" >/dev/null; then
			echo -e "[${greenColour}✔${endColour}] ${yellowColour}$dep${endColour} instalado en ${blueColour}$(which $dep)${endColour}"
		else
			echo -e "[${redColour}✗${endColour}] No tienes ${yellowColour}$dep${endColour}."
			echo -e "[${purpleColour}?${endColour}] ¿Deseas instalar ${yellowColour}$dep${endColour}? (s/n): "
			read instalar

			if [[ "$instalar" == "s" || "$instalar" == "S" ]]; then
				echo -e "[${yellowColour}!${endColour}] Instalando $dep..." >>STDOUT.log 2>>STDERR.log
				sudo apt-get update && sudo apt-get install -y $dep
				echo -e "[${greenColour}✔${endColour}] $dep ha sido instalado correctamente." >>STDOUT.log 2>>STDERR.log
			else
				echo -e "[${redColour}✗${endColour}] No se instalará ${yellowColour}$dep${endColour} y es necesario para ejecutar el script. Saliendo..." >>STDOUT.log 2>>STDERR.log
				exit 1
			fi
		fi
	done
}

# Llama la función para validar dependencias al inicio del script
validar_dependencias

# Bucle infinito que mantiene el menú en pantalla hasta que el usuario elija salir
while true; do
	echo -e "${yellowColour}---------------------------------------------${endColour}"
	echo -e "${yellowColour}|${endColour}                   TP1 Bash                ${yellowColour}|${endColour}"
	echo -e "${yellowColour}---------------------------------------------${endColour}"
	echo
	echo -e "${greenColour}1.${endColour} Mostrar sitios"
	echo -e "${greenColour}2.${endColour} Analizar sitio con ${yellowColour}nmap${endColour}"
	echo -e "${greenColour}3.${endColour} Analizar sitio con ${yellowColour}wafw00f${endColour}"
	echo -e "${greenColour}4.${endColour} Enviar sitio a ${yellowColour}URLScan.io${endColour}"
	echo -e "${greenColour}5.${endColour} Mostrar resultados de ${yellowColour}URLScan.io${endColour}"
	echo -e "${greenColour}6.${endColour} Leer ${yellowColour}archivo de errores${endColour}"
	echo -e "${greenColour}7.${endColour} ${redColour}Salir${endColour}"
	echo
	echo -e "${redColour}>>${endColour} Ingresar opción: "
	read option

	case $option in
	1)
		echo
		mostrar_sitios
		echo
		;;
	2)
		echo
		analizar_con_nmap
		echo
		;;
	3)
		echo
		analizar_con_wafw00f
		echo
		;;
	4)
		echo
		enviar_a_urlscan
		echo
		;;
	5)
		echo
		obtener_resultados_urlscan
		echo
		;;
	6)
		echo
		leer_log_errores
		echo
		;;
	7)
		echo
		echo
		echo -e "[${redColour}!${endColour}] Saliendo..."
		break
		;;
	*)
		echo
		echo -e "[${redColour}!${endColour}] Opción no válida. Por favor, ingrese una de las opciones especificadas."
		;;
	esac

	echo

done
