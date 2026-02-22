//
//  OpenSwiftUIUIKitSubviews.m
//  OpenSwiftUI_SPI
//
//  Status: Complete
//  Audited for 6.5.4

#include "OpenSwiftUIUIKitSubviews.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include "OpenSwiftUICoreViewFunctions.h"
#include <QuartzCore/QuartzCore.h>
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <UIKit/UIKit.h>
#else
#include <AppKit/AppKit.h>
#endif

// MARK: - UIKit Private API

OPENSWIFTUI_EXPORT CALayer * _Nullable CALayerGetSuperlayer(CALayer *layer);

@interface NSObject ()
- (void)_invalidateSubviewCache;
@end

// MARK: - UIKit Add Subview

void _OpenSwiftUIUIKitAddSubview(id child, id parent, NSInteger index) {
    CALayer *parentLayer = [parent layer];
    NSArray<CALayer *> *sublayers = [parentLayer sublayers];
    NSUInteger count = sublayers ? [sublayers count] : 0;
    CALayer *childLayer = [child layer];
    if (count > index && sublayers[index] == childLayer) {
        return;
    }
    if (CALayerGetSuperlayer(childLayer) != parentLayer) {
        [parent openswiftui_insertRenderedSubview:child atIndex:(NSInteger)index];
    } else {
        NSUInteger nextIndex = index + 1;
        if (nextIndex < count && sublayers[nextIndex] == childLayer) {
            childLayer = sublayers[index];
            assert(childLayer);
            index = count;
        }
        [parentLayer insertSublayer:childLayer atIndex:(unsigned)index];
        [parent _invalidateSubviewCache];
    }
}

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
