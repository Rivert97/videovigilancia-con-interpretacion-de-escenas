FROM pytorch/pytorch:2.10.0-cuda12.6-cudnn9-runtime

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /workspace

RUN apt-get update && apt-get install -y \
    build-essential \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    libx11-6 \
    libxcb1 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --break-system-packages --upgrade pip setuptools wheel

# Custom packages
COPY src/YOLOX /workspace/YOLOX
RUN pip install --break-system-packages --no-build-isolation -e /workspace/YOLOX

COPY src/deepsort-pip /workspace/deepsort-pip
RUN pip install --break-system-packages --no-build-isolation -e /workspace/deepsort-pip

COPY src/yolotracker /workspace/yolotracker
RUN pip install --break-system-packages --no-build-isolation -e /workspace/yolotracker

# App
COPY src/video-surveillance-app /workspace/video-surveillance-app

WORKDIR /workspace/video-surveillance-app

RUN pip install --break-system-packages -r requirements.txt

WORKDIR /workspace

COPY --chmod=0755 docker/entrypoint.sh ./entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["bash", "/workspace/entrypoint.sh"]