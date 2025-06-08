//
//  CoreUI+UIUserInterfaceIdiom.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.4.41
//  Status: Complete

#ifndef CoreUI_UIUserInterfaceIdiom_h
#define CoreUI_UIUserInterfaceIdiom_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_IOS && OPENSWIFTUI_LINK_COREUI

#import <UIKit/UIKit.h>
#import <CoreUI/CUITypes.h>

OPENSWIFTUI_EXPORT
CUIDeviceIdiom _CUIIdiomForIdiom(UIUserInterfaceIdiom idiom);

OPENSWIFTUI_EXPORT
CUISubtype _CUISubtypeForIdiom(UIUserInterfaceIdiom idiom);

#endif /* OPENSWIFTUI_TARGET_OS_IOS && OPENSWIFTUI_LINK_COREUI */

#endif /* CoreUI_UIUserInterfaceIdiom_h */
