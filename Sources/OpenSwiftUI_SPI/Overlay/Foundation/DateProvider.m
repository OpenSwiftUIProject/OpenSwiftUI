//
//  DateProvider.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "DateProvider.h"
#include "Localization.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <CoreFoundation/CoreFoundation.h>

@implementation DateFormattingContext

- (instancetype)initWithReferenceDate:(NSDate * _Nullable)referenceDate
                    isLuminanceReduced:(BOOL)isLuminanceReduced {
    self = [super init];
    if (self) {
        _referenceDate = referenceDate;
        _isLuminanceReduced = isLuminanceReduced;
    }
    return self;
}

- (instancetype)init {
    return [self initWithReferenceDate:nil isLuminanceReduced:NO];
}

@end

extern NSString * const NSDateFormatterPatternLiteralKey;
extern NSString * const NSDateFormatterPatternStringKey;

@interface NSDateFormatter (OpenSwiftUIDateProviderPrivate)
+ (NSArray<NSDictionary<NSString *, id> *> *)_componentsFromFormatString:(NSString *)format;
+ (NSString *)_formatStringFromComponents:(NSArray<NSDictionary<NSString *, id> *> *)components;
@end

@interface BaseDateProvider ()
- (void)_startSessionWithDate:(nullable NSDate *)date;
- (nullable NSString *)_sessionTextForIndex:(NSInteger)index context:(DateFormattingContext *)context;
- (void)_endSession;
- (NSInteger)_updateFrequency;
- (NSString *)_timeFormatByRemovingWhitespaceAroundDesignatorOfTimeFormat:(NSString *)timeFormat
                                                         designatorExists:(nullable BOOL *)designatorExists;
- (NSString *)_timeFormatByRemovingDesignatorOfTimeFormat:(NSString *)timeFormat;
- (NSString *)_timeFormatByRemovingWhitespaceAroundDesignatorOfTimeFormat:(NSString *)timeFormat
                                                   andRemovingDesignator:(BOOL)removingDesignator
                                                        designatorExists:(nullable BOOL *)designatorExists;
@end

@implementation BaseDateProvider

- (instancetype)initWithCalendar:(NSCalendar *)calendar
                           locale:(NSLocale *)locale
                         timeZone:(NSTimeZone * _Nullable)timeZone {
    self = [super init];
    if (self) {
        _calendar = calendar;
        _locale = locale;
        _timeZone = timeZone;
    }
    return self;
}

- (NSString * _Nullable)formattedString {
    return [self formattedStringInContext:[[DateFormattingContext alloc] init]];
}

- (NSString * _Nullable)formattedStringInContext:(DateFormattingContext *)context {
    [self _startSessionWithDate:context.referenceDate];
    NSString *string = [self _sessionTextForIndex:0 context:context];
    [self _endSession];
    return string;
}

- (NSInteger)updateType {
    return 0;
}

- (NSNumber * _Nullable)updateInterval {
    switch ([self _updateFrequency]) {
    case 1:
        return @60.0;
    case 2:
        return @1.0;
    case 3:
        return @(1.0 / 30.0);
    default:
        return nil;
    }
}

- (NSCalendarUnit)updateWallClockAlignment {
    return 0;
}

- (NSDateInterval * _Nullable)timerInterval {
    return nil;
}

- (NSDate * _Nullable)timerEndDate {
    return nil;
}

- (void)_startSessionWithDate:(NSDate * _Nullable)date {}

- (NSString * _Nullable)_sessionTextForIndex:(NSInteger)index context:(DateFormattingContext *)context {
    return @"";
}

- (void)_endSession {}

- (NSInteger)_updateFrequency {
    return 0;
}

- (NSString *)_timeFormatByRemovingWhitespaceAroundDesignatorOfTimeFormat:(NSString *)timeFormat
                                                         designatorExists:(BOOL * _Nullable)designatorExists {
    return [self _timeFormatByRemovingWhitespaceAroundDesignatorOfTimeFormat:timeFormat
                                                     andRemovingDesignator:NO
                                                          designatorExists:designatorExists];
}

- (NSString *)_timeFormatByRemovingDesignatorOfTimeFormat:(NSString *)timeFormat {
    return [self _timeFormatByRemovingWhitespaceAroundDesignatorOfTimeFormat:timeFormat
                                                     andRemovingDesignator:YES
                                                          designatorExists:NULL];
}

