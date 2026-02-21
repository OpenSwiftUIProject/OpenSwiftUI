//
//  UIKitSubviews.h
//  OpenSwiftUI_SPI
//
//  Status: Complete
//  Audited for 6.5.4

#ifndef UIKitSubviews_h
#define UIKitSubviews_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

#include <QuartzCore/QuartzCore.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSObject (OpenSwiftUICore_Additions)
- (void)openswiftui_insertRenderedSubview:(id)subview atIndex:(NSInteger)index;
@end

void _UIKitAddSubview(id child, id parent, NSInteger index);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* UIKitSubviews_h */
