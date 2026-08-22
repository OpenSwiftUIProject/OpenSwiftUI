//
//  DateFormattingContext.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "DateFormattingContext.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

@implementation OpenSwiftUIDateFormattingContext

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

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
