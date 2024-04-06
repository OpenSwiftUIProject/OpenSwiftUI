//
//  ProtocolDescriptor.c
//  COpenSwiftUI


#include "ProtocolDescriptor.h"

void _OpenSwiftUI_callVisitViewType(void *visitor_value,
                                    const void *view_type,
                                    const void *view_type2,
                                    const void *view_pwt);

OPENSWIFTUI_EXPORT
const void *$s11OpenSwiftUI4ViewMp;

const void *_OpenSwiftUI_viewProtocolDescriptor(void) {
    return &$s11OpenSwiftUI4ViewMp;
}

OPENSWIFTUI_EXPORT
const void *$s11OpenSwiftUI12ViewModifierMp;

const void *_OpenSwiftUI_viewModifierProtocolDescriptor(void) {
    return &$s11OpenSwiftUI12ViewModifierMp;
}

void _OpenSwiftUI_callVisitViewType1(void *visitor_value,
                                     const void *view_type,
                                     const void *view_pwt) {
    _OpenSwiftUI_callVisitViewType2(visitor_value, view_type, view_type, view_pwt);
}

OPENSWIFTUI_EXPORT
void _OpenSwiftUI_callVisitViewType2(void *visitor_value,
                                     const void *view_type,
                                     const void *view_type2,
                                     const void *view_pwt) {
    _OpenSwiftUI_callVisitViewType(visitor_value, view_type, view_type2, view_pwt);
}
