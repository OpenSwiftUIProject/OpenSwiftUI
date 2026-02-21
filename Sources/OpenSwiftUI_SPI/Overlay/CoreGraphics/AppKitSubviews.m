//
//  AppKitSubviews.m
//  OpenSwiftUI_SPI
//
//  Status: Complete
//  Audited for 6.5.4

#include "AppKitSubviews.h"
#include "UIKitSubviews.h"

#if OPENSWIFTUI_TARGET_OS_OSX

#include <AppKit/AppKit.h>

// MARK: - NSObject (OpenSwiftUICore_Additions)

@implementation NSObject (OpenSwiftUICore_Additions)
- (void)openswiftui_insertRenderedSubview:(id)subview atIndex:(NSInteger)index {
    [(NSView *)self addSubview:subview positioned:NSWindowAbove relativeTo:nil];
}
- (void)openswiftui_addRenderedSubview:(id)subview positioned:(NSInteger)place relativeTo:(id _Nullable)otherView {
    [(NSView *)self addSubview:subview positioned:place relativeTo:otherView];
}
@end

// MARK: - AppKit Add Subview

void _OpenSwiftUIAppKitAddSubview(NSView *child, NSView *parent, NSUInteger index) {
    NSArray<NSView *> *subviews = [parent subviews];
    NSUInteger count = [subviews count];
    // Fast path: child is already at the correct position
    if (count > index && subviews[index] == child) {
        return;
    }
    if ([child superview] == parent) {
        // Child is already a subview but at wrong position
        NSUInteger nextIndex = index + 1;
        if (nextIndex < count && subviews[nextIndex] == child) {
            // Child is at index+1: reposition the view at index to the end
            child = subviews[index];
            index = count;
        }
    }
    // Wrap in zero-duration animation context to suppress animations
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.0];
    if (index == count) {
        // Append at end: positioned above, no relative view
        [parent openswiftui_addRenderedSubview:child positioned:NSWindowAbove relativeTo:nil];
    } else if (index == 0) {
        // Insert at beginning: positioned below, no relative view
        [parent openswiftui_addRenderedSubview:child positioned:NSWindowBelow relativeTo:nil];
    } else {
        // Insert before the view currently at index
        NSView *relativeTo = subviews[index];
        [parent openswiftui_addRenderedSubview:child positioned:NSWindowBelow relativeTo:relativeTo];
    }
    [NSAnimationContext endGrouping];
}

#endif /* OPENSWIFTUI_TARGET_OS_OSX */
