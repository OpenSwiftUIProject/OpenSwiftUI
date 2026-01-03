//
//  CATransactionCompletionItem.m
//  COpenSwiftUI

#import "CATransactionCompletionItem.h"

#if __has_include(<QuartzCore/QuartzCore.h>)

CATransactionCompletionItem *_CATransactionCompletionItem(void) {
    return [CATransactionCompletionItem completionItem];
}

#endif /* __has_include(<QuartzCore/QuartzCore.h>) */

