//
//  DateProvider.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "DateProvider.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <CoreFoundation/CoreFoundation.h>

NSCalendarUnit NSCalendarUnitSmallestUnit(NSCalendarUnit units) {
    static const NSCalendarUnit orderedUnits[] = {
        NSCalendarUnitNanosecond,
        NSCalendarUnitSecond,
        NSCalendarUnitMinute,
        NSCalendarUnitHour,
        NSCalendarUnitDay,
        NSCalendarUnitWeekday,
        NSCalendarUnitWeekdayOrdinal,
        NSCalendarUnitWeekOfMonth,
        NSCalendarUnitWeekOfYear,
        NSCalendarUnitMonth,
        NSCalendarUnitQuarter,
        NSCalendarUnitYear,
        NSCalendarUnitYearForWeekOfYear,
        NSCalendarUnitEra,
    };
    for (size_t index = 0; index < sizeof(orderedUnits) / sizeof(orderedUnits[0]); index += 1) {
        if ((units & orderedUnits[index]) != 0) {
            return orderedUnits[index];
        }
    }
    return 0;
}

extern BOOL LocaleIsCJK(NSLocale *locale);
extern BOOL RemovesPunctuationFromWeekdayDay(NSLocale *locale);

extern CFStringRef _Nullable _CFDateFormatterCreateSkeletonFromTemplate(
    CFStringRef format,
    CFLocaleRef locale,
    CFOptionFlags options
) CF_RETURNS_RETAINED;

extern CFOptionFlags _CFCalendarGetUnitsFromDateFormat(CFStringRef format);

static BOOL _isWeekdayDayTemplate(NSString *dateFormatTemplate) {
    return [dateFormatTemplate isEqualToString:@"EEE d"] ||
           [dateFormatTemplate isEqualToString:@"EEEE d"] ||
           [dateFormatTemplate isEqualToString:@"ccccc d"];
}

static NSString *_removePunctuationIfNecessaryFromTextForTemplate(
    NSString *text,
    NSString *dateFormatTemplate,
    NSLocale *locale
) {
    if (!_isWeekdayDayTemplate(dateFormatTemplate) ||
        !RemovesPunctuationFromWeekdayDay(locale)) {
        return text;
    }

    static NSMutableCharacterSet *punctuationExceptDash;
    if (punctuationExceptDash == nil) {
        punctuationExceptDash = [NSMutableCharacterSet punctuationCharacterSet];
        [punctuationExceptDash removeCharactersInString:@"-"];
    }
    NSArray<NSString *> *components = [text componentsSeparatedByCharactersInSet:punctuationExceptDash];
    return [components componentsJoinedByString:@""];
}

@interface OpenSwiftUIDateProvider ()
- (NSArray<NSString *> *)_completeDateTemplateSeries;
- (NSArray<NSString *> *)_partialDateTemplateSeriesForUnits:(NSCalendarUnit)units;
- (NSCalendarUnit)_minCalendarUnitFromFormat:(NSString *)format;
@end

@implementation OpenSwiftUIDateProvider

- (instancetype)initWithDate:(NSDate *)date units:(NSCalendarUnit)units {
    return [self initWithDate:date
                        units:units
                     calendar:NSCalendar.currentCalendar
                       locale:NSLocale.currentLocale
                     timeZone:nil];
}

- (instancetype)initWithDate:(NSDate *)date
                        units:(NSCalendarUnit)units
                     calendar:(NSCalendar *)calendar
                       locale:(NSLocale *)locale
                     timeZone:(NSTimeZone * _Nullable)timeZone {
    self = [super initWithCalendar:calendar locale:locale timeZone:timeZone];
    if (self) {
        _date = date;
        _calendarUnits = units;
    }
    return self;
}

- (instancetype)initWithDateFormat:(NSString *)dateFormat
                           calendar:(NSCalendar *)calendar
                             locale:(NSLocale *)locale
                           timeZone:(NSTimeZone * _Nullable)timeZone {
    self = [super initWithCalendar:calendar locale:locale timeZone:timeZone];
    if (self) {
        _date = [NSDate date];
        _dateFormat = dateFormat;
        _updateWallClockAlignment = [self _minCalendarUnitFromFormat:dateFormat];
    }
    return self;
}

- (instancetype)initWithDateFormatTemplate:(NSString *)dateFormatTemplate
                                   calendar:(NSCalendar *)calendar
                                     locale:(NSLocale *)locale
                                   timeZone:(NSTimeZone * _Nullable)timeZone {
    self = [super initWithCalendar:calendar locale:locale timeZone:timeZone];
    if (self) {
        _date = [NSDate date];
        _dateFormatTemplate = dateFormatTemplate;
        _updateWallClockAlignment = [self _minCalendarUnitFromFormat:dateFormatTemplate];
    }
    return self;
}

- (OpenSwiftUIBaseDateProviderUpdateType)updateType {
    return self.dateFormatTemplate != nil || self.dateFormat != nil
        ? OpenSwiftUIBaseDateProviderUpdateTypeWallClock
        : OpenSwiftUIBaseDateProviderUpdateTypeInterval;
}

- (NSCalendarUnit)updateWallClockAlignment {
    return _updateWallClockAlignment;
}

- (void)setUpdateWallClockAlignment:(NSCalendarUnit)updateWallClockAlignment {
    _updateWallClockAlignment = updateWallClockAlignment;
}

- (void)_startSessionWithDate:(NSDate * _Nullable)date {
    if (date != nil) {
        _date = date;
    }
}

