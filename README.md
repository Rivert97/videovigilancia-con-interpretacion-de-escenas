# Videovigilancia con interpretación de escenas

Este proyecto tiene por objetivo utilizar cámaras de videovigilancia para detectar eventos de seguridad, como son: Personas merodeando, personas ingresando a áreas restringidas, objetos abandonados, y la presencia de armas (cuchillos y armas de fuego).

Para generar alertas de seguridad, el sistema combina técnicas de inteligencia artificial y procesamiento de imágenes para detectar objetos y personas en la escena. Posteriormente, les da seguimiento a lo largo del video y, finalmente, emplea esta información para analizar la escena y decidir si alguno de ellos representa un riesgo.

Para un video demostrativo del funcionamiento y explicación del funcionamiento, puede consultar: [Videovigilancia con interpretación de escenas](https://youtu.be/nbg8GqHGUHg).

<p align="center">
<img src="./docs/diagramas/general_schema.png" width="100%" alt="Funcionamiento general">
</p>

NOTA: La documentación principal está en español, pero la documentación de los submódulos está en inglés, principalmente para mantener compatibilidad con los repositorios originales.

## Categoría y nombre del equipo

* **Categoría:** C - Analítica de video para seguridad perimetral
* **Equipo:** Videovigilancia con interpretación de escenas

## Tabla de contenidos

* [Requisitos del sistema](#requisitos-del-sistema)
    * [Modo aplicación](#requisitos-en-modo-aplicación)
    * [Modo desarrollo](#requisitos-en-modo-desarrollo)
* [Instalación](#instalación)
    * [Modo aplicación](#instalación-en-modo-aplicación)
    * [Modo desarrollo](#instalación-en-modo-desarrollo)
* [Configuración de la aplicación](#configuración-de-la-aplicación)
    * [Agregar cámara RTSP](#agregar-cámara-rtsp)
    * [Agregar cámara web](#agregar-cámara-web)
    * [Merodeo](#merodeo)
    * [Intrusión](#intrusión)
    * [Objeto Abandonado](#objetos-abandonados)
    * [Arma](#armas)
* [Descargas de modelos y datasets](#descargas-de-modelos-y-datasets)
* [Ejecutar la aplicación](#ejecutar-la-aplicación)
* [Probar el sistema](#probar-el-sistema)
    * [Detección en tiempo real](#visualización-de-detección-en-tiempo-real)
    * [Videos pregrabados](#pruebas-en-videos-pre-grabados)
    * [Webcam](#pruebas-con-webcam-integrada)
* [Pruebas automatizadas](#pruebas-automatizadas)
* [Estructura del proyecto](#estructura-del-proyecto)
* [Tecnologías utilizadas](#tecnologías-utilizadas)
* [Métricas principales](#métricas-principales)
* [Limintaciones conocidas](#limitaciones-conocidas)
* [Créditos](#créditos)

## Requisitos del sistema

El proyecto cuenta con dos modos de instalación:

* **Modo aplicación:** Utiliza Docker para desplegar el sistema de forma rápida.
    * Control a través de aplicación web.
    * Capturar video de cámaras por RTSP.
    * Alta de detectores de eventos.
    * Visualización de bitácoras y descarga de clips de eventos.
    * En Linux. Captura de video de cámaras web, siguiendo [Conectar cámara web al contenedor](./docs/conectar_camara_web.md).
* **Modo desarrollo:** Instala Python y todas sus dependencias para probar todos los scripts y funcionalidades del sistema.
    * Funcionalidades del *modo aplicación*.
    * Capturar video de cámaras web integradas o conectadas por USB.
    * Detectar eventos en videos pregrabados.
    * Visualización en tiempo real de las detecciones (no solo clips de eventos).
    * Entrenamiento de modelo de detección de armas.
    * Detección en videos pre-grabados.

Además, puede utilizarse con GPU o únicamente con CPU. Considere que la inferencia con CPU es más lenta. Los requisitos generales deben instalarse independientemente del modo de uso de la aplicación.

### Requisitos Generales

* **Sistema Operativo:** Windows 10 o Ubuntu 24.04. Esta guía fue probada en Windows 10 y en Kubuntu 24.04.
* **Hardware Mínimo:**
    * Intel Core i5-10300H
    * 8 GB de RAM DDR4
    * GPU NVIDIA con 4 GB de memoria (Opcional. Requerido para entrenamiento y para inferencia con cuda.)
* **Docker Engine:** En Linux, seguir la guía de instalación de [Docker Engine en Linux](https://docs.docker.com/engine/install/), no se recomienda instalar *Docker Desktop* por incompatibilidades en el uso de la GPU, además se recomienda agregar el usuario al grupo docker para poder ejecuar contenedores  sin sudo [Ver Aquí](https://www.drupaladicto.com/snippet/como-corregir-error-docker-got-permission-denied-while-trying-connect-docker-daemon-socket). En Windows, se recomienda instalar [Docker Desktop](https://www.docker.com/products/docker-desktop/).
* **Drivers de NVIDIA:** Descargar la versión correspondiente a la tarjeta gráfica instalada. Revise la [Página Oficial de NVIDIA](https://www.nvidia.com/es-es/drivers/). En Ubuntu y derivados, checa este link: [NVIDIA drivers installation](https://ubuntu.com/server/docs/how-to/graphics/install-nvidia-drivers/).
* **Cámara IP con soporte RTSP:** Para probar la aplicación en tiempo real es necesario tener una cámara conectada a la misma red que el equipo donde se intalará la aplicación.
* **Cámara web:** En *modo desarrollo* se puede probar la aplicación con una cámara web integrada o conectada por USB.

### Requisitos en *modo aplicación*

* **Nvidia Container Toolkit(v1.19.1-1):** Solo para Linux. Seguir las instrucciones de la [Página Oficial](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html). En Windows asegúrate de que Docker utiliza WSL 2.

### Requisitos en *modo desarrollo*

* **Python (v3.12.3):** Descargar desde la [Página Oficial de Python](https://www.python.org/downloads/). También se puede instalar con [Conda](https://docs.conda.io/projects/conda/en/stable/user-guide/install/index.html) o [Pyenv](https://github.com/pyenv/pyenv).
* **Compilador GCC:** En Linux se debe instalar el paquete `build-essential`. En Windows debe instalarse por separado.
* **Herramientas de desarrollo de Python:** En Linux se debe instalar el paquete `python3-dev`. En Windows estas herramientas se incluyen por defecto.

## Instalación

Independientemente del tipo de instalación se deben seguir los siguientes pasos:

1. Descargar el repositorio y sus submódulos:

    ```bash
    git clone --recurse-submodules https://github.com/Rivert97/videovigilancia-con-interpretacion-de-escenas.git
    cd videovigilancia-con-interpretacion-de-escenas
    ```

2. Descargar los modelos preentrenados desde Google Drive ([Link](https://drive.google.com/file/d/1HcN4MLRHlNK7AFgKPlwyMOMSZxjR-UDZ/view?usp=sharing)).
3. Descomprimir la carpeta en `videovigilancia-con-interpretacion-de-escenas/weights`. La estructura final debe ser:

    ```
    .
    ...
    ├── LICENSE
    ├── README.md
    ├── weights
    │   ├── osnet_x0_25_msmt17.onnx
    │   ├── osnet_x0_25_msmt17.onnx.data
    │   ├── yolox_s.onnx
    │   ├── yolox_s_weapon.onnx
    │   ├── yolox_s_weapon.onnx.data
    │   ├── yolox_s_weapon_merged.onnx
    │   └── yolox_s_weapon_merged.onnx.data
    ...

### Instalación en *modo aplicación*

1. Iniciar el servicio de *Docker*. En Windows el servicio se inicia al abrir *Docker Desktop*, en Linux usualmente inicia de forma automática.
2. Detener cualquier servicio que esté corriendo en los puertos de redis (6379, 8001) o en el puerto de la aplicación (8000).
3. Crear los contenedores y ejecutarlos. El comando siguiente crea el contenedor de la aplicación y descarga un contenedor Redis-Stack. El proceso puede demorar varios minutos:

    ```bash
    docker compose -f docker/compose.yml up --build
    ```

4. Se debe esperar a que aparezca un mensaje como el siguiente:

    ```bash
    video-surveillance-app  | Settings added correctly
    video-surveillance-app  | User Admin created successfully.
    video-surveillance-app  | Iniciando la aplicación...
    video-surveillance-app  | [2026-06-08 20:16:53 -0600] [30] [INFO] Starting gunicorn 26.0.0
    video-surveillance-app  | [2026-06-08 20:16:53 -0600] [30] [INFO] Listening at: http://0.0.0.0:8000 (30)
    video-surveillance-app  | [2026-06-08 20:16:53 -0600] [30] [INFO] Using worker: gthread
    video-surveillance-app  | [2026-06-08 20:16:53 -0600] [31] [INFO] Booting worker with pid: 31
    video-surveillance-app  | [2026-06-08 20:16:53 -0600] [30] [INFO] Control socket listening at /root/.gunicorn/gunicorn.ctl
    ```

5. La aplicación puede accederse desde http://localhost:8000. El usuario por defecto es *admin@email.com* y la contraseña *admin*.

6. Para detener la aplicación se debe usar `d Detach` para salir del modo bitácora de Docker. Y ejecutar:

    ```bash
    docker compose -f docker/compose.yml stop
    ```

NOTA: En *modo aplicación*, los modelos son cargados desde `weights/` y los datos de la aplicación son guardados en `instance/`.

### Instalación en *modo desarrollo*

1. Detener cualquier servicio que esté corriendo en los puertos de Redis (6379, 8001) o de la aplicación (8000).

2. Crear un entorno virtual de python. En caso de no tener venv, instalar de acuerdo al sistema operativo:

    ```bash
    python3 -m venv .venv
    ```

3. Activar el entorno virtual:

    ```bash
    # Linux
    source .venv/bin/activate
    # Windows
    source .venv\Scripts\activate
    ```

4. Instalar paquetes de construcción:

    ```bash
    pip install --upgrade pip setuptools wheel
    ```

5. Instalar Pytorch. Nota: Si la partición `/tmp` es muy pequeña se puede agregar `TMPDIR=/home/$USER/tmp_pip` para evitar el error de `No space left on device`:

    ```bash
    pip install torch==2.10.0 torchvision==0.25.0 --index-url https://download.pytorch.org/whl/cu126
    ```

6. Instalar paquetes y dependencias. Los paquetes se instalan como editables para poder editarlos y a la vez importarlos desde cualquier lugar:

    ```bash
    cd src
    pip install --no-build-isolation -e YOLOX
    pip install -e deepsort-pip
    pip install -e yolotracker
    cd video-surveillance-app
    pip install -r requirements.txt
    ```

7. Crear y ejecutar un contenedor con Redis. Éste se usa para el *caché Redis* y para el envío de notificaciones en la aplicación.

    ```bash
    docker run -p 6379:6379 -p 8001:8001 --rm -d --name redis redis/redis-stack:latest
    ```

8. Ahora se debe inicializar la base de datos y crear un usuario y contraseña:

    ```bash
    python init_db.py "<Nombre>" "<Correo>" "<Contraseña>"
    ```

9. Ejecutar la aplicación:

    ```bash
    python run.py
    ```

9. La aplicación puede accederse desde http://localhost:8000, usar el usuario y contraseña recién creados.

    NOTA: En *modo desarrollo*, los modelos son cargados desde `weights/` y los datos de la aplicación son guardados en `video-surveillance-app/instance/`.

10. (Opcional). Algunas veces aparece el error `Note that Qt no longer ships fonts..` al ejecutar la aplicación. Para corregir ese error, seguir la guía de [Instalación de fuentes Qt](./src/yolotracker/docs/install_qt_fonts.md).

<p align="center">
<img src="./docs/imagenes/login.png" width="800" alt="Pantalla de login">
</p>

## Configuración de la aplicación

La configuración de la aplicación es la misma tanto para el *modo aplicación* como para el *modo desarrollo*.

1. Acceder a la aplicación con el usuario y contraseña.

2. Dirigirse a *Configuración > Cámaras > Agregar cámara*.

    <p align="center">
    <img src="./docs/imagenes/agregar_camara.png" width="800" alt="Agregar cámara">
    </p>

3. En *modo aplicación* solo es posible [agregar una cámara RTSP](#agregar-cámara-rtsp). En *modo desarrollo* también se puede [agregar una cámara web](#agregar-cámara-web) para probar el sistema.

4. Agregar detectores de eventos: [Merodeo](#merodeo), [Objetos abandonados](#objetos-abandonados), [Intrusión](#intrusión), [Armas](#armas).

5. Comenzar la detección de eventos. Este es un servicio que se ejecuta en segundo plano y se controla con la opción *Servicios > Servicio de detección de eventos*. Hacer clic en *iniciar*.

    <p align="center">
    <img src="./docs/imagenes/services.png" width="800" alt="Manejo de servicios">
    </p>

    Cada que se modifique alguna configuración del sistema, las cámaras o los detectores, es necesario reiniciar el servicio. Es recomendable apagar el servicio antes de hacer modificaciones, pues algunas opciones de los detectores requieren que el servicio esté desactivado para conectarse a las cámaras.

### Agregar cámara RTSP

Para un funcionamiento adecuado del sistema, la cámara debe estar conectada por cable ethernet, ya que las conexiones WiFi son inestables.

1. Activar el protocolo desde la aplicación del proveedor. Para cámaras Ezviz, revisar [RTSP en Ezviz](https://svtclti.com/manuales/CCTV/CAMARAS/EZVIZ/C%C3%B3mo%20activar%20RTSP%20en%20Ezviz.pdf) o [RTSP en Hikivision](https://www.securame.com/blog/hikvision-como-acceder-a-un-dispositivo-mediante-rtsp/).

2. Obtener el usuario y contraseña de la cámara. Generalmente el usuario es *admin* y la contraseña viene incluida en la etiqueta de la cámara. Para cámaras ezviz puede buscarse como *Verification Code*.

    <p align="center">
    <img src="./docs/imagenes/camara_ezviz.jpeg" width="300" alt="Código de verificación">
    </p>

3. Obtener la dirección IP de la cámara. Esta puede consultarse desde la aplicación de Ezviz como se muestra en [RTSP en Ezviz](https://svtclti.com/manuales/CCTV/CAMARAS/EZVIZ/C%C3%B3mo%20activar%20RTSP%20en%20Ezviz.pdf) o desde la administración de redes del router o módem.

4. Obtener la URL de conexión. Puede variar dependiendo del proveedor, para cámaras Ezviz es de la forma `rtsp://admin:CodigoDeVerificacion@DireccionIP:554/stream1`. Para cámaras cámaras Hikivision, revisar [Cómo acceder a un dispositivo mediante RTSP](https://www.securame.com/blog/hikvision-como-acceder-a-un-dispositivo-mediante-rtsp/).

5. Agregar la cámara con un *Nombre* y la *URL*.

    <p align="center">
    <img src="./docs/imagenes/add_camera_ezviz.png" width="800" alt="Agregar cámara Ezviz">
    </p>

### Agregar cámara web

La conexión a la cámara se realiza mediante OpenCV, el cual permite la conexión de una gran cantidad de cámaras web utilizando un índice de conexión. Por defecto, la cámara integrada (o principal) es el índice `0`. Para más detalles, revisar la [documentación de OpenCV](https://opencv24-python-tutorials.readthedocs.io/en/latest/py_tutorials/py_gui/py_video_display/py_video_display.html).

1. Agregar la cámara con un *Nombre* y en el campo de *URL* colocar el índice de la cámara.

    <p align="center">
    <img src="./docs/imagenes/add_webcam.png" width="800" alt="Agregar cámara web">
    </p>

### Merodeo

Se considera como merodeo cuando una persona se muestra en escena durante más de un tiempo determinado. Para configurarlo se utiliza la opción de *Agregar detector* de la cámara y se indica el *Tiempo máximo en pantalla* que una persona puede estar antes de que sea considerado merodeo. Este valor está en segundos.

<p align="center">
<img src="./docs/imagenes/add_loitering.png" width="800" alt="Agregar detector de merodeo">
</p>
<p align="center">
<img src="./docs/imagenes/loitering_example.png" width="800" alt="Ejemplo de merodeo">
</p>

### Objetos abandonados

Se considera como objeto abandonado a objetos de tipo bolsas o desconocido que permanezcan en escena durante más de un tiempo determinado y que además no se hayan movido. Para configurarlo se utiliza la opción de *Agregar detector* de la cámara y se indica el *Tiempo máximo de abandono*.

<p align="center">
<img src="./docs/imagenes/add_abandoned.png" width="800" alt="Agregar detector de abandono">
</p>

Además, el detector necesita calcular el fondo de referencia de la escena. Para ello se debe esperar a que la escena esté en su estado base, es decir, sin objetos temporales (puede haber personas caminando), y se debe hacer clic en el botón de *Capturar Fondo*. Al dar click en el botón se capturarán 300 frames para promediar el fondo de la escena.

<p align="center">
<img src="./docs/imagenes/get_background.png" width="800" alt="Obtener el fondo">
</p>

<p align="center">
<img src="./docs/imagenes/abandoned_example.png" width="800" alt="Ejemplo de abandono">
</p>

NOTA: El fondo puede re-capturarse cuantas veces sea necesario.

### Intrusión

Para la intrusión, primero se define un área restringida con un polígono dibujado en la imagen. Cuando una persona ingrese a esa área se considera como intrusión.

Se utiliza la opción de *Agregar detector*. La aplicación capturará una imagen de la cámara, sobre la cual se debe dibujar un polígono dando clics en la imagen (no es necesario unir el primer punto con el último). Una vez finalizado se da clic en *Finalizar polígono* y el programa conectará el último punto con el primero para finalizar.

<p align="center">
<img src="./docs/imagenes/draw_polygon.png" width="800" alt="Dibujar polígono">
</p>

Posteriormente se configura el porcenaje del cuerpo de la persona que debe ingresar al polígono para que se considere como intrusión. Además, el sistema permite establecer un rango de horas en que el detector está activo, de esta forma la detección puede realizarse solo cuando es de noche, o fuera de horario laboral. Por defecto se aplica la detección las 24hrs.

<p align="center">
<img src="./docs/imagenes/add_intrusion.png" width="800" alt="Agregar detector de intrusión">
</p>

<p align="center">
<img src="./docs/imagenes/intrusion_example.png" width="800" alt="Ejemplo de intrusión">
</p>

### Armas

Cuando un arma se detecta en la escena se lanza el evento, sin embargo, para evitar falsos positivos se establece un mínimo de tiempo que el arma debe ser detectada antes de lanzar el evento. Este valor se configura al utilizar la opción de *Agregar detector*, bajo la opción de *Tiempo de detección*, donde usualmente se configura un tiempo corto (1 segundo).

<p align="center">
<img src="./docs/imagenes/add_weapon.png" width="800" alt="Agregar detector de armas">
</p>
<p align="center">
<img src="./docs/imagenes/weapon_example.png" width="800" alt="Ejemplo de armas">
</p>

## Descargas de modelos y datasets

### Modelos

Para el funcionamiento de la aplicación, únicamente se necesita descargar los modelos preentrenados del [link de Google Drive](https://drive.google.com/file/d/1HcN4MLRHlNK7AFgKPlwyMOMSZxjR-UDZ/view?usp=sharing) y descomprimirlos en `weights/`.

Si deseas conocer más detalles:

* El modelo de detección de objetos `yolox_s.onnx` se descargó del [repositorio de YOLOX original](https://github.com/Megvii-BaseDetection/YOLOX/tree/main/demo/ONNXRuntime).
* El modelo de extracción de características `osnet_x0_25_msmt17.onnx` se obtuvo siguiendo la guía para [Obtener el modelo ReID preentrenado](./src/yolotracker/docs/get_osnet_for_reid.md).
* El modelo de detección de armas `yolox_s_weapon_merged.onnx` se obtuvo al reentrenar un modelo *yolox_s* en un conjunto de datos de detección de armas, siguiendo la [Gúia para entrenar con Simuletic Syntectic CCTV Weapon datasets](./src/YOLOX/docs/train_cctv_weapon.md).

### Datasets

No es necesario descargar ningún dataset para el funcionamiento de la aplicación, solo deben descargarse en caso de desear replicar la evaluación o el reentrenamiento.

* Para el reentrenamiento del modelo de detección de armas, se debe serguir la [Guía para entrenar con Simuletic Syntectic CCTV Weapon datasets](./src/YOLOX/docs/train_cctv_weapon.md), que utiliza dos datasets:
    * **[Simuletic Synthetic CCTV Weapon-Detection dataset](https://simuletic.com/blog/weapon-detection-dataset):** Creado con imágenes sintéticas de personas sosteniendo armas de fuego. Contiene dos clases: persona, arma.
    * **[Simuletic Synthetic CCTV ATM Robbery Detection Dataset: Gun & Knife](https://www.kaggle.com/datasets/simuletic/cctv-atm-robbery-detection-dataset-gun-and-knife):** Creado con imágenes sintéticas de personas siendo asaltadas en cajeros de banco. Contiene cuatro clases: agresor, víctima, arma, cuchillo.
* Para la evaluación de eventos en videos de cámaras reales, se debe seguir la [Guía para evaluar la detección de eventos](./src/yolotracker/docs/event_detection.md), que utiliza un dataset personalizado:
    * **[Dataset de detección de eventos](https://drive.google.com/file/d/1I6_n2AQM6NCNeEuJ2FRaeDDY2MIuvrMF/view?usp=drive_link):** Este conjunto de datos propio que tiene algunos clips de [VIRAT Dataset 2.0](https://viratdata.org/), videos propios y otros videos de uso libre.
* Para la evaluación de la calidad de detección de objetos en los videos, se debe seguir la [Guía para evaluar la detección de objetos](./src/yolotracker/docs/eval_object_detection.md), que utiliza:
    * **[VIRAT Dataset 2.0](https://viratdata.org):** Solo se toman algunos videos de este dataset.

## Ejecutar la aplicación

1. Si se instaló en *modo aplicación*, usar docker compose para iniciar los contenedores desde la carpeta raiz del repositorio `videovigilancia-con-interpretacion-de-escenas/`.

    ```bash
    docker compose -f docker/compose.yml up
    ```

2. Si se instaló en *modo desarrollo*, iniciar el contenedor Redis e iniciar el servidor de pruebas.

    ```bash
    docker run -p 6379:6379 -p 8001:8001 --rm -d --name redis redis/redis-stack:latest

    cd src/video-surveillance-app
    python run.py
    ```
3. Acceder a la aplicación con el URL: http://localhost:8000
4. Configurar una cámara.
5. Agregar detectores de eventos a la cámara.
6. Iniciar el servicio de detección de eventos y esperar unos segundos a que cargue.
7. Colocarse en el rango de visión de la cámara y realizar una acción que emita una alerta: permanecer en la escena mucho tiempo, dejar un objeto abandonado, ingresar al área restringida abandonada, aparecer con un arma.
8. La aplicación deberá mostrar una notificación en la aplicación cuando detecte un evento de seguridad.

    <p align="center">
    <img src="./docs/imagenes/notification.png" width="800" alt="Notificación de evento">
    </p>

9. Descargar el clip de seguridad desde *Bitácoras > Descargar Clip*.

## Probar el sistema

Para probar el sistema en su totalidad se recomienda instalar en *modo desarrollo*.

### Visualización de detección en tiempo real

El servicio de detección de eventos es un script que si se ejecuta desde consola permite la opción `--display-detection` se puede ver en tiempo real los cuadros que está procesando el servicio.

1. Configuar una o más cámaras desde la aplicación.
2. Agregar uno o más detectores de eventos.
3. Ejecutar el servicio de detección de eventos desde consola.

    ```bash
    cd src/video-surveillance-app/scripts
    python tracking_service.py --display-detection
    ```
4. Esperar a que el programa cargue. Se deberá mostrar una ventana con el video en tiempo real y las detecciones de eventos:

    <p align="center">
    <img src="./docs/imagenes/test_service_two_cameras.png" width="800" alt="Ventana de captura en tiempo real">
    </p>

5. En este caso las notificaciones de eventos se pueden visualizar a través de la aplicación web.

### Pruebas en videos pre-grabados

1. Ejecutar el script `src/yolotracker/test_video.py` con el archivo `data/demo.mp4` incluido o cualquier otro video de cámaras CCTV. Se debe configurar las opciones `--loitering-time`, `--object-time`, `--weapon-time` y `--intrusion-polygon` para configurar los detectores.

    ```bash
    cd src/yolotracker/scripts
    python test_video.py --camera-id 1 --input-shape 640,640 \
    --file ../../../data/demo.mp4 \
    --model ../../../weights/yolox_s.onnx \
    --reid-model ../../../weights/osnet_x0_25_msmt17.onnx \
    --onnx-provider cuda \
    --score-thr 0.5 --weapon-model ../../../weights/yolox_s_weapon_merged.onnx \
    --weapon-score-thr 0.5 --loitering-time=30 --object-time=15 \
    --weapon-time=5 \
    --intrusion-polygon="[[870, 280], [1280, 280], [1280, 720], [820, 1080]]" \
    --shared-storage
    ```

2. Esperar a que carge el programa. Se deberá mostrar una ventana con el video en reproducción y las detecciones de eventos.

    <p align="center">
    <img src="./docs/imagenes/test_video_video.png" width="800" alt="Ventana de video en procesamiento">
    </p>

3. En la consola se deben ir mostrando los eventos de seguridad.

    <p align="center">
    <img src="./docs/imagenes/test_video_events.png" width="800" alt="Notificación de eventos en consola">
    </p>

4. Ejecutar el comando `python test_video.py -h` para ver todas las opciones de la herramienta. También hay ejemplos adicionales en la [Guía de detección de eventos](./src/yolotracker/docs/event_detection.md#testing-on-tenaxes-samples).

### Pruebas con webcam integrada

Es posible probar el sistema con una webcam, ya sea una conectada por USB o la cámara integrada del equipo.

1. Ejecutar el script `src/yolotracker/test_video.py` con el `--camera-id` del índice de la cámara (0 para cámara integrada). Se debe configurar las opciones `--loitering-time`, `--object-time`, `--weapon-time` y `--intrusion-polygon` para configurar los detectores.

    ```bash
    cd src/yolotracker/scripts
    python test_video.py \
    --camera-id 0 \
    --model ../../../weights/yolox_s.onnx \
    --reid-model ../../../weights/osnet_x0_25_msmt17.onnx  \
    --weapon-model ../../../weights/yolox_s_weapon_merged.onnx \
    --onnx-provider cuda \
    --loitering-time 30 \
    --object-time 30 \
    --weapon-time 1 \
    --intrusion-polygon "[[320, 0], [640, 0], [640, 480], [320, 480]]"
    ```

2. Ejecutar `python test_vide.py -h` para ver todas las opciones. O revisar la [Guía de detección de eventos](./src/yolotracker/docs/event_detection.md#testing-on-live-video).

## Pruebas automatizadas

Para ejecutar las pruebas automatizadas se hace uso de *Pytest*.

Hay pruebas en el directorio `tests/` de la raíz del repositorio, y también, cada paquete en `src/` cuenta con sus propias pruebas en su carpeta `tests/`.

Desde la carpeta raíz del repositorio ejecutar:

```bash
pytest
```

Detalles:

* `tests/`: Smoke tests de todo el sistema. Requiren que se hayan descargado todos los modelos preentrenados en `weights/`.
* `src/YOLOX/tests/`: Pruebas unitarias específicas de funcionamiento de modelos YOLOX.
* `src/yolotracker/tests/`: Pruebas unitarias de detección de eventos.

## Estructura del proyecto

* **src/:** Código fuente de la aplicación separado en paquetes para su mejor seguimiento.
    * **YOLOX/:** Paquete para detección de objetos con el modelo YOLOX. Adaptado a Python 3.12 y al conjunto de datos de reconocimiento de armas. Consulte [src/YOLOX/README.md](./src/YOLOX/README.md) para más detalles. (Versión original: [Megii-BaseDetection/YOLOX](https://github.com/megvii-basedetection/yolox)).

    * **deepsort-pip/:** Paquete para seguiiento de múltiples objetos en video. Adaptado a Python 3.12 y con modificaciones para integración con el proyecto. Consulte [src/deepsort-pip/README.md](./src/deepsort-pip/README.md) para más detalles. (Version original: [kadirnar/deepsort-pip](https://github.com/kadirnar/deepsort-pip)).

    * **yolotracker/:** Paquete propio que incluye la lógica de la detección de eventos y combina *yolox* con *deepsort*. Contiene toda la lógica de detección de eventos. Consulte [src/yolotracker/README.md](./src/yolotracker/README.md) para más detalles.

    * **video-surveillance-app/:** Directorio con el código fuente de la aplicación web y el servicio de detección de eventos en tiempo real. Además, contiene la lógica para obtener y procesar video en tiempo real de múltiples cámaras en simultáneo. Consulte [src/video-surveillance-app/README.md](./src/video-surveillance-app/README.md) para más detalles.

* **data/:** Carpeta para descargar datasets y ejemplos de evaluación. Contiene un video demo pero aquí se coloca el dataset de eventos de seguridad.

* **docker/:** Archivos para construir contenedores Docker de la aplicación cuando se instala en *modo aplicación*.

* **docs/:** Contiene archivos auxiliares para la documentación.

* **instance/:** Carpeta vacía donde se colocan los datos de la aplicación cuando se instala en *modo aplicación*. En modo desarrollo se usa *src/video-surveillance-app/instance*.

* **scripts/:** Carpeta para colocar scripts de configuración. Vacía ya que la configuración se realiza con Docker o simplemente ejecutando comandos. Se hace así para mantener compatibilidad de Linux y Windows.

* **weights/:** Carpeta para descargar y colocar modelos en formato ONNX para la aplicación.

* **tests/:** Pruebas generales de la aplicación.

* **reporte_tecnico/:** Reporte técnico de la aplicación.

## Tecnologías utilizadas


* **Sistema Operativo** (Ubuntu 24.04.4 LTS): Ubuntu proporciona herramientas de manejo de drivers de GPU.
* **Sistema Operativo** (Windows 10): Sistema Operativo de pruebas. Se usa para probar compatibilidad pues es el SO de mayor uso comercial.
* **Drivers NVIDIA** (580.159.03): Conexión con GPU NVIDIA. Esta es la versión compatible con hardware utilizado para desarrollo.
* **Docker Engine** (29.5.2): Despliegue de la aplicación y ejecución de Redis para notificaciones. Permite desplegar la aplicación con un solo comando. Permite instalar Redis con un solo comando.
* **Redis Stack (contenedor)** (7.4.0-v8): Cache de detecciones con búsqueda semántica de embeddings. Notificaciones Pop-Up en aplicación web. Su motor de búsqueda por similitud semántica es rápido al estar cargado en memoria. Es necesario para las notificaciones.
* **Pytorch (contenedor)** (2.10.0-cuda12.6-cudnn9-runtime): Imagen base de despliegue del sistema. Tiene Pytorch con soporte para CUDA preinstalado. Evita manejo de dependencias de pytorch al construir el contenedor de la aplicación.
* **Python** (3.12.3): Lenguaje principal del sistema. Compatibilidad entre SO, librerías de visión por computadora, librearías de redes neuronales, librerías de manejo de hilos y multiprocesos.
* **PyTroch** (2.10.0+cu126): Entrenamiento y pruebas de redes neuronales para detección de objetos (armas). Permite usar la GPU para entrenamiento. Existen múltiples modelos preentrenados compatibles con PyTorch.
* **Flask** (3.1.3): Implementación de aplicación web. Fácil de usar, soporta conexiones con múltiples bases de datos.
* **Gunicorn** (26.0.0): Servidor web WSGI. Se requiere para despliegues en producción de aplicación web escritas en Python.
* **Onnxruntime-gpu** (1.24.4): Entorno de ejecución de modelos de detección de objetos en la aplicación. Ejecutar modelos con onnxruntime es más ligero y rápido que utilizar PyTorch.
* **OpenCV-python** (4.13.0.92): Conexión con cámaras RTSP. Conexión con webcams. Procesamiento de cuadros. Con la clase VideoCapture se puede conectar a diferentes tipos de cámaras sin modificaciones en el código. Contiene funciones para transformar y procesar imágenes optimizadas.
* **SQLite** (3.45.1): Base de datos de la aplicación. Integrada en SQLAlchemy, no requiere configuración de un servicio adicional.

## Métricas principales

A este sistema se le ralizaron 3 tipos de evaluaciones principales:

* **Capacidad de detección de personas y vehículos**
* **Capacidad de detección de armas de fuego**
* **Capacidad de detección de eventos de seguridad**

Para evaluar la detección de personas, vehículos y armas de fuego, se adoptó el enfoque tradicional de medir la AP@0.5, es decir, la precisión promedio para umbrales de detección de 0.5. La evaluación se realizó sobre videos reales de cámaras CCTV del dataset VIRAT 2.0, así como los conjuntos de datos de Simulectic para detección de armas.

<table>
    <thead>
        <tr>
            <th>Clase</th>
            <th>AP@0.5</th>
            <th>Muestras</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Persona</td>
            <td>0.27</td>
            <td>39,869</td>
        </tr>
        <tr>
            <td>Vehículo</td>
            <td>0.74</td>
            <td>33,635</td>
        </tr>
    </tbody>
</table>

<table>
    <thead>
        <tr>
            <th>Clase</th>
            <th>Dataset 1 AP@0.5:0.95</th>
            <th>Dataset 1 y 2 AP@0.5:0.95</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Arma</td>
            <td>0.26</td>
            <td>0.25</td>
        </tr>
    </tbody>
</table>

Para evaluar la capacidad de detección de eventos de seguridad se utilizó el *Dataset de detección de eventos*, y se calcularon las métrica: *accuracy*, *precision*, *recall* y *F1*.

<table>
    <thead>
        <tr>
            <td>Evento</td>
            <td>Accuracy</td>
            <td>Precision</td>
            <td>Recall</td>
            <td>F1</td>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Merodeo</td>
            <td>0.72</td>
            <td>1.00</td>
            <td>0.69</td>
            <td>0.78</td>
        </tr>
        <tr>
            <td>Intrusión</td>
            <td>0.96</td>
            <td>1.00</td>
            <td>0.96</td>
            <td>0.98</td>
        </tr>
        <tr>
            <td>Objeto Abandonado</td>
            <td>1.00</td>
            <td>1.00</td>
            <td>1.00</td>
            <td>1.00</td>
        </tr>
        <tr>
            <td>Arma</td>
            <td>0.45</td>
            <td>0.75</td>
            <td>0.60</td>
            <td>0.66</td>
        </tr>
        <tr>
            <td>Media</td>
            <td>0.78</td>
            <td>0.93</td>
            <td>0.81</td>
            <td>0.85</td>
        </tr>
    </tbody>
</table>

Para más detalles sobre la evaluación y las métricas, consultar el [Reporte Técnico](./reporte_tecnico/videovigilancia-con-interpretacion-de-escenas.pdf).

## Limitaciones conocidas


* **Bajo porcentaje de detección de armas de fuego:** El sistema no es capaz de detectar armas cortas (como pistolas) en escenas reales. Esto ocasiona falsos negativos en detección de armas.

* **Necesidad de recalcular el fondo del video cada que hay un cambio permanente en la escena:** Para detectar objetos abandonados, si en un momento dado, se coloca nueva decoración o mobiliario, se tiene que usar la opción de “Calcular fondo” para que la detección de objetos olvidados siga funcionando. Esto ocasiona falsos positivos en eventos de detección de objetos olvidados.

* **Baja detección en personas a distancia:** Si la altura de una persona en la imagen es de menor al 10% de la altura del video, se le dificulta al modelo hacer la detección. Esto ocasiona falsos negativos en videos a larga distancia.

* **Pérdida de rastreo con cambios bruscos de ruta:** Cuando una persona hace un cambio brusco en su movimiento (ej: Gira 90°), es posible que el sistema pierda su rastro y lo identifique como una nueva persona. Esto ocasiona duplicación de alarmas o reinicio de contadores de permanencia.

* **Perspectiva de la cámara para eventos de intrusión:** Si una persona pasa entre la cámara y el área restringida (aunque no la pise) se puede detectar un evento de intrusión. Esto ocasiona falsos positivos en eventos de intrusión.

* **Fallos en la reidentificación de personas:** Cuando una persona sale de la escena, si no entra en un ángulo similar (ej: si no vuelve a entrar por la izquierda), el sistema no puede reidentificarlo. Esto ocasiona la pérdida de rastreo de algunas personas, lo que reinicia los contadores de permanencia.

## Créditos

Roberto García Guzmán. Diseñador, Desarrollador, Tester, Documentador. betogarcia97@live.com.mx

Código bajo Licencia Apache 2.0
