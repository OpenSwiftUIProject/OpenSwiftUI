//
//  BaseDateProvider.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#pragma once

#include "DateFormattingContext.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OpenSwiftUIBaseDateProviderUpdateType) {
    OpenSwiftUIBaseDateProviderUpdateTypeInterval = 0,
    OpenSwiftUIBaseDateProviderUpdateTypeWallClock = 1,
    OpenSwiftUIBaseDateProviderUpdateTypeTimer = 2,
    OpenSwiftUIBaseDateProviderUpdateTypeTimerIntervalCountdown = 3,
    OpenSwiftUIBaseDateProviderUpdateTypeTimerIntervalCountup = 4,
} NS_SWIFT_NAME(BaseDateProvider.UpdateType);

NS_SWIFT_NAME(BaseDateProvider)
@interface OpenSwiftUIBaseDateProvider : NSObject {
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

@property (nonatomic, readonly) OpenSwiftUIBaseDateProviderUpdateType updateType;
@property (nonatomic, readonly) NSCalendarUnit updateWallClockAlignment;
@property (nonatomic, readonly, nullable) NSDateInterval *timerInterval;
@property (nonatomic, readonly, nullable) NSDate *timerEndDate;

- (nullable NSNumber *)updateInterval;

- (nullable NSString *)formattedString;
- (nullable NSString *)formattedStringInContext:(OpenSwiftUIDateFormattingContext *)context;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
