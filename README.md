# Videovigilancia con interpretación de escenas

Este proyecto emplea técnicas de inteligencia artificial para hacer detección de eventos de seguridad en cámaras de videovigilancia. El objetivo es detectar personas y objetos de interés en imágenes de cámaras de seguridad y rastrear su movimiento, para así poder detectar comportamientos sospechosos.

El proyecto está diseñado para funcionar correctamente en Linux y Windows.

## Requisitos

* **Docker Desktop:** Descargar desde la [Página Oficial de Docker](https://www.docker.com/products/docker-desktop/). En Linux usualmente hay que agregar el usuario al grupo docker para poder ejecuar contenedores [Ver Aquí](https://www.drupaladicto.com/snippet/como-corregir-error-docker-got-permission-denied-while-trying-connect-docker-daemon-socket).
* **Python 3.12:** Descargar desde la [Página Oficial de Python](https://www.python.org/downloads/). También se puede instalar con [Conda](https://docs.conda.io/projects/conda/en/stable/user-guide/install/index.html) o [Pyenv](https://github.com/pyenv/pyenv).
* **Compilador GCC:** En Linux se debe instalar el paquete `build-essential`. En Windows debe instalarse por separado.
* **Herramientas de desarrollo de Python:** En Linux se debe instalar el paquete `python3-dev`. En Windows estas herramientas se incluyen por defecto.

### Requisitos para usar GPU NVIDIA

Solo requeridos para inferencia con GPU. El sistema es mucho más rápido cuando se cuenta con una tarjeta gráfica NVIDIA, pero puede funcionar solo con CPU.

* **Drivers de NVIDIA:** Descargar la versión correspondiente a la tarjeta gráfica instalada. Revise la [Página Oficial de NVIDIA](https://www.nvidia.com/es-es/drivers/). En Ubuntu, checa este link: [NVIDIA drivers installation](https://ubuntu.com/server/docs/how-to/graphics/install-nvidia-drivers/).
* **Nvidia Container Toolkit:** Solo para Linux. Seguir las instrucciones de la [Página Oficial](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html). En Windows asegúrate de que Docker utiliza WSL 2.

## Instalación

1. Crear un entorno virtual de python. En caso de no tener venv, instalar de acuerdo al sistema operativo:

```bash
python3 -m venv .venv
```

2. Activar el entorno virtual:

```bash
# Linux
source .venv/bin/activate
# Windows
source .venv\Scripts\activate
```

3. Instalar paquetes de construcción:

```bash
pip install --upgrade pip setuptools wheel
```

4. Instalar Pytorch:

```bash
pip install torch==2.10.0 torchvision==0.25.0 --index-url https://download.pytorch.org/whl/cu126
```

5. Instalar paquetes y dependencias:

```bash
pip install --no-build-isolation -e YOLOX
pip install -e deepsort-pip
pip install -e yolotracker
cd video-surveillance-app
pip install -r requirements.txt
```

6. Crear y ejecutar un contenedor con Redis. Este se usa para el *almacenamento compartido entre cámaras* y para el envío de notificaciones en la aplicación.

```bash
docker run -p 6379:6379 -p 8001:8001 --rm -d --name redis redis/redis-stack:latest
```

7. Ahora se debe inicializar la base de datos y crear un usuario y contraseña:

```bash
python init_db.py "<Nombre>" "<Correo>" "<Contraseña>"
```

8. Ejecutar la aplicación:

```bash
python run.py
```

9. Acceder a la aplicación en `http://localhost:8000` y configurar las cámaras.

<p align="center">
<img src="./images/login.png" width="800" alt="Pantalla de login">
</p>

## Configuración de la aplicación

1. Acceder a la aplicación con el usuario y contraseña recién creado.

2. Dirigirse a *Configuración > Cámaras > Agregar cámara*.

<p align="center">
<img src="./images/agregar_camara.png" width="800" alt="Agregar cámara">
</p>

3. Es posible [agregar una cámara RTSP](#agregar-una-cámara-rtsp), como [agregar una cámara web](#agregar-una-cámara-web).

4. Agregar detectores de eventos: [Merodeo](#merodeo), [Objetos abandonados](#objetos-abandonados), [Intrusión](#intrusión), [Armas](#armas).

### Agregar una cámara RTSP

La mayoría de las cámaras IP implementan el protocolo RTSP como un protocolo de envío de video secundario. Este protocolo permite a aplicaciones de terceros acceder al video en tiempo real a través de una conexión de red local.

Para un funcionamiento adecuado del sistema, la cámara debe estar conectada por Ethernet, ya que las conexiones WiFi son más lentas e inestables.

1. Activar el protocolo desde la aplicación del proveedor. Para cámaras Ezviz, revisar [RTSP en Ezviz](https://svtclti.com/manuales/CCTV/CAMARAS/EZVIZ/C%C3%B3mo%20activar%20RTSP%20en%20Ezviz.pdf).

2. Obtener el usuario y contraseña de la cámara. Generalmente el usuario es *admin* y la contraseña viene incluida en la etiqueta de la cámara. Para cámaras ezviz puede buscarse como *Verification Code*.

<p align="center">
<img src="./images/camara_ezviz.jpeg" width="300" alt="Código de verificación">
</p>

3. Obtener la dirección IP de la cámara. Esta puede consultarse desde la aplicación de Ezviz como se muestra en [RTSP en Ezviz](https://svtclti.com/manuales/CCTV/CAMARAS/EZVIZ/C%C3%B3mo%20activar%20RTSP%20en%20Ezviz.pdf) o desde la administración de redes del router o módem.

3. Obtener la URL de conexión. Puede variar dependiendo del proveedor, para cámaras Ezviz es de la forma `rtsp://admin:CodigoDeVerificacion@DireccionIP:554/stream1`. Para cámaras cámaras Hikivision, revisar [Cómo acceder a un dispositivo mediante RTSP](https://www.securame.com/blog/hikvision-como-acceder-a-un-dispositivo-mediante-rtsp/).

4. Agregar la cámara con un *Nombre* y la *URL*.

<p align="center">
<img src="./images/add_camera_ezviz.png" width="800" alt="Agregar cámara Ezviz">
</p>

### Agregar una cámara web

La conexión a la cámara se realiza mediante OpenCV, el cual permite la conexión de una gran cantidad de cámaras web utilizando un índice de conexión. Por defecto, la cámara integrada (o principal) es el índice `0`. Para más detalles, revisar [OpenCV doc](https://opencv24-python-tutorials.readthedocs.io/en/latest/py_tutorials/py_gui/py_video_display/py_video_display.html).

1. Agregar la cámara con un *Nombre* y en el campo de *URL* colocar el índice de la cámara.

<p align="center">
<img src="./images/add_webcam.png" width="800" alt="Agregar cámara web">
</p>

### Merodeo

Se considera como merodeo cuando una persona se muestra en escena durante más de un tiempo determinado. Para configurarlo se utiliza la opción de *Agregar detector* de la cámara y se indica el *Tiempo máximo en pantalla* que una persona puede estar antes de que sea considerado merodeo. Este valor está en segundos.

<p align="center">
<img src="./images/add_loitering.png" width="800" alt="Agregar detector de merodeo">
</p>

### Objetos abandonados

Se considera como objeto abandonado a objetos de tipo bolsas o desconocido que permanezcan en escena durante más de un tiempo determinado y que además no se hayan movido. Para configurarlo se utiliza la opción de *Agregar detector* de la cámara y se indica el *Tiempo máximo de abandono*.

<p align="center">
<img src="./images/add_abandoned.png" width="800" alt="Agregar detector de abandono">
</p>

Además, el detector necesita calcular el fondo de referencia de la escena. Para ello se debe esperar a que la escena esté en su estado base, es decir, sin objetos temporales (puede haber personas caminando), y se debe hacer clic en el botón de *Capturar Fondo*. Al dar click en el botón se capturará el fondo de la escena y se mostrará.

#Agregar imagen#

El fondo puede re-capturarse cuantas veces sea necesario.

### Intrusión

Para la intrusión, primero se define un área restringida con un polígono dibujado en la imagen. Cuando una persona ingrese a esa área se considera como intrusión.

Se utiliza la opción de *Agregar detector*. La aplicación capturará una imagen de la cámara, sobre la cual se debe dibujar un poligono dando clicks en la imagen. Una vez finalizado se da clic en *Finalizar polígono*.

#Agregar imagen#

Posteriormente se configura el porcenaje del cuerpo de la persona que debe ingresar al polígono para que se considere como intrusión. Además, el sistema permite establecer un rango de horas en que el detector está activo, de esta forma la detección puede realizarse solo cuando es de noche, o fuera de horario laboral. Por defecto se aplica la detección 24hrs.

#Agregar imagen#

### Armas

Cuando un arma se detecta en la escena se lanza el evento, sin embargo, para evitar falsos positivos se establece un mínimo de tiempo que el arma debe ser detectada antes de lanzar el evento. Este valor se configura al utilizar la opción de *Agregar detector*, bajo la opción de *Tiempo de detección*, donde usualmente se configura un tiempo corto.

<p align="center">
<img src="./images/add_weapon.png" width="800" alt="Agregar detector de armas">
</p>

## Comenzar la detección de eventos

El sistema cuenta con un servicio que se ejecuta en segundo plano para realizar la detección de los eventos. Este servicio puede iniciarse y detenerse desde la aplicación web.

Para iniciar la detección de eventos dirigirse a *Servicios* y buscar en la lista *Servicio de detección de eventos* y usar los botones de *Iniciar*, *Detener* o *Reiniciar*.

<p align="center">
<img src="./images/services.png" width="800" alt="Manejo de servicios">
</p>

Cada que se modifique alguna configuración del sistema, las cámaras o los detectores, es necesario reiniciar el servicio. Es recomendable apagar el servicio antes de hacer modificaciones, pues algunas opciones de los detectores requieren que el servicio esté desactivado para conectarse a las cámaras.

## Estructura del repositorio

Este repositorio contiene el código fuente de la aplicación, separado en diferentes paquetes (o directorios) para su fácil entendimiento y para poder realizar pruebas aisladas de cada componente. Además, contiene ejemplos de uso, evidencias, entre otras cosas.


* **YOLOX/:** Paquete para detección de objetos con el modelo YOLOX. Adaptado a Python 3.12 y al conjunto de datos de reconocimiento de armas. Consulte [YOLOX/README.md](./YOLOX/README.md) para más detalles. (Versión original: [Megii-BaseDetection/YOLOX](https://github.com/megvii-basedetection/yolox)).

* **deepsort-pip/:** Paquete para seguiiento de múltiples objetos en video. Adaptado a Python 3.12 y con modificaciones para integración con el proyecto. Consulte [deepsort-pip/README.md](./deepsort-pip/README.md) para más detalles. (Version original: [kadirnar/deepsort-pip](https://github.com/kadirnar/deepsort-pip)).

* **yolotracker/:** Paquete propio que incluye la lógica de la detección de eventos y combina *yolox* con *deepsort*. Contiene toda la lógica de detección de eventos. Consulte [yolotracker/README.md](./yolotracker/README.md) para más detalles.

* **video-surveillance-app/:** Directorio con el código fuente de la aplicación web y el servicio de detección de eventos en tiempo real. Además, contiene la lógica para obtener y procesar video en tiempo real de múltiples cámaras en simultáneo. Consulte [video-surveillance-app/README.md](./video-surveillance-app/README.md) para más detalles.

* **weights/:** Modelos en formato ONNX para la aplicación.

* **compose.yml, Dockerfile:** Archivos de creación de contenedores para instalación de la aplicación en *Modo apliación* (instalación rápida pero limitada).