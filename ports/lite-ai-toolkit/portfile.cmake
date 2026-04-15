# 源码位于同仓库的 thirdparty/lite.ai.toolkit 目录（本地子模块）
# 从 ports/lite-ai-toolkit/ 向上三级即可到达 thirdparty/
set(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../lite.ai.toolkit")

# 注意：lite.ai.toolkit 的 CMakeLists.txt 无条件调用 enable_language(CUDA)，
# 因此无论是否启用 tensorrt feature，系统均需安装 CUDA Toolkit（nvcc 需可寻址）。

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tensorrt ENABLE_TENSORRT
)

# ── CUDA / TensorRT 路径（仅 tensorrt feature 时真正生效）────────────────────
# 优先读取环境变量，回退到常用默认路径。
# 使用方式：export CUDA_DIR=... && export TENSORRT_DIR=... 后再执行 vcpkg install
set(_LITE_CUDA_DIR "/usr/local/cuda")
set(_LITE_TENSORRT_DIR "/usr/local/tensorrt")
if(DEFINED ENV{CUDA_DIR})
    set(_LITE_CUDA_DIR "$ENV{CUDA_DIR}")
elseif(DEFINED ENV{CUDA_HOME})
    set(_LITE_CUDA_DIR "$ENV{CUDA_HOME}")
endif()
if(DEFINED ENV{TENSORRT_DIR})
    set(_LITE_TENSORRT_DIR "$ENV{TENSORRT_DIR}")
elseif(DEFINED ENV{TENSORRT_HOME})
    set(_LITE_TENSORRT_DIR "$ENV{TENSORRT_HOME}")
endif()
# ─────────────────────────────────────────────────────────────────────────────

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TEST=OFF
        -DENABLE_ONNXRUNTIME=ON
        # onnxruntime：使用 vcpkg 已安装版本（system prefix style）
        # 头文件位于 ${CURRENT_INSTALLED_DIR}/include/onnxruntime/，
        # lite.ai.toolkit/cmake/onnxruntime.cmake 会自动识别此布局。
        -DOnnxRuntime_DIR=${CURRENT_INSTALLED_DIR}
        # opencv：通过 vcpkg toolchain 注入的 CMAKE_PREFIX_PATH 自动 find_package，
        # lite.ai.toolkit/cmake/opencv.cmake 优先走 find_package(OpenCV QUIET)。
        # 无需额外传参。
        #
        # CUDA_DIR / TensorRT_DIR 声明为 CMake Cache 变量（即使不启用 TRT 也无副作用）
        -DCUDA_DIR=${_LITE_CUDA_DIR}
        -DTensorRT_DIR=${_LITE_TENSORRT_DIR}
        # -Wl,-Bsymbolic: required when statically linking ffmpeg into a shared library.
        # ffmpeg x86 asm uses R_X86_64_PC32 relocations which are rejected by the linker
        # unless symbols are bound within the shared library at link time.
        # See: https://ffmpeg.org/platform.html#Advanced-linking-configuration
        "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-Bsymbolic"
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        CUDA_DIR
        TensorRT_DIR
)

vcpkg_cmake_install()

# lite.ai.toolkit-config.cmake include 的 lite.ai.toolkit.cmake 中通过
# get_filename_component("../../..") 从 lib/cmake/lite.ai.toolkit/ 推导安装前缀。
# vcpkg_cmake_config_fixup 会将 cmake 文件从 lib/cmake/ 移到 share/（2 层深度），
# 所以需要先 fixup，再修补路径推导从 3 层改为 2 层。
vcpkg_cmake_config_fixup(PACKAGE_NAME lite.ai.toolkit CONFIG_PATH lib/cmake/lite.ai.toolkit)

# 修补路径推导：vcpkg_cmake_config_fixup 将 cmake 文件从 lib/cmake/lite.ai.toolkit/（3层）
# 移至 share/lite.ai.toolkit/（2层），因此需将路径推导从 ../../.. 改为 ../..。
# 注意：变量名必须与 lite.ai.toolkit.cmake.in 模板中的实际名称一致。
vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/lite.ai.toolkit/lite.ai.toolkit.cmake"
    "get_filename_component(_LITE_AI_PREFIX \"\${_LITE_AI_CMAKE_DIR}/../../..\" ABSOLUTE)"
    "get_filename_component(_LITE_AI_PREFIX \"\${_LITE_AI_CMAKE_DIR}/../..\" ABSOLUTE)"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/lite/bin"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
