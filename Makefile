FS_ENDPOINT=https://cryo.unixvoid.com/bin/redis/filesystem/rootfs.tar.gz
IMAGE_NAME=docker.io/unixvoid/redis
DOCKER_OPTIONS='--no-cache'
DOCKER_PREFIX=sudo
GIT_HASH=$(shell git rev-parse HEAD | head -c 10)
CURRENT_DIR=$(shell pwd)

bootstrap:
	mkdir -p stage.tmp/
	wget -O stage.tmp/rootfs.tar.gz $(FS_ENDPOINT)

binary:
	mkdir -p bin/
	mkdir -p stage.tmp/
	cp deps/Dockerfile.stage0 stage.tmp/Dockerfile
	cp deps/build.sh stage.tmp/
	cd stage.tmp/ && \
		./build.sh
	mv stage.tmp/redis-server bin/
	mv stage.tmp/ld-musl-x86_64.so.1 bin/

rootfs:
	$(MAKE) binary
	rm -rf stage.tmp/
	mkdir -p stage.tmp/rootfs/bin/
	mkdir -p stage.tmp/rootfs/etc/
	mkdir -p stage.tmp/rootfs/lib/
	mkdir -p stage.tmp/rootfs/redisbackup/
	cp deps/group stage.tmp/rootfs/etc/
	cp deps/passwd stage.tmp/rootfs/etc/
	cp deps/resolv.conf stage.tmp/rootfs/etc/
	touch stage.tmp/rootfs/bin/false
	cp bin/redis-server stage.tmp/rootfs/bin/
	cp bin/ld-musl-x86_64.so.1 stage.tmp/rootfs/lib
	cd stage.tmp/ && \
		tar -czf rootfs.tar.gz rootfs
	mv stage.tmp/rootfs.tar.gz .

docker:
	mkdir -p stage.tmp/
	cp deps/redis.conf stage.tmp/
	cp deps/Dockerfile stage.tmp/
	#$(MAKE) bootstrap
	cp rootfs.tar.gz stage.tmp/
	cd stage.tmp/ && \
		$(DOCKER_PREFIX) docker build $(DOCKER_OPTIONS) -t $(IMAGE_NAME) .

clean:
	rm -rf stage.tmp/
	rm -rf bin/
	#rm -f rootfs.tar.gz
