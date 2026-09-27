//
//  AXChartDescriptor_Private.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef AXChartDescriptor_Private_h
#define AXChartDescriptor_Private_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Accessibility/Accessibility.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface AXChartDescriptor (OpenSwiftUI_SPI)
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* AXChartDescriptor_Private_h */
