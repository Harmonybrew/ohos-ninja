#!/bin/sh
set -e

# 当前工作目录。拼接绝对路径的时候需要用到这个值。
WORKDIR=$(pwd)

# 如果存在旧的目录和文件，就清理掉
rm -rf *.tar.gz \
    ninja-1.13.1 \
    ohos-sdk \
    ninja-1.13.1-ohos-arm64

# 准备 ohos-sdk
mkdir ohos-sdk
curl -L -O https://repo.huaweicloud.com/openharmony/os/6.0-Release/ohos-sdk-windows_linux-public.tar.gz
tar -zxf ohos-sdk-windows_linux-public.tar.gz -C ohos-sdk
cd ohos-sdk/linux
unzip -q native-*.zip
cd ../..

# 编译 ninja
curl -L https://github.com/ninja-build/ninja/archive/refs/tags/v1.13.1.tar.gz -o ninja-1.13.1.tar.gz
tar -zxf ninja-1.13.1.tar.gz
cd ninja-1.13.1
mkdir build
cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${WORKDIR}/ninja-1.13.1-ohos-arm64 \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
    -DCMAKE_CXX_COMPILER=${WORKDIR}/ohos-sdk/linux/native/llvm/bin/aarch64-unknown-linux-ohos-clang++ \
    -DCMAKE_CXX_COMPILER_AR=${WORKDIR}/ohos-sdk/linux/native/llvm/bin/llvm-ar \
    -DCMAKE_CXX_COMPILER_RANLIB=${WORKDIR}/ohos-sdk/linux/native/llvm/bin/llvm-ranlib \
    -DBUILD_TESTING=OFF
make -j$(nproc)
make install
cd ../..

# 履行开源义务，将 license 随制品一起发布
cp ninja-1.13.1/COPYING ninja-1.13.1-ohos-arm64/

# 打包最终产物
tar -zcf ninja-1.13.1-ohos-arm64.tar.gz ninja-1.13.1-ohos-arm64
