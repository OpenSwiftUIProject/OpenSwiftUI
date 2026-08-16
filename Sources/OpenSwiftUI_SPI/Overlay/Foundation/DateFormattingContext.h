//
//  DateFormattingContext.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#pragma once

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface DateFormattingContext : NSObject {
@private
    BOOL _isLuminanceReduced;
    NSDate *_referenceDate;
}

- (instancetype)initWithReferenceDate:(nullable NSDate *)referenceDate
                    isLuminanceReduced:(BOOL)isLuminanceReduced
    NS_DESIGNATED_INITIALIZER
    NS_SWIFT_NAME(init(referenceDate:isLuminanceReduced:));

@property (nonatomic, readonly, nullable) NSDate *referenceDate;
@property (nonatomic, readonly) BOOL isLuminanceReduced;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
