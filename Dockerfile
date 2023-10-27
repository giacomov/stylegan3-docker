FROM nvcr.io/nvidia/pytorch:21.08-py3

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN pip install imageio imageio-ffmpeg==0.4.4 pyspng==0.1.0

RUN useradd -u 1001 -m student

RUN chown --recursive student:student /home/student

USER student
WORKDIR /home/student

RUN git clone https://github.com/NVlabs/stylegan3.git

ENV PIP_NO_CACHE_DIR=false

# Run once to download the weigths. Note that this command
# will actually fail because there is no available GPU drivers
# at build time. However, the weights are downloaded first so 
# that's ok
RUN cd stylegan3 \ 
    && python gen_images.py --outdir=out --trunc=1 --seeds=2 \
       --network=https://api.ngc.nvidia.com/v2/models/nvidia/research/stylegan3/versions/1/files/stylegan3-r-afhqv2-512x512.pkl \
    || echo "done"