- (NSString * _Nullable)_sessionTextForIndex:(NSInteger)index context:(OpenSwiftUIDateFormattingContext *)context {
    if (_date == nil) {
        return nil;
    }

    self.dateFormatter.dateFormat = nil;
    if (self.dateFormatTemplate != nil) {
        [self.dateFormatter setLocalizedDateFormatFromTemplate:self.dateFormatTemplate];
    } else if (_dateFormat != nil) {
        self.dateFormatter.dateFormat = _dateFormat;
    } else {
        if (_templateSeries == nil) {
            _templateSeries = [self _completeDateTemplateSeries];
        }
        if ((NSUInteger)index >= _templateSeries.count) {
            return nil;
        }

        NSString *dateFormatTemplate = [_templateSeries objectAtIndex:(NSUInteger)index];
        NSLocale *locale = self.locale;
        BOOL usesExactFormat;
        if ([dateFormatTemplate isEqualToString:@"d"]) {
            usesExactFormat = LocaleIsCJK(locale);
        } else {
            usesExactFormat =
                _isWeekdayDayTemplate(dateFormatTemplate) &&
                [[locale objectForKey:NSLocaleLanguageCode] isEqualToString:@"en"];
        }
        if (usesExactFormat) {
            self.dateFormatter.dateFormat = dateFormatTemplate;
        } else {
            [self.dateFormatter setLocalizedDateFormatFromTemplate:dateFormatTemplate];
        }

        NSString *string = [self.dateFormatter stringFromDate:_date];
        if ([dateFormatTemplate isEqualToString:[@"MMMMM" stringByAppendingString:@"d"]] &&
            LocaleIsCJK(self.locale)) {
            string = [self.dateFormatter stringFromDate:_date];
        } else {
            string = _removePunctuationIfNecessaryFromTextForTemplate(
                string,
                dateFormatTemplate,
                self.locale
            );
        }
        return string;
    }

    return [self.dateFormatter stringFromDate:_date];
}

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.formattingContext = NSFormattingContextStandalone;
        _dateFormatter.calendar = self.calendar;
        _dateFormatter.locale = self.locale;
        if (self.timeZone != nil) {
            _dateFormatter.timeZone = self.timeZone;
        }
    }
    return _dateFormatter;
}

- (void)setDateFormatter:(NSDateFormatter *)dateFormatter {
    _dateFormatter = dateFormatter;
}

- (NSArray<NSString *> *)_completeDateTemplateSeries {
    NSCalendarUnit units = _calendarUnits & (
        NSCalendarUnitYear |
        NSCalendarUnitMonth |
        NSCalendarUnitDay |
        NSCalendarUnitWeekday
    );
    if (units == 0) {
        units = NSCalendarUnitDay;
    }

    NSMutableArray<NSString *> *series = [NSMutableArray array];
    while (units != 0) {
        [series addObjectsFromArray:[self _partialDateTemplateSeriesForUnits:units]];
        if ((units & NSCalendarUnitYear) != 0) {
            units &= ~NSCalendarUnitYear;
        } else if ((units & NSCalendarUnitWeekday) != 0) {
            units &= ~NSCalendarUnitWeekday;
        } else if ((units & NSCalendarUnitMonth) != 0) {
            units &= ~NSCalendarUnitMonth;
        } else {
            units &= ~NSCalendarUnitDay;
        }
    }
    return series;
}

- (NSArray<NSString *> *)_partialDateTemplateSeriesForUnits:(NSCalendarUnit)units {
    NSMutableArray<NSString *> *prefixes = [NSMutableArray new];
    if (units == (NSCalendarUnitWeekday | NSCalendarUnitDay)) {
        [prefixes addObject:@"EEEE d"];
        [prefixes addObject:@"EEE d"];
        return prefixes;
    }

    NSCalendarUnit monthAndWeekday = NSCalendarUnitMonth | NSCalendarUnitWeekday;
    if ((units & monthAndWeekday) == monthAndWeekday) {
        [prefixes addObjectsFromArray:@[@"MMMMEEEE", @"MMMMEEE", @"MMMEEEE"]];
        [prefixes addObject:@"MMMEEE"];
    } else if ((units & NSCalendarUnitMonth) != 0) {
        [prefixes addObject:@"MMMM"];
        [prefixes addObject:@"MMM"];
    } else if ((units & NSCalendarUnitWeekday) != 0) {
        [prefixes addObject:@"EEEE"];
        [prefixes addObject:@"EEE"];
    } else {
        [prefixes addObject:@""];
    }

    NSString *suffix = @"";
    if ((units & NSCalendarUnitDay) != 0) {
        suffix = [suffix stringByAppendingString:@"d"];
    }
    if ((units & NSCalendarUnitYear) != 0) {
        suffix = [suffix stringByAppendingString:@"y"];
    }

    NSMutableArray<NSString *> *series = [NSMutableArray array];
    for (NSString *prefix in prefixes) {
        [series addObject:[prefix stringByAppendingString:suffix]];
    }
    return series;
}

- (NSCalendarUnit)_minCalendarUnitFromFormat:(NSString *)format {
    if (format.length == 0) {
        return 0;
    }
    if ([format isEqualToString:@"a"]) {
        return NSCalendarUnitHour;
    }

    CFStringRef skeleton = _CFDateFormatterCreateSkeletonFromTemplate(
        (__bridge CFStringRef)format,
        (__bridge CFLocaleRef)self.locale,
        0
    );
    if (skeleton == NULL) {
        return 0;
    }
    NSCalendarUnit units = (NSCalendarUnit)_CFCalendarGetUnitsFromDateFormat(skeleton);
    CFRelease(skeleton);
    return NSCalendarUnitSmallestUnit(units);
}

@end

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
