# 源码位于同仓库的 thirdparty/cutie_cpp 目录（本地子模块）
# 从 ports/cutie-cpp/ 向上三级即可到达 thirdparty/
set(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../cutie_cpp")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tensorrt ENABLE_TENSORRT
)

# ── CUDA / TensorRT 路径（仅 tensorrt feature 时真正生效）──────────────────────
# 优先读取环境变量，回退到常用默认路径
set(_CUTIE_CUDA_DIR "/usr/local/cuda")
set(_CUTIE_TENSORRT_DIR "/usr/local/tensorrt")
if(DEFINED ENV{CUDA_DIR})
    set(_CUTIE_CUDA_DIR "$ENV{CUDA_DIR}")
endif()
if(DEFINED ENV{TENSORRT_DIR})
    set(_CUTIE_TENSORRT_DIR "$ENV{TENSORRT_DIR}")
endif()
# ─────────────────────────────────────────────────────────────────────────────

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DDOWNLOAD_MODELS=OFF
        -DENABLE_ONNXRUNTIME=ON
        # TensorRT 路径声明（即使不启用 TRT 也无副作用）
        -DCUDA_DIR=${_CUTIE_CUDA_DIR}
        -DTensorRT_DIR=${_CUTIE_TENSORRT_DIR}
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CUDA_DIR
        TensorRT_DIR
)

vcpkg_cmake_install()

# cutieConfig.cmake 安装在 lib/cmake/cutie/（三级深度，与 cutie_cpp CMakeLists.txt 中的
# INSTALL_DESTINATION 一致），vcpkg_cmake_config_fixup 将其移至 share/cutie/
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "cutie"
    CONFIG_PATH "lib/cmake/cutie"
)

# 清理 debug/include（头文件只安装一份）
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
