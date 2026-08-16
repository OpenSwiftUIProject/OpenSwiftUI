//
//  TimeIntervalProvider.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "TimeIntervalProvider.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

extern NSString * const NSDateFormatterPatternCharacterKey;
extern NSString *LocalizedString(NSString *key, NSLocale *locale);

static NSString * const _StandardTimeFormatTemplate = @"j:mm";
static NSString * const _NoMinutesTimeFormatTemplate = @"j";

typedef BOOL (^TimeIntervalProviderPattern)(NSString * _Nullable pattern);

@interface NSDateFormatter (OpenSwiftUITimeIntervalProviderPrivate)
- (nullable NSAttributedString *)_attributedStringWithFieldsFromDate:(NSDate *)date;
@end

@interface BaseDateProvider (OpenSwiftUITimeIntervalProviderPrivate)
- (NSString *)_timeFormatByRemovingWhitespaceAroundDesignatorOfTimeFormat:(NSString *)timeFormat
                                                         designatorExists:(nullable BOOL *)designatorExists;
@end

@interface TimeIntervalProvider ()
- (nullable NSString *)_sessionTextForIndex:(NSInteger)index
                                    context:(DateFormattingContext *)context;
- (NSRange)_rangeOfDesignatorInAnnotatedTime:(NSAttributedString *)annotatedTime;
- (NSRange)_rangeOfHoursInAnnotatedTime:(NSAttributedString *)annotatedTime;
- (NSRange)_rangeOfAnnontatedTime:(NSAttributedString *)annotatedTime
                  matchingPattern:(TimeIntervalProviderPattern)matchingPattern;
- (NSString *)_stringByRemovingDesignatorRange:(NSRange)removingDesignatorRange
                                    fromString:(NSString *)string;
- (NSArray<NSNumber *> *)_fallbackSequence;
- (nullable NSString *)_textForSequenceItem:(NSInteger)sequenceItem;
- (nullable NSString *)_timeIntervalFullText;
- (nullable NSString *)_timeIntervalDropMinutesText;
- (nullable NSString *)_startTimeFullText;
- (nullable NSString *)_startTimeDropMinutesText;
- (nullable NSString *)_dateIntervalWideText;
- (nullable NSString *)_dateIntervalNarrowText;
- (nullable NSString *)_timeIntervalTextWithDropMinutes:(BOOL)dropMinutes
                                           onlyStartDate:(BOOL)onlyStartDate;
- (nullable NSString *)_dateIntervalTextWithNarrow:(BOOL)narrow;
@end

static BOOL _DropLeftRedundantDesignator(NSLocale *locale) {
    NSString *value = LocalizedString(
        @"INTERVAL_DROP_LEFTMOST_REDUNDANT_DESIGNATOR",
        locale
    );
    return value == nil || value.boolValue;
}

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

- (NSString * _Nullable)_sessionTextForIndex:(NSInteger)index
                                      context:(DateFormattingContext *)context {
    if (_startDate == nil || _endDate == nil) {
        return nil;
    }

    if (_dateFormatter == nil) {
        _dateFormatter = [NSDateFormatter new];
        if (self.timeZone != nil) {
            _dateFormatter.timeZone = self.timeZone;
        }
        _dateFormatter.calendar = self.calendar;
        _dateFormatter.locale = self.locale;
    }

    if (_fallbackSequence == nil) {
        _fallbackSequence = [self _fallbackSequence];
    }
    if ((NSUInteger)index >= _fallbackSequence.count) {
        return nil;
    }
    return [self _textForSequenceItem:_fallbackSequence[(NSUInteger)index].integerValue];
}

- (NSRange)_rangeOfDesignatorInAnnotatedTime:(NSAttributedString *)annotatedTime {
    return [self _rangeOfAnnontatedTime:annotatedTime matchingPattern:^BOOL(NSString *pattern) {
        return [pattern hasPrefix:@"a"];
    }];
}

- (NSRange)_rangeOfHoursInAnnotatedTime:(NSAttributedString *)annotatedTime {
    return [self _rangeOfAnnontatedTime:annotatedTime matchingPattern:^BOOL(NSString *pattern) {
        return [pattern hasPrefix:@"H"] ||
               [pattern hasPrefix:@"h"] ||
               [pattern hasPrefix:@"K"] ||
               [pattern hasPrefix:@"k"];
    }];
}

- (NSRange)_rangeOfAnnontatedTime:(NSAttributedString *)annotatedTime
                  matchingPattern:(TimeIntervalProviderPattern)matchingPattern {
    __block NSRange result = NSMakeRange(NSNotFound, 0);
    [annotatedTime enumerateAttributesInRange:NSMakeRange(0, annotatedTime.length)
                                      options:0
                                   usingBlock:^(NSDictionary<NSAttributedStringKey, id> *attributes,
                                                NSRange range,
                                                BOOL *stop) {
        NSString *pattern = attributes[NSDateFormatterPatternCharacterKey];
        if (matchingPattern(pattern)) {
            result = range;
            *stop = YES;
        }
    }];
    return result;
}

