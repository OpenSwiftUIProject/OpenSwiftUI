//
//  TimeIntervalProvider.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#pragma once

#include "BaseDateProvider.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface TimeIntervalProvider : BaseDateProvider {
@private
    NSDateFormatter *_dateFormatter;
    NSArray<NSNumber *> *_fallbackSequence;
    NSDate *_startDate;
    NSDate *_endDate;
}

- (instancetype)initWithStartDate:(NSDate *)startDate
                           endDate:(NSDate *)endDate;

- (instancetype)initWithStartDate:(NSDate *)startDate
                           endDate:(NSDate *)endDate
                          calendar:(NSCalendar *)calendar
                            locale:(NSLocale *)locale
                          timeZone:(nullable NSTimeZone *)timeZone;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
