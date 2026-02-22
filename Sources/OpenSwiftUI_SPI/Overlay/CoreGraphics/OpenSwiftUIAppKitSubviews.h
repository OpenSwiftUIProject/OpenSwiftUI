//
//  OpenSwiftUIAppKitSubviews.h
//  OpenSwiftUI_SPI
//
//  Status: Complete
//  Audited for 6.5.4

#ifndef OpenSwiftUIAppKitSubviews_h
#define OpenSwiftUIAppKitSubviews_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

void _OpenSwiftUIAppKitAddSubview(id child, id parent, NSUInteger index) OPENSWIFTUI_SWIFT_NAME(_AppKitAddSubview(child:parent:index:));

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* OpenSwiftUIAppKitSubviews_h */
