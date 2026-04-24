set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CMAKE_SYSTEM_NAME Linux)

# spdlog 及其直接依赖库使用动态链接，确保整个进程只有一份 spdlog 实例，
# 避免多个 .so 各自静态链接 spdlog 导致的 ODR 冲突（free(): invalid pointer）
if(PORT MATCHES "^(spdlog|fmt)$")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

