#!/bin/bash

WORKSPACE="/workspace"
INSTANCEDIR="$WORKSPACE/video-surveillance-app/instance"

ACTION=$1

if [ -z "$ACTION" ]; then
    echo "Por favor indique una acción"
    exit 1
fi

CWD=$(pwd)

case $ACTION in
  "app")
    cd "$WORKSPACE/video-surveillance-app/"

    if [ ! -f "$INSTANCEDIR/app.db" ]; then
        echo "Inicializando base de datos"
        python init_db.py "Admin" "admin@email.com" "admin"
    fi

    echo "Iniciando la aplicación..."
    gunicorn --worker-class gthread --workers 1 --threads 8 --bind 0.0.0.0:8000 wsgi:app
    ;;
  "service")
    if [ -z "$2" ]; then
        echo "Por favor indique el nombre del servicio a ejecutar"
        exit 1
    fi

    cd "$WORKSPACE/video-surveillance-app/scripts/"

    bash "${2}.sh" "${@:3}"
    ;;
  "yolotracker")
    if [ -z "$2" ]; then
        echo "Por favor indique el nombre del script a ejecutar"
        exit 1
    fi

    cd "$WORKSPACE/yolotracker/scripts/"

    python "${2}.py" "${@:3}"
    ;;
  *)
    echo "Usage: $0 {app|service|yolotracker} [OPTIONS]"
    exit 1
esac

cd "$CWD"