# Guía para probar el sistema con una cámara web

Esta funcionalidad está disponible únicamente para sistemas Linux.

1. Identificar el número de dispositivo. Normalmente en linux se pueden visualizar como archivos en `/dev/video#`.

    ```bash
    ls /dev/video*
    ```

2. Indicar el archivo de dispositivo al construir el contenedor:

    ```bash
    WEBCAM_DEVICE=/dev/video0 docker compose -f docker/compose.yml up --build

3. Agregar la cámara web desde la aplicación colocando el índice (Usualmente 0) en el *URL*.

4. Ejecutar el servicio.