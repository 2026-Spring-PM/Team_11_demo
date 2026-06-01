#!/usr/bin/env bash
set -e
IMAGE="kjhstrange/volcanic_game_img:latest"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or was not found in PATH."
  exit 1
fi

# Detect OS
OS="$(uname -s)"

# macOS handling
if [ "$OS" = "Darwin" ]; then
  docker pull --platform linux/amd64 yoonjimin/volcanic_vnc:latest
  docker run -d \
    --platform linux/amd64 \
    -p 6080:6080 \
    yoonjimin/volcanic_vnc:latest
  sleep 5
  open "http://localhost:6080/vnc.html?resize=scale&autoconnect=1"
  exit 0
fi

# Linux / WSL handling (기존 코드)
if [ -z "${DISPLAY:-}" ]; then
  echo "DISPLAY is empty."
  echo "On Windows, run this script from a WSL2 + WSLg terminal."
  exit 1
fi

docker pull "$IMAGE"

DOCKER_ARGS=(
  -it
  --rm
  -e "DISPLAY=${DISPLAY}"
)

if [ -n "${WAYLAND_DISPLAY:-}" ]; then
  DOCKER_ARGS+=(-e "WAYLAND_DISPLAY=${WAYLAND_DISPLAY}")
fi

if [ -n "${XDG_RUNTIME_DIR:-}" ]; then
  DOCKER_ARGS+=(-e "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}")
fi

if [ -d /tmp/.X11-unix ]; then
  DOCKER_ARGS+=(-v /tmp/.X11-unix:/tmp/.X11-unix)
fi

if [ -d /mnt/wslg ]; then
  DOCKER_ARGS+=(-v /mnt/wslg:/mnt/wslg)
fi

docker run "${DOCKER_ARGS[@]}" "$IMAGE"