# 源码位于同仓库的 thirdparty/linden_bsp 目录（git submodule）
# commit: c3ecc91c8e74971653492bff1a5f8b99a107c720
# 从 ports/linden-bsp/ 向上三级即可到达 thirdparty/
set(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../linden_bsp")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

# 将 cmake 配置文件从 lib/cmake/linden_bsp 移动到 share/linden_bsp（vcpkg 惯例）
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "linden_bsp"
    CONFIG_PATH "lib/cmake/linden_bsp"
)

# 清理 debug/include（头文件只安装一份）
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
