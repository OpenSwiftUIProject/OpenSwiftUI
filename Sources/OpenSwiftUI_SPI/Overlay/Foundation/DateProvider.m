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


#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
