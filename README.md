# TP1 Bash - IRSI
# IMPORTANTE

Crear tu archivo **credenciales.dat**:

```bash
touch 'API_TOKEN="<token-URLScan.io>"' > credenciales.dat
```

## Lista de tareas:
+ Cree un directorio exclusivamente para esta actividad que contenga todos los
elementos tales como script, archivos de salida, entre otros. ✔

Características del Script:
* Debe utilizar como base todo el código entregado junto con esta actividad. ✔
* Nombre del archivo debe ser: “analisis_web.sh” ✔
* Permisos del archivo script: “755” o “rwxr-xr-x” ✔ (verificar)
* Separar todos los datos sensibles (como credenciales, tokens, contraseñas, etc)
en un archivo anexo al script:
+ Nombre de archivo: “credenciales.dat” ✔ 
+ Permisos del archivo: “600” o “rw-------“ ✔ (verificar)

En el script "analisis_web.sh":
* Implementar una función llamada “validar_comandos” que verifique si “curl”,
“jq”, “nmap”, y “wafw00f” están instalados; si no, pida confirmación para
instalarlos y si ya existen, informe al usuario que están instalados. ✔
+ Use un arreglo indexado para definir la lista de comandos. ✔
+ Esta función se debe ejecutar siempre al iniciar la ejecución misma del
script.
+ Evalúe los comandos utilizando “if else” dentro de un ciclo “for”. ✔
* Utilice “case” para crear un “menú de opciones” que muestre un listado 
ordenado con las opciones. ✔
+ Se deben usar números para elegir manualmente la opción deseada. ✔
+ Cada opción será una función del script. ✔
+ Se debe usar “Enter” para volver al menú principal. ✔
* Utilizando “while”, haga que el menú se vuelva a ejecutar luego de cada
operación, hasta que el usuario ingrese la opción para salir. ✔
+ Utilice “break” para la opción de salida del ciclo “while” que utilizó en el
menú de opciones. ✔
+ Se debe detectar si se ingresó una opción diferente a las que creó en el
menú. ✔
* Redirigir todos los STDOUT a “STDOUT.log” y STDERR a “STDERR.log” a
nivel de función, utilizando la redirección dentro de la definición de cada función. ✘
+ También aplicar a todos los mensajes de usuario que estén o haya
agregado. ✘
+ Cree una función llamada “leer_log_errores” que lea el registro de STDERR. ✘
+  Debe mostrar el registro solo si existe el log, si no existe debe mostrar un ✘

# RECAUCIONES:
* Debe utilizar todas las buenas prácticas para escribir el código del script, como
por ejemplo el manejo de arreglos para variables con varios datos, uso de ciclos,
uso de condiciones if else, manejo de STDOUT y STDERR, entre otros.
* No modifique la variable ”sitios”.
* Un solo alumno de cada grupo debe subir las evidencias a la plataforma.
* Se debe eliminar cualquier código residual (código que no tenga ningún uso).
* Se deben escribir comentarios sobre cada función, línea o bloque de código
indicando su funcionamiento
