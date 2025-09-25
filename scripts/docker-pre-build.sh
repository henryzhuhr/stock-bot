#!/bin/bash
# 预先构建项目镜像的脚本，加快 docker compose up 的速度

IMAGE_TAG=0.0.1

UV_IMAGETAG=0.8.15
NODE_IMAGETAG=24
MIRRORS_URL=mirrors.ustc.edu.cn
CLEAN_APT_CACHE=1

# 镜像列表（格式：镜像名:标签）
IMAGES=(
  "ubuntu:24.04"
  "ghcr.io/astral-sh/uv:${UV_IMAGETAG}"
  "node:${NODE_IMAGETAG}"
  "mysql:9"
  "redis:8"
)

for IMAGE in "${IMAGES[@]}"; do
  NAME=$(echo "${IMAGE}" | cut -d: -f1)
  TAG=$(echo "${IMAGE}" | cut -d: -f2-)
  if ! docker images | grep -q "^${NAME}[[:space:]]\+${TAG}[[:space:]]"; then
    echo "pull image: ${IMAGE}"
    docker pull "${IMAGE}" || {
      echo "failed to pull image ${IMAGE}, aborting!";
      exit 1;
    }
  else
    echo "found ${IMAGE}, skip docker pull."
  fi
done

# 代理设置 - 自动检测系统代理
HTTP_PROXY=${HTTP_PROXY:-${http_proxy}}
HTTPS_PROXY=${HTTPS_PROXY:-${https_proxy}}
NO_PROXY=${NO_PROXY:-${no_proxy}}

# 构建时的参数，拆开写 "--build-arg" 和参数是为了避免解析错误
BUILD_ARGS=(
  "--build-arg"
  "UV_IMAGETAG=${UV_IMAGETAG}"
  "--build-arg"
  "NODE_IMAGETAG=${NODE_IMAGETAG}"
  "--build-arg"
  "MIRRORS_URL=${MIRRORS_URL}"
  "--build-arg"
  "CLEAN_APT_CACHE=${CLEAN_APT_CACHE}"
)

# 如果检测到代理设置，则添加到构建参数中
if [ -n "${HTTP_PROXY}" ]; then
  BUILD_ARGS+=("--build-arg" "HTTP_PROXY=${HTTP_PROXY}")
  BUILD_ARGS+=("--build-arg" "http_proxy=${HTTP_PROXY}")
  echo "build with HTTP proxy: ${HTTP_PROXY}"
fi
if [ -n "${HTTPS_PROXY}" ]; then
  BUILD_ARGS+=("--build-arg" "HTTPS_PROXY=${HTTPS_PROXY}")
  BUILD_ARGS+=("--build-arg" "https_proxy=${HTTPS_PROXY}")
  echo "build with HTTPS proxy: ${HTTPS_PROXY}"
fi
if [ -n "${NO_PROXY}" ]; then
  BUILD_ARGS+=("--build-arg" "NO_PROXY=${NO_PROXY}")
  BUILD_ARGS+=("--build-arg" "no_proxy=${NO_PROXY}")
  echo "Proxy Exclusion List: ${NO_PROXY}"
fi

docker build -t stock-bot:${IMAGE_TAG} \
  -f dockerfiles/Dockerfile \
  "${BUILD_ARGS[@]}" \
  --no-cache .