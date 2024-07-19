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
