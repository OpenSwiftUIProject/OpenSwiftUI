//
//  DateProvider.h
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

@interface BaseDateProvider : NSObject {
@private
    NSCalendar *_calendar;
    NSLocale *_locale;
    NSTimeZone *_timeZone;
}

- (instancetype)initWithCalendar:(NSCalendar *)calendar
                           locale:(NSLocale *)locale
                         timeZone:(nullable NSTimeZone *)timeZone NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSLocale *locale;
@property (nonatomic, strong, nullable) NSTimeZone *timeZone;

@property (nonatomic, readonly) NSInteger updateType;
@property (nonatomic, readonly) NSCalendarUnit updateWallClockAlignment;
@property (nonatomic, readonly, nullable) NSDateInterval *timerInterval;
@property (nonatomic, readonly, nullable) NSDate *timerEndDate;

- (nullable NSNumber *)updateInterval;

- (nullable NSString *)formattedString;
- (nullable NSString *)formattedStringInContext:(DateFormattingContext *)context;

@end

@interface DateProvider : BaseDateProvider {
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

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
