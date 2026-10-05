//
//  UIKitFocusableViewResponderItemBase.m
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#import "UIKitFocusableViewResponderItemBase.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

@implementation OpenSwiftUIUIKitFocusableViewResponderItemBase

- (NSString *)openswiftui_focusGroupIdentifier {
    return nil;
}

- (NSString *)focusGroupIdentifier {
    return self.openswiftui_focusGroupIdentifier;
}

@end

#endif
