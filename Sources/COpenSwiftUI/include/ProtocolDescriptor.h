//
//  ProtocolDescriptor_h
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

#ifndef ProtocolDescriptor_h
#define ProtocolDescriptor_h

#include "OpenSwiftUIBase.h"

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
const void *_OpenSwiftUI_viewProtocolDescriptor(void);

OPENSWIFTUI_EXPORT
const void *_OpenSwiftUI_viewModifierProtocolDescriptor(void);

OPENSWIFTUI_EXPORT
void _OpenSwiftUI_callVisitViewType1(void *visitor_value,
                                     const void *view_type,
                                     const void *view_pwt);

OPENSWIFTUI_EXPORT
void _OpenSwiftUI_callVisitViewType2(void *visitor_value,
                                     const void *view_type,
                                     const void *view_type2,
                                     const void *view_pwt);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* ProtocolDescriptor_h */
