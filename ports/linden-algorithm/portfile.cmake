# 源码位于同仓库的 thirdparty/linden_algorithm 目录（git submodule）
# commit: d4ef4cb4c776b1072f3e01c352d92e1bcc0627a4
# 从 ports/linden-algorithm/ 向上三级即可到达 thirdparty/
set(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../linden_algorithm")

# 注意：zbar 是系统依赖，需提前安装：
#   sudo apt-get install libzbar-dev

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cuda WITH_CUDA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SHARED_LIBS=ON
        # -Wl,-Bsymbolic: required when statically linking opencv (which embeds ffmpeg) into a shared library.
        # ffmpeg x86 asm uses R_X86_64_PC32 relocations which are rejected unless symbols are bound at link time.
        # See: https://ffmpeg.org/platform.html#Advanced-linking-configuration
        "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-Bsymbolic"
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

# 将 cmake 配置文件从 lib/cmake/linden_algorithm 移动到 share/linden_algorithm（vcpkg 惯例）
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "linden_algorithm"
    CONFIG_PATH "lib/cmake/linden_algorithm"
)

# 清理 debug/include（头文件只安装一份）
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
