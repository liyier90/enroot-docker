# enroot-docker

## Build

```
docker buildx build --tag enroot:3.5.0-bookworm .
```

## Run

```
docker run \
    --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --mount type=bind,source=</host/path/to/workspace>,target=/workspace \
    enroot:3.5.0-bookworm \
        -o alpine.sqsh \
        dockerd://alpine:latest
```

## Running without installing

TODO: Figure out how to specify `ENROOT_SQUASH_OPTIONS`.

1. Install docker
2. Install `jq` and `squashfs-tools`
3. Clone `enroot` and update variables.

```
ENROOT_VERSION=3.5.0
ENROOT_BIN_DIR=/opt/enroot
git clone \
    --depth 1 \
    --branch v${ENROOT_VERSION} \
    https://github.com/NVIDIA/enroot.git \
    ${ENROOT_BIN_DIR}
sed -e "s|@sysconfdir|${ENROOT_BIN_DIR}/etc|" \
    -e "s|@libdir@|${ENROOT_BIN_DIR}/src|" \
    -e "s|@version@|${ENROOT_VERSION}|" \
    ${ENROOT_BIN_DIR}/enroot.in \
    > ${ENROOT_BIN_DIR}/enroot
mkdir -p "${ENROOT_BIN_DIR}/etc"
```

4. Run `enroot_import.sh`

```
./enroot_import.sh -o alpine.sqsh dockerd://alpine:latest
```
