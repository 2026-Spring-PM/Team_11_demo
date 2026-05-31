#!/usr/bin/env bash
set -e

IMAGE="kjhstrange/volcanic_game_img:latest"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or was not found in PATH."
  exit 1
fi

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
