//
//  TimeIntervalProvider.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: WIP

#include "TimeIntervalProvider.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

@implementation TimeIntervalProvider

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    return [self initWithStartDate:startDate
                          endDate:endDate
                         calendar:NSCalendar.currentCalendar
                           locale:NSLocale.currentLocale
                         timeZone:nil];
}

- (instancetype)initWithStartDate:(NSDate *)startDate
                           endDate:(NSDate *)endDate
                          calendar:(NSCalendar *)calendar
                            locale:(NSLocale *)locale
                          timeZone:(NSTimeZone * _Nullable)timeZone {
    self = [super initWithCalendar:calendar locale:locale timeZone:timeZone];
    if (self) {
        _startDate = startDate;
        _endDate = endDate;
    }
    return self;
}

@end

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
