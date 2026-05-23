FROM pytorch/pytorch:2.10.0-cuda12.6-cudnn9-runtime

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /workspace

RUN apt-get update && apt-get install -y \
    build-essential \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --break-system-packages --upgrade pip setuptools wheel

# Custom packages
COPY YOLOX /workspace/YOLOX
COPY deepsort-pip /workspace/deepsort-pip
COPY yolotracker /workspace/yolotracker

RUN pip install --break-system-packages --no-build-isolation -e /workspace/YOLOX
RUN pip install --break-system-packages --no-build-isolation -e /workspace/deepsort-pip
RUN pip install --break-system-packages --no-build-isolation -e /workspace/yolotracker

# App
COPY video-surveillance-app /workspace/video-surveillance-app

WORKDIR /workspace/video-surveillance-app

RUN pip install --break-system-packages -r requirements.txt

WORKDIR /workspace

COPY --chmod=0755 entrypoint ./entrypoint

EXPOSE 8000

ENTRYPOINT ["bash", "/workspace/entrypoint"]