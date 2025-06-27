//
//  ProtocolDescriptor.c
//  OpenSwiftUI_SPI

#include "ProtocolDescriptor.h"

void _OpenSwiftUI_callVisitViewType(void *visitor_value,
                                    const void *view_type,
                                    const void *view_type2,
                                    const void *view_pwt);

OPENSWIFTUI_EXPORT
const void *$s15OpenSwiftUICore4ViewMp;

const void *_OpenSwiftUI_viewProtocolDescriptor(void) {
    return &$s15OpenSwiftUICore4ViewMp;
}

OPENSWIFTUI_EXPORT
const void *$s15OpenSwiftUICore12ViewModifierMp;

const void *_OpenSwiftUI_viewModifierProtocolDescriptor(void) {
    return &$s15OpenSwiftUICore12ViewModifierMp;
}

OPENSWIFTUI_EXPORT
const void *$s15OpenSwiftUICore7GestureMp;

const void *_OpenSwiftUI_gestureProtocolDescriptor(void) {
    return &$s15OpenSwiftUICore7GestureMp;
}

OPENSWIFTUI_EXPORT
const void *$s15OpenSwiftUICore15GestureModifierMp;

const void *_OpenSwiftUI_gestureModifierProtocolDescriptor(void) {
    return &$s15OpenSwiftUICore15GestureModifierMp;
}
