//
//  AppKitSubviews.h
//  OpenSwiftUI_SPI
//
//  Status: Complete
//  Audited for 6.5.4

#ifndef AppKitSubviews_h
#define AppKitSubviews_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_OSX

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSObject (OpenSwiftUICore_Additions)
- (void)openswiftui_insertRenderedSubview:(id)subview atIndex:(NSInteger)index;
- (void)openswiftui_addRenderedSubview:(id)subview positioned:(NSInteger)place relativeTo:(id _Nullable)otherView;
@end

void _OpenSwiftUIAppKitAddSubview(id child, id parent, NSUInteger index);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_OSX */

#endif /* AppKitSubviews_h */
