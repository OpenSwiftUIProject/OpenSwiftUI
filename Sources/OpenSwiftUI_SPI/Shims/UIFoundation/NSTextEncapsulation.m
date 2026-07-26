//
//  NSTextEncapsulation.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "NSTextEncapsulation.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

@implementation NSTextEncapsulation (OpenSwiftUICore)

- (void)setPlatformColor:(NSObject * _Nullable)platformColor {
    self.color = platformColor;
}

@end

#endif
