//
//  CATransactionCompletionItem.h
//  COpenSwiftUI

#ifndef CATransactionCompletionItem_h
#define CATransactionCompletionItem_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/QuartzCore.h>)

#import <QuartzCore/QuartzCore.h>
#import "Shims/QuartzCore/QuartzCore_Private.h"

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
CATransactionCompletionItem * _Nullable _CATransactionCompletionItem(void);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* __has_include(<QuartzCore/QuartzCore.h>) */

#endif /* CATransactionCompletionItem_h */

