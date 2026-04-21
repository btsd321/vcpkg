# =============================================================================
# 自定义 triplet：x64-linux-pic
# 在 vcpkg 默认 x64-linux 基础上，强制所有目标（含 CUDA）走 -fPIC，
# 修复 pcl_gpu_octree 等 CUDA 静态库被下游共享库链接时报：
#   relocation R_X86_64_PC32 against symbol can not be used when making a shared object
#
# 引用方式：通过工程根 vcpkg-configuration.json 的 overlay-triplets 字段加载，
# 或环境变量 VCPKG_OVERLAY_TRIPLETS 指向本目录（见 scripts/env/.usrconfig）。
#
# 参考：
#   https://learn.microsoft.com/vcpkg/users/triplets
#   https://learn.microsoft.com/vcpkg/users/buildsystems/manifest-mode#vcpkg-configurationjson
# =============================================================================

set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Linux)

# 主机端 C/C++ 编译器 flags
set(VCPKG_C_FLAGS "-fPIC")
set(VCPKG_CXX_FLAGS "-fPIC")

# CMake 全局 PIC（影响所有 add_library）
list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
)

# CUDA：把 -fPIC 透传给 nvcc 内部主机编译器
# CMake CUDA 默认不会把 host PIC flag 传给 nvcc，需显式声明
set(VCPKG_ENV_PASSTHROUGH "CUDAFLAGS")
list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS
    "-DCMAKE_CUDA_FLAGS=-Xcompiler=-fPIC"
)
