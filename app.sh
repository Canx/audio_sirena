#!/bin/bash

# Función para mostrar la interfaz
function main_app {
  # Mostrar mensaje de bienvenida
  if ! command -v zenity &> /dev/null; then
    echo "ffmpeg no está instalado"
    exit 1
  fi

  # Solicitar la selección de los archivos
  cancion=$(zenity --file-selection --title="Selecciona la canción:")

  # Solicitar el audio del mensaje
  mensaje=$(zenity --file-selection --title="Selecciona el mensaje:")

  # Ejecutar el script que recibe las rutas de los archivos y el contenido del cuadro de texto

  # TODO: Añadir el nombre de la canción en el nombre de salida
  editar "$cancion" "$mensaje" "sirena.mp3"
}

function editar {
  # Añadimos el mensaje dos veces
  combinar "$1" "$2" "temp1.mp3" "00:00:05"
  combinar "temp1.mp3" "$2" "temp2.mp3" "00:00:15"

  # Cortamos el mensaje a 1 minuto
  cortar "temp2.mp3" "temp3.mp3"

  # Normalizamos el audio
  normalizar "temp3.mp3" "$3"

  # Borramos archivos temporales
  rm temp1.mp3
  rm temp2.mp3
  rm temp3.mp3
}

function combinar {
  # Asignar los argumentos a variables
  file1="$1"
  file2="$2"
  output="$3"
  start_time="$4"


  # Usando ffmpeg para concatenar los archivos mp3
  ffmpeg -i "$file1" -ss 0 -t "$start_time" -acodec copy part1.ts
  ffmpeg -i "$file1" -ss "$start_time" -acodec copy part2.ts
  ffmpeg -i "$file2" -acodec copy mensaje.ts

  ffmpeg -i "concat:part1.ts|mensaje.ts|part2.ts" -acodec copy "$output"

  # Eliminación de los archivos temporales
  rm part1.ts
  rm part2.ts
  rm mensaje.ts

  # Comprobar si se ha realizado correctamente la combinación
  if [ $? -ne 0 ]; then
    echo "Error al combinar los archivos"
    exit 1
  fi

  echo "Combinación realizada correctamente, resultado guardado en $nombre_fichero_salida"
}

function cortar {
  # Verificar si el archivo especificado existe
  if [ ! -f "$1" ]; then
    echo "El archivo especificado no existe"
    exit 1
  fi

  # Verificar si ffmpeg está instalado
  if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg no está instalado"
    exit 1
  fi

  # Recortar archivo a 1 minuto
  ffmpeg -i "$1" -t 60 "$2"

  echo "El archivo ha sido recortado a 1 minuto exitosamente"
}

function normalizar {
  # Verificar si el archivo especificado existe
  if [ ! -f "$1" ]; then
    echo "El archivo especificado no existe"
    exit 1
  fi

  # Verificar si ffmpeg está instalado
  if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg no está instalado"
    exit 1
  fi

  # Normalizar audio
  ffmpeg -i "$1" -af loudnorm=I=-16:TP=-1.5:LRA=11:print_format=summary -f null /dev/null

  # Guardar archivo normalizado
  ffmpeg -i "$1" -af loudnorm=I=-16:TP=-1.5:LRA=11 "$2"

  echo "El archivo ha sido normalizado exitosamente"
}

# Mostrar la interfaz
main_app
