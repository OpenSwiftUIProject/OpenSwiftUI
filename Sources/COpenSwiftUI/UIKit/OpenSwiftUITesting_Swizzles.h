//
//  OpenSwiftUITesting_Swizzles.h
//  COpenSwiftUI
//
//  Audited for 6.0.87
//  Status: Complete

#ifndef OpenSwiftUITesting_Swizzles_h
#define OpenSwiftUITesting_Swizzles_h

#include "OpenSwiftUIBase.h"

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

OPENSWIFTUI_EXPORT
void _PerformTestingSwizzles();

OPENSWIFTUI_EXPORT
void _SwizzleMethods(Class class, SEL originalSelector, SEL swizzledSelector);

#endif /* OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION */

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OpenSwiftUITesting_Swizzles_h */
