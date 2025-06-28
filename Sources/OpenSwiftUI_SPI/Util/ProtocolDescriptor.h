//
//  ProtocolDescriptor_h
//  OpenSwiftUI_SPI

#ifndef ProtocolDescriptor_h
#define ProtocolDescriptor_h

#include "OpenSwiftUIBase.h"

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
const void *_OpenSwiftUI_viewProtocolDescriptor(void);

OPENSWIFTUI_EXPORT
const void *_OpenSwiftUI_viewModifierProtocolDescriptor(void);

OPENSWIFTUI_EXPORT
const void *_OpenSwiftUI_gestureProtocolDescriptor(void);

OPENSWIFTUI_EXPORT
const void *_OpenSwiftUI_gestureModifierProtocolDescriptor(void);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* ProtocolDescriptor_h */
