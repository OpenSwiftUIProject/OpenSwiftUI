//
//  Localization.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#pragma once

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
NSString *_LocalizeString(NSBundle *bundle, NSString *key, NSString * _Nullable table, NSLocale * _Nullable locale);

OPENSWIFTUI_EXPORT
NSAttributedString *_LocalizeAttributedString(NSBundle *bundle, NSString *key, NSString * _Nullable table, NSLocale * _Nullable locale);

OPENSWIFTUI_EXPORT
BOOL _isBeginningOfSentence(NSString *string, NSString *substring, NSLocale * _Nullable locale);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
