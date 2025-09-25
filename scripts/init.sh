#!/bin/bash

# Init Python environment 
uv sync # --active

# Init Node.js environment
NODE_MIRROR=https://registry.npmmirror.com/ # 设置为淘宝镜像
# NODE_MIRROR=https://npm.aliyun.com/         # 设置为阿里云镜像
# NODE_MIRROR=https://mirrors.cloud.tencent.com/npm/  # 设置为腾讯云镜像
# NODE_MIRROR=https://registry.npmjs.org/             # 恢复为官方源

npm config set registry ${NODE_MIRROR}
npm install -g pnpm
pnpm config set registry ${NODE_MIRROR}
# pnpm install