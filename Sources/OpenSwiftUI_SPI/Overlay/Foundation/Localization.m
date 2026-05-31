//
//  Localization.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "Localization.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <CoreFoundation/CoreFoundation.h>
#import <os/lock.h>

@interface NSBundle (OpenSwiftUILocalizationPrivate)
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)table localization:(NSString *)localization;
- (NSAttributedString *)localizedAttributedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)table;
- (NSAttributedString *)localizedAttributedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)table localization:(NSString *)localization;
@end

static NSString * _Nullable _getBestLocalization(NSBundle *bundle, NSLocale * _Nullable locale) {
    static NSMapTable<NSBundle *, NSMutableDictionary<NSString *, NSString *> *> *cache;
    static os_unfair_lock lock = OS_UNFAIR_LOCK_INIT;

    if (locale == nil) {
        return nil;
    }
    if ([locale isEqual:NSLocale.currentLocale] || locale.languageIdentifier == nil) {
        return nil;
    }

    os_unfair_lock_lock(&lock);
    if (cache == nil) {
        cache = NSMapTable.weakToStrongObjectsMapTable;
    }
    NSMutableDictionary<NSString *, NSString *> *bundleCache = [cache objectForKey:bundle];
    NSString *localeIdentifier = locale.localeIdentifier;
    NSString *bestLocalization = [bundleCache objectForKey:localeIdentifier];
    os_unfair_lock_unlock(&lock);

    if (bestLocalization != nil) {
        return bestLocalization;
    }

    NSArray<NSString *> *localizations = bundle.localizations;
    NSString *languageIdentifier = locale.languageIdentifier;
    NSArray<NSString *> *preferences = [NSArray arrayWithObjects:&languageIdentifier count:1];
    NSArray<NSString *> *preferredLocalizations = [NSBundle preferredLocalizationsFromArray:localizations forPreferences:preferences];
    bestLocalization = preferredLocalizations.firstObject;

    os_unfair_lock_lock(&lock);
    if (bundleCache == nil) {
        bundleCache = [NSMutableDictionary new];
        [cache setObject:bundleCache forKey:bundle];
    }
    bundleCache[locale.localeIdentifier] = bestLocalization;
    os_unfair_lock_unlock(&lock);

    return bestLocalization;
}

NSString *_LocalizeString(NSBundle *bundle, NSString *key, NSString * _Nullable table, NSLocale * _Nullable locale) {
    NSString *localization = _getBestLocalization(bundle, locale);
    if (localization != nil) {
        return [bundle localizedStringForKey:key value:nil table:table localization:localization];
    } else {
        return [bundle localizedStringForKey:key value:nil table:table];
    }
}

NSAttributedString *_LocalizeAttributedString(NSBundle *bundle, NSString *key, NSString * _Nullable table, NSLocale * _Nullable locale) {
    NSString *localization = _getBestLocalization(bundle, locale);
    if (localization != nil) {
        return [bundle localizedAttributedStringForKey:key value:nil table:table localization:localization];
    } else {
        return [bundle localizedAttributedStringForKey:key value:nil table:table];
    }
}

BOOL _isBeginningOfSentence(NSString * __unsafe_unretained string, NSString * __unsafe_unretained substring, NSLocale * __unsafe_unretained _Nullable locale) {
    CFStringRef source = (__bridge CFStringRef)string;
    CFStringRef searchString = (__bridge CFStringRef)substring;
    CFLocaleRef tokenizerLocale = (__bridge CFLocaleRef)locale;
    CFMutableStringRef uppercaseMutableString = CFStringCreateMutableCopy(NULL, 0, source);
    CFStringUppercase(uppercaseMutableString, NULL);
    CFStringRef uppercaseString = CFStringCreateCopy(NULL, uppercaseMutableString);
    CFRelease(uppercaseMutableString);
    CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault,
                                                             uppercaseString,
                                                             CFRangeMake(0, CFStringGetLength(uppercaseString)),
                                                             kCFStringTokenizerUnitSentence,
                                                             tokenizerLocale);
    while (CFStringTokenizerAdvanceToNextToken(tokenizer) != kCFStringTokenizerTokenNone) {
        CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        CFStringRef token = CFStringCreateWithSubstring(NULL, uppercaseString, tokenRange);
        CFRange matchRange = CFStringFind(token, searchString, 0);
        if (matchRange.location != kCFNotFound) {
            BOOL result = matchRange.location == 0;
            CFRelease(token);
            CFRelease(uppercaseString);
            CFRelease(tokenizer);
            return result;
        }
        CFRelease(token);
    }
    CFRelease(uppercaseString);
    CFRelease(tokenizer);
    return NO;
}

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
