//
//  OpenSwiftUIUIKitSubviews.h
//  OpenSwiftUI_SPI
//
//  Status: Complete
//  Audited for 6.5.4

#ifndef OpenSwiftUIUIKitSubviews_h
#define OpenSwiftUIUIKitSubviews_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

void _OpenSwiftUIUIKitAddSubview(id child, id parent, NSInteger index) OPENSWIFTUI_SWIFT_NAME(_UIKitAddSubview(child:parent:index:));

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* OpenSwiftUIUIKitSubviews_h */
