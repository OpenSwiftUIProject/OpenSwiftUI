//
//  CTFontLegibilityWeight.h
//  OpenSwiftUI_SPI
//
//  Status: WIP

#ifndef CTFontLegibilityWeight_h
#define CTFontLegibilityWeight_h

#include "OpenSwiftUIBase.h"

#if __has_include(<CoreText/CoreText.h>)

#import <CoreText/CoreText.h>
#import <CoreFoundation/CoreFoundation.h>

CF_ASSUME_NONNULL_BEGIN

/*!
    @enum       CTFontLegibilityWeight
    @abstract   Constants for font legibility weight options.
    @discussion These constants correspond to the Accessibility Bold Text user setting.
*/
typedef CF_ENUM(CFIndex, CTFontLegibilityWeight) {
    CTFontLegibilityWeightRegular = 0,
    CTFontLegibilityWeightBold = 1
};

CF_ASSUME_NONNULL_END

#endif /* CoreText.h */

#endif /* CTFontLegibilityWeight_h */
