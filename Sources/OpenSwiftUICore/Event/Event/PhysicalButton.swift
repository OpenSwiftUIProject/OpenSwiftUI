//
//  PhysicalButton.swift
//  OpenSwiftUICore

#if !OPENSWIFTUI_LVGL || OPENSWIFTUI_PLATFORM_FOLOTOY
/// A logical physical button, independent of its platform's GPIO or key codes.
///
/// Shared by the standard event model and the FoloToy LVGL input adapter.
/// AI Passport supplies `upArrow`, `downArrow` and `select`.
public enum PhysicalButton: Hashable {
    case upArrow
    case downArrow
    case leftArrow
    case rightArrow
    case select
    case menu
    case playPause
    case pageUp
    case pageDown
    case back
}
#endif
