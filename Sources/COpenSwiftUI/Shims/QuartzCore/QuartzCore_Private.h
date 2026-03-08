//
//  QuartzCore_Private.h
//  COpenSwiftUI

#ifndef QuartzCore_Private_h
#define QuartzCore_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/QuartzCore.h>)

#import <QuartzCore/QuartzCore.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface CATransactionCompletionItem : NSObject
+ (nullable CATransactionCompletionItem *)completionItem;
- (void)invalidate;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* __has_include(<QuartzCore/QuartzCore.h>) */

#endif /* QuartzCore_Private_h */

