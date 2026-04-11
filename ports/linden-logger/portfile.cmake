# linden-logger 是 header-only 库，无需构建 debug 版本
set(VCPKG_BUILD_TYPE release)

# 源码位于同仓库的 thirdparty/linden_logger 目录
# 从 ports/linden-logger/ 向上三级即可到达 thirdparty/
set(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../linden_logger")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_NAMESPACE=ON
)

vcpkg_cmake_install()

# 将 cmake 配置文件从 lib/cmake/linden_logger 移动到 share/linden_logger（vcpkg 惯例）
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "linden_logger"
    CONFIG_PATH "lib/cmake/linden_logger"
)

# header-only 库清理多余目录
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