- (NSString *)_timeFormatByRemovingWhitespaceAroundDesignatorOfTimeFormat:(NSString *)timeFormat
                                                   andRemovingDesignator:(BOOL)removingDesignator
                                                        designatorExists:(BOOL * _Nullable)designatorExists {
    NSArray<NSDictionary<NSString *, id> *> *components = [NSDateFormatter _componentsFromFormatString:timeFormat];
    NSUInteger designatorIndex = NSNotFound;
    for (NSDictionary<NSString *, id> *component in components) {
        BOOL isLiteral = [component[NSDateFormatterPatternLiteralKey] boolValue];
        NSString *pattern = component[NSDateFormatterPatternStringKey];
        if (!isLiteral && [pattern hasPrefix:@"a"]) {
            designatorIndex = [components indexOfObject:component];
            break;
        }
    }

    if (designatorExists != NULL) {
        *designatorExists = designatorIndex != NSNotFound;
    }
    if (designatorIndex == NSNotFound) {
        return timeFormat;
    }
    (void)self.locale;
    if (!removingDesignator) {
        return timeFormat;
    }
    BOOL removePrevious = NO;
    if (designatorIndex != 0) {
        NSDictionary<NSString *, id> *previous = components[designatorIndex - 1];
        if ([previous[NSDateFormatterPatternLiteralKey] boolValue]) {
            NSString *pattern = previous[NSDateFormatterPatternStringKey];
            removePrevious = [pattern stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet].length == 0;
        }
    }
    BOOL removeNext = NO;
    if (designatorIndex < components.count - 1) {
        NSDictionary<NSString *, id> *next = components[designatorIndex + 1];
        if ([next[NSDateFormatterPatternLiteralKey] boolValue]) {
            NSString *pattern = next[NSDateFormatterPatternStringKey];
            removeNext = [pattern stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet].length == 0;
        }
    }

    NSMutableArray<NSDictionary<NSString *, id> *> *result = components.mutableCopy;
    if (removeNext) {
        [result removeObjectAtIndex:designatorIndex + 1];
    }
    [result removeObjectAtIndex:designatorIndex];
    if (removePrevious) {
        [result removeObjectAtIndex:designatorIndex - 1];
    }
    return [NSDateFormatter _formatStringFromComponents:result];
}

@end

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

BOOL LocaleIsCJK(NSLocale *locale) {
    static NSSet<NSString *> *_cjkSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cjkSet = [NSSet setWithObjects:@"zh", @"ja", @"ko", nil];
    });
    return [_cjkSet containsObject:[locale objectForKey:NSLocaleLanguageCode]];
}

static NSBundle *Bundle(void) {
    static NSBundle *__bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __bundle = [NSBundle bundleForClass:BaseDateProvider.class];
    });
    return __bundle;
}

NSString *LocalizedString(NSString *key, NSLocale *locale) {
    return _LocalizeString(
        Bundle(),
        key,
        @"CoreDateProvider",
        locale
    );
}

BOOL RemovesPunctuationFromWeekdayDay(NSLocale *locale) {
    return [LocalizedString(@"DATE_WEEKDAY_DAY_REMOVE_PUNCTUATION", locale) boolValue];
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

@interface DateProvider ()
- (NSArray<NSString *> *)_completeDateTemplateSeries;
- (NSArray<NSString *> *)_partialDateTemplateSeriesForUnits:(NSCalendarUnit)units;
- (NSCalendarUnit)_minCalendarUnitFromFormat:(NSString *)format;
@end

@implementation DateProvider

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

- (NSInteger)updateType {
    return (self.dateFormatTemplate != nil || self.dateFormat != nil) ? 1 : 0;
}

- (void)_startSessionWithDate:(NSDate * _Nullable)date {
    if (date != nil) {
        _date = date;
    }
}

- (NSString * _Nullable)_sessionTextForIndex:(NSInteger)index context:(DateFormattingContext *)context {
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
    if (units == 0) {
        return 0;
    }

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
    for (NSUInteger index = 0; index < sizeof(orderedUnits) / sizeof(orderedUnits[0]); index += 1) {
        if ((units & orderedUnits[index]) != 0) {
            return orderedUnits[index];
        }
    }
    return 0;
}

@end

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