- (NSString *)_stringByRemovingDesignatorRange:(NSRange)removingDesignatorRange
                                    fromString:(NSString *)string {
    NSString *result = [string stringByReplacingCharactersInRange:removingDesignatorRange
                                                        withString:@""];
    return [result stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
}

- (NSArray<NSNumber *> *)_fallbackSequence {
    NSCalendar *calendar = self.calendar;
    if (self.timeZone != nil) {
        calendar.timeZone = self.timeZone;
    }

    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:_startDate
                                                 toDate:_endDate
                                                options:0];
    if (components.day != 0) {
        return @[@4, @5];
    }

    NSMutableArray<NSNumber *> *sequence = [NSMutableArray arrayWithObject:@0];
    NSInteger startMinute = [calendar component:NSCalendarUnitMinute fromDate:_startDate];
    NSInteger endMinute = [calendar component:NSCalendarUnitMinute fromDate:_endDate];
    if ((startMinute | endMinute) == 0) {
        [sequence addObject:@1];
        [sequence addObject:@2];
        [sequence addObject:@3];
    } else {
        [sequence addObject:@2];
        if (startMinute == 0) {
            [sequence addObject:@3];
        }
    }
    return sequence;
}

- (NSString * _Nullable)_textForSequenceItem:(NSInteger)sequenceItem {
    switch (sequenceItem) {
    case 0:
        return [self _timeIntervalFullText];
    case 1:
        return [self _timeIntervalDropMinutesText];
    case 2:
        return [self _startTimeFullText];
    case 3:
        return [self _startTimeDropMinutesText];
    case 4:
        return [self _dateIntervalWideText];
    case 5:
        return [self _dateIntervalNarrowText];
    default:
        return nil;
    }
}

- (NSString * _Nullable)_timeIntervalFullText {
    return [self _timeIntervalTextWithDropMinutes:NO onlyStartDate:NO];
}

- (NSString * _Nullable)_timeIntervalDropMinutesText {
    return [self _timeIntervalTextWithDropMinutes:YES onlyStartDate:NO];
}

- (NSString * _Nullable)_startTimeFullText {
    return [self _timeIntervalTextWithDropMinutes:NO onlyStartDate:YES];
}

- (NSString * _Nullable)_startTimeDropMinutesText {
    return [self _timeIntervalTextWithDropMinutes:YES onlyStartDate:YES];
}

- (NSString * _Nullable)_dateIntervalWideText {
    return [self _dateIntervalTextWithNarrow:NO];
}

- (NSString * _Nullable)_dateIntervalNarrowText {
    return [self _dateIntervalTextWithNarrow:YES];
}

- (NSString * _Nullable)_timeIntervalTextWithDropMinutes:(BOOL)dropMinutes
                                            onlyStartDate:(BOOL)onlyStartDate {
    NSString *template = dropMinutes
        ? _NoMinutesTimeFormatTemplate
        : _StandardTimeFormatTemplate;
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:template
                                                            options:0
                                                             locale:self.locale];
    BOOL designatorExists = NO;
    dateFormat = [self _timeFormatByRemovingWhitespaceAroundDesignatorOfTimeFormat:dateFormat
                                                                  designatorExists:&designatorExists];
    _dateFormatter.dateFormat = dateFormat;

    NSAttributedString *annotatedStartTime =
        [_dateFormatter _attributedStringWithFieldsFromDate:_startDate];
    if (annotatedStartTime.string == nil) {
        return nil;
    }
    NSRange startDesignatorRange = [self _rangeOfDesignatorInAnnotatedTime:annotatedStartTime];
    NSString *startDesignator = nil;
    if (startDesignatorRange.location != NSNotFound) {
        startDesignator = [annotatedStartTime attributedSubstringFromRange:startDesignatorRange].string;
    }

    NSAttributedString *annotatedEndTime = nil;
    NSRange endDesignatorRange = NSMakeRange(NSNotFound, 0);
    NSString *endDesignator = nil;
    if (!onlyStartDate) {
        annotatedEndTime = [_dateFormatter _attributedStringWithFieldsFromDate:_endDate];
        if (annotatedEndTime.string == nil) {
            return nil;
        }
        endDesignatorRange = [self _rangeOfDesignatorInAnnotatedTime:annotatedEndTime];
        if (endDesignatorRange.location != NSNotFound) {
            endDesignator = [annotatedEndTime attributedSubstringFromRange:endDesignatorRange].string;
        }
    }

    NSString *hyphen = LocalizedString(@"INTERVAL_HYPHEN_NARROW", self.locale);
    if (startDesignator == nil && endDesignator == nil) {
        if (onlyStartDate) {
            return annotatedStartTime.string;
        }
        return [NSString stringWithFormat:@"%@%@%@",
                                          annotatedStartTime.string,
                                          hyphen,
                                          annotatedEndTime.string];
    }

    NSString *startString = annotatedStartTime.string;
    if (onlyStartDate) {
        return startString;
    }
    NSString *endString = annotatedEndTime.string;
    if (endDesignator != nil && [startDesignator isEqualToString:endDesignator]) {
        if (_DropLeftRedundantDesignator(self.locale)) {
            if (startDesignatorRange.location != NSNotFound) {
                startString = [self _stringByRemovingDesignatorRange:startDesignatorRange
                                                           fromString:startString];
            }
        } else if (endDesignatorRange.location != NSNotFound) {
            endString = [self _stringByRemovingDesignatorRange:endDesignatorRange
                                                    fromString:endString];
        }
    }

    NSMutableString *result = [[NSMutableString alloc] initWithString:startString];
    [result appendString:hyphen];
    [result appendString:endString];
    return result;
}

- (NSString * _Nullable)_dateIntervalTextWithNarrow:(BOOL)narrow {
    [_dateFormatter setLocalizedDateFormatFromTemplate:narrow ? @"M/d" : @"MMM d"];
    NSString *startString = [_dateFormatter stringFromDate:_startDate];
    NSString *endString = [_dateFormatter stringFromDate:_endDate];
    NSString *hyphen = LocalizedString(@"INTERVAL_HYPHEN_WIDE", self.locale);
    return [NSString stringWithFormat:@"%@%@%@", startString, hyphen, endString];
}

@end

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
