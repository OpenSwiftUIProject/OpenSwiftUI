//
//  CoreUI+UIUserInterfaceIdiom.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.4.41
//  Status: Complete

#ifndef CoreUI_UIUserInterfaceIdiom_h
#define CoreUI_UIUserInterfaceIdiom_h

#include "OpenSwiftUIBase.h"

#if __has_include(<UIKit/UIKit.h>)

#import <UIKit/UIKit.h>

OPENSWIFTUI_EXPORT
NSInteger _CUIIdiomForIdiom(UIUserInterfaceIdiom idiom);

OPENSWIFTUI_EXPORT
NSInteger _CUISubtypeForIdiom(UIUserInterfaceIdiom idiom);

#endif /* __has_include(<UIKit/UIKit.h>) */

#endif /* CoreUI_UIUserInterfaceIdiom_h */
