//
//  NSButton_Private.h
//  OpenSwiftUI_SPI
//
//  Audited for macOS 15.5

#ifndef NSButton_Private_h
#define NSButton_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<AppKit/AppKit.h>)
#include <AppKit/AppKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSControl (OpenSwiftUI_SPI)
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(unsigned long long)events;
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(unsigned long long)events;
@end

@interface NSButton (OpenSwiftUI_SPI)
@property (nullable, strong) NSView *contentView;
@property NSInteger toolbarAppearance;
- (int)effectiveVibrancyBlendModeForAppearance:(NSAppearance *)appearance;
- (void)_setUsesCautionaryAppearanceWhenActionIsDestructive:(BOOL)destructive;
- (BOOL)_getIntrinsicArtworkSize:(CGSize *)size
            alignmentRectInsets:(NSEdgeInsets *)alignmentInsets
             idealContentInsets:(NSEdgeInsets *)contentInsets
               maxContentInsets:(nullable NSEdgeInsets *)maxContentInsets;
@end

OPENSWIFTUI_ASSUME_NONNULL_END
#endif

#endif /* NSButton_Private_h */
