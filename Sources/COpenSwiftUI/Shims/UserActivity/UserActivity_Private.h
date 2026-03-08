//
//  UserActivity_Private.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef UserActivity_Private_h
#define UserActivity_Private_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSUserActivity (OpenSwiftUI_SPI)
@property (nonatomic, readonly) BOOL _isUniversalLink;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* UserActivity_Private_h */
