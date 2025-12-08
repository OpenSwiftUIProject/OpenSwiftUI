//
//  NSStringDrawing_Private.m
//  OpenSwiftUI_SPI

#import "NSStringDrawing_Private.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

void _NSStringDrawingContextSetBaselineOffset(NSStringDrawingContext *context, CGFloat offset) {
    context.baselineOffset = offset;
}

void _NSStringDrawingContextSetFirstBaselineOffset(NSStringDrawingContext *context, CGFloat offset) {
    context.firstBaselineOffset = offset;
}

#endif
