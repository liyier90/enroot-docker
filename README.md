# enroot-docker

## Build

```
docker buildx build --tag enroot:2204 .
```

## Run

```
docker run \
    -it \
    --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --mount type=bind,source=</host/path/to/workspace,target=/workspace \
    enroot:2204 \
        -o alpine.sqsh \
        dockerd://alpine:latest
```
