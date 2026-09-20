//
//  EmbeddedConfiguration.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_PLATFORM_FOLOTOY && !OPENSWIFTUI_LVGL
#error("The FoloToy input adapter requires OPENSWIFTUI_LVGL")
#endif
