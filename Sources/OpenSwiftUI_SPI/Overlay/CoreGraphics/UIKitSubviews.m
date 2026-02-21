//
//  UIKitSubviews.m
//  OpenSwiftUI_SPI
//
//  Status: Complete
//  Audited for 6.5.4

#include "UIKitSubviews.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

#include <UIKit/UIKit.h>

// MARK: - UIKit Private API

OPENSWIFTUI_EXPORT CALayer * _Nullable CALayerGetSuperlayer(CALayer *layer);

@interface UIView (UIKitSubviews)
- (void)_invalidateSubviewCache;
@end

// MARK: - NSObject (OpenSwiftUICore_Additions)

@implementation NSObject (OpenSwiftUICore_Additions)
- (void)openswiftui_insertRenderedSubview:(id)subview atIndex:(NSInteger)index {
    [(UIView *)self insertSubview:subview atIndex:index];
}
@end

// MARK: - UIKit Add Subview

void _UIKitAddSubview(UIView *child, UIView *parent, NSInteger index) {
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
        NSUInteger targetIndex;
        if (nextIndex < count && sublayers[nextIndex] == childLayer) {
            childLayer = sublayers[index];
            assert(childLayer);
            targetIndex = count;
        } else {
            targetIndex = index;
        }
        [parentLayer insertSublayer:childLayer atIndex:(unsigned)targetIndex];
        [parent _invalidateSubviewCache];
    }
}

#endif
