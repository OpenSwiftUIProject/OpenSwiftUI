//
//  UIKitFocusableViewResponderItemBase.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef UIKitFocusableViewResponderItemBase_h
#define UIKitFocusableViewResponderItemBase_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

#import <UIKit/UIKit.h>

OPENSWIFTUI_SWIFT_NAME(UIKitFocusableViewResponderItemBase)
@interface OpenSwiftUIUIKitFocusableViewResponderItemBase : UIResponder
@property (nonatomic, readonly, nullable) NSString *openswiftui_focusGroupIdentifier;
@end

#endif

#endif /* UIKitFocusableViewResponderItemBase_h */
