#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Función para poder apretar CTRL+C
trap ctrl_c INT 

function ctrl_c(){
  echo -e "\n\n[${redColour}!${endColour}] Saliendo...\n"
  exit 1 
}

# API KEY de URLScan.io 
API_KEY=$(cat credenciales.dat | grep API_TOKEN | awk -F '=' '{print $2}'| tr -d '"')

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
analizar_con_wafw00f(){
  for sitio in "${sitios[@]}"; do 
    echo -e "[${greenColour}+${endColour}] Analizando el sitio $sitio con ${yellowColour}wafw00f${endColour}..." 
    wafw00f $sitio >> STDOUT.log 2> STDERR.log
  done
}

# Función para analizar puertos abiertos con nmap
analizar_con_nmap() {
    for sitio in "${sitios[@]}"; do
        echo -e "[${greenColour}+${endColour}] Analizando puertos abiertos en $sitio con ${yellowColour}nmap${endColour}..."
        nmap -Pn $sitio >> STDOUT.log 2> STDERR.log
    done
}

# Función para enviar URLs a URLScan.io
enviar_a_urlscan() {
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
            echo "Error al enviar $sitio a URLScan.io. Respuesta: $response" >> STDERR.log 2> STDERR.log 
        fi
    done
}

leer_log_errores(){
  local archivo="./STDERR.log"

  if [ -e "$archivo" ]; then
    echo "[+] Contenido del archivo de log de errores: "$archivo" es: "
    echo " "
    cat "$archivo"
  else
    echo "[!] El archivo de log de errores "$archivo" no existe."
  fi   

}

# Función para obtener resultados de URLScan.io
obtener_resultados_urlscan() {
    for sitio in "${!uuid_por_sitio[@]}"; do
        uuid=${uuid_por_sitio[$sitio]}
        echo -e "[${greenColour}+${endColour}] Obteniendo resultados de URLScan.io para $sitio (UUID: $uuid)..."
        response=$(curl -s --request GET --url "https://urlscan.io/api/v1/result/$uuid/" \
        --header "API-Key: $API_KEY")
        echo "$response " | jq >> STDOUT.log 2> STDERR.log
    done
}

# Función para validar que las dependencias estén instaladas
validar_dependencias() {
    dependencias=("curl" "jq" "nmap" "wafw00f")

    # Iterar sobre cada dependencia para verificar su instalación
    for dep in "${dependencias[@]}"; do
        if command -v "$dep" >/dev/null; then
            echo -e "[${greenColour}✔${endColour}] ${yellowColour}$dep${endColour} instalado en ${blueColour}$(which $dep)${endColour}"
        else
            echo -e "[${redColour}✗${endColour}] No tienes ${yellowColour}$dep${endColour}."
            echo -e "[${purpleColour}?${endColour}] ¿Deseas instalar ${yellowColour}$dep${endColour}? (s/n): " 
            read instalar

            if [[ "$instalar" == "s" || "$instalar" == "S" ]]; then
                # Instalar la dependencia
                echo -e "[${yellowColour}!${endColour}] Instalando $dep..."
                sudo apt-get update && sudo apt-get install -y $dep
                echo -e "[${greenColour}✔${endColour}] $dep ha sido instalado correctamente."
            else
                echo -e "[${redColour}✗${endColour}] No se instalará ${yellowColour}$dep${endColour} y es necesario para ejecutar el script. Saliendo..." 2> STDERR.log
                exit 1
            fi
        fi
    done
}

validar_dependencias

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
  echo -e "${redColour}>>${endColour} Ingresar opción: "; read option

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
      #llamamos la funcion
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








