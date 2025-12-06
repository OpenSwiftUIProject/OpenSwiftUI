//
//  NSStringDrawingContext.m
//  OpenSwiftUI_SPI

#import "NSStringDrawingContext.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

void _NSStringDrawingContextSetBaselineOffset(NSStringDrawingContext *context, CGFloat offset) {
    context.baselineOffset = offset;
}

void _NSStringDrawingContextSetFirstBaselineOffset(NSStringDrawingContext *context, CGFloat offset) {
    context.firstBaselineOffset = offset;
}

#endif
