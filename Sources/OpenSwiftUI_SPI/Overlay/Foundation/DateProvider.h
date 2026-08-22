//
//  DateProvider.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#pragma once

#include "BaseDateProvider.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>

OPENSWIFTUI_EXPORT
NSCalendarUnit NSCalendarUnitSmallestUnit(NSCalendarUnit units);

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(DateProvider)
@interface OpenSwiftUIDateProvider : OpenSwiftUIBaseDateProvider {
@private
    NSArray<NSString *> *_templateSeries;
    BOOL _uppercase;
    NSCalendarUnit _updateWallClockAlignment;
    NSDate *_date;
    NSCalendarUnit _calendarUnits;
    NSString *_dateFormat;
    NSString *_dateFormatTemplate;
    NSDateFormatter *_dateFormatter;
}

- (instancetype)initWithDate:(NSDate *)date
                        units:(NSCalendarUnit)units;

- (instancetype)initWithDate:(NSDate *)date
                        units:(NSCalendarUnit)units
                     calendar:(NSCalendar *)calendar
                       locale:(NSLocale *)locale
                     timeZone:(nullable NSTimeZone *)timeZone;

- (instancetype)initWithDateFormat:(NSString *)dateFormat
                           calendar:(NSCalendar *)calendar
                             locale:(NSLocale *)locale
                           timeZone:(nullable NSTimeZone *)timeZone;

- (instancetype)initWithDateFormatTemplate:(NSString *)dateFormatTemplate
                                   calendar:(NSCalendar *)calendar
                                     locale:(NSLocale *)locale
                                   timeZone:(nullable NSTimeZone *)timeZone;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic) NSCalendarUnit calendarUnits;
@property (nonatomic) BOOL uppercase;
@property (nonatomic, copy, nullable) NSString *dateFormat;
@property (nonatomic, copy, nullable) NSString *dateFormatTemplate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic) NSCalendarUnit updateWallClockAlignment;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
