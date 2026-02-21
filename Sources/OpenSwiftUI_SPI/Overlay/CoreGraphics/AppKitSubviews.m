//
//  AppKitSubviews.m
//  OpenSwiftUI_SPI
//
//  Status: Complete
//  Audited for 6.5.4

#include "AppKitSubviews.h"
#include "CoreViewFunctions.h"
#include <QuartzCore/QuartzCore.h>

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <UIKit/UIKit.h>
#else
#include <AppKit/AppKit.h>
#endif

// MARK: - AppKit Add Subview

static Class nsAnimationContextClass;
static dispatch_once_t nsAnimationContextOnce;

@interface NSObject (NSAnimationContext)
+ (void)beginGrouping;
+ (void)endGrouping;
@property (class, readonly, strong) NSObject *currentContext;
@property NSTimeInterval duration;
@end

void initAnimationContextClass(void *context) {
    nsAnimationContextClass = NSClassFromString(@"NSAnimationContext");
}

void _AppKitAddSubview(id child, id parent, NSUInteger index) {
    NSArray<id> *subviews = [parent subviews];
    NSUInteger count = [subviews count];
    if (count > index && subviews[index] == child) {
        return;
    }
    if ([child superview] == parent) {
        NSUInteger nextIndex = index + 1;
        if (nextIndex < count && subviews[nextIndex] == child) {
            child = subviews[index];
            index = count;
        }
    }
    dispatch_once_f(&nsAnimationContextOnce, NULL, &initAnimationContextClass);
    [nsAnimationContextClass beginGrouping];
    [[nsAnimationContextClass currentContext] setDuration:0.0];
    NSInteger place;
    id otherView;
    if (index == count) {
        // Append at end: positioned above, no relative view
        place = 1; /*NSWindowAbove*/
        otherView = nil;
    } else if (index == 0) {
        // Insert at beginning: positioned below, no relative view
        place = -1;/*NSWindowBelow*/
        otherView = nil;
    } else {
        // Insert before the view currently at index
        place = -1;/*NSWindowBelow*/
        otherView = subviews[index];
    }
    [parent openswiftui_addRenderedSubview:child positioned:place relativeTo:otherView];
    [nsAnimationContextClass endGrouping];
}
