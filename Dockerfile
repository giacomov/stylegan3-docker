#FROM nvcr.io/nvidia/pytorch:21.08-py3
FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PIP_NO_CACHE_DIR=false

RUN apt update && apt install -y git g++ && apt-get clean &&  rm -rf /var/lib/apt/lists/*
COPY environment.yml .
RUN conda env update -n base -f environment.yml && conda clean --all -y

RUN useradd -u 1001 -m student

RUN chown --recursive student:student /home/student

USER student
WORKDIR /home/student

RUN git clone https://github.com/NVlabs/stylegan3.git
COPY --chown=student:student cache /home/student/.cache

# Run once to download the weigths. Note that this command
# will actually fail because there is no available GPU drivers
# at build time. However, the weights are downloaded first so 
# that's ok
RUN cd stylegan3 \ 
    && python gen_images.py --outdir=out --trunc=1 --seeds=2 \
       --network=https://api.ngc.nvidia.com/v2/models/nvidia/research/stylegan3/versions/1/files/stylegan3-r-afhqv2-512x512.pkl \
    || echo "done"

COPY --chown=student:student custom_ops.py /home/student/stylegan3/torch_utils/custom_ops.py

