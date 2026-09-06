# Explicit static-display profile: the regular SwiftPM graph is not embedded.
function(openswiftui_link_embedded target)
    get_filename_component(osui_root "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/.." ABSOLUTE)
    set(osui_output "${CMAKE_CURRENT_BINARY_DIR}/openswiftui")
    file(STRINGS "${osui_root}/Embedded/sources.txt" osui_relative_sources)
    set(osui_sources)
    foreach(source IN LISTS osui_relative_sources)
        list(APPEND osui_sources "${osui_root}/${source}")
    endforeach()
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${osui_root}/Embedded/sources.txt")
    add_custom_command(
        OUTPUT "${osui_output}/libOpenSwiftUI.a" "${osui_output}/OpenSwiftUI.swiftmodule"
        COMMAND "${PYTHON}" "${osui_root}/Scripts/build_embedded.py"
            --target riscv32 --output "${osui_output}" --swiftc "${CMAKE_Swift_COMPILER}"
        DEPENDS ${osui_sources} "${osui_root}/Embedded/sources.txt" "${osui_root}/Scripts/build_embedded.py"
        COMMENT "Building OpenSwiftUI Embedded display profile"
        VERBATIM
    )
    add_custom_target(openswiftui_embedded_build
        DEPENDS "${osui_output}/libOpenSwiftUI.a" "${osui_output}/OpenSwiftUI.swiftmodule")
    add_library(OpenSwiftUIEmbedded STATIC IMPORTED GLOBAL)
    set_target_properties(OpenSwiftUIEmbedded PROPERTIES
        IMPORTED_LOCATION "${osui_output}/libOpenSwiftUI.a")
    add_dependencies(OpenSwiftUIEmbedded openswiftui_embedded_build)
    add_dependencies(${target} openswiftui_embedded_build)
    target_compile_options(${target} PRIVATE "$<$<COMPILE_LANGUAGE:Swift>:SHELL:-I ${osui_output}>")
    target_link_libraries(${target} PRIVATE OpenSwiftUIEmbedded)
endfunction()
