//
//  ProtocolDescriptor.c
//  COpenSwiftUICore

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
