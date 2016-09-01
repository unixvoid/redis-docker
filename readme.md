# unixvoid/redis
This project is intended to be a small redis image for production use.  
To build the image, we actually take the binary and a single shared object from alpine linux.

- to build this image without building (pulls root filesystem from binder), issue the following
  - `make bootstrap`
  - `make docker`
- to build this image, building the filesystem from scratch, issue the following
  - `make binary rootfs`
  - `make docker`
