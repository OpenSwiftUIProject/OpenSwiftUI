//
//  CAFilterPrivate.h
//  OpenSwiftUI_SPI

#ifndef CAFilterPrivate_h
#define CAFilterPrivate_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

#import <QuartzCore/CoreAnimation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface CAFilter : NSObject

+ (NSArray<NSString *> *)filterTypes;
+ (instancetype)filterWithName:(NSString *)name;
+ (instancetype)filterWithType:(NSString *)type;

@end

OPENSWIFTUI_EXPORT CAFilter *_CAFilterCreate(uint32_t type) OPENSWIFTUI_SWIFT_NAME(CAFilterCreate(_:));
OPENSWIFTUI_EXPORT id _Nullable _CAFilterGetInput(CAFilter *filter, uint32_t key) OPENSWIFTUI_SWIFT_NAME(CAFilterGetInput(_:key:));
OPENSWIFTUI_EXPORT void _CAFilterSetInput(CAFilter * _Nullable filter, id _Nullable value, uint32_t key) OPENSWIFTUI_SWIFT_NAME(CAFilterSetInput(_:_:_:));
OPENSWIFTUI_EXPORT NSMutableArray<CAFilter *> *_CAFilterArrayCreate(void) OPENSWIFTUI_SWIFT_NAME(CAFilterArrayCreate());
OPENSWIFTUI_EXPORT void _CAFilterArrayAppend(NSMutableArray<CAFilter *> *array, CAFilter *filter) OPENSWIFTUI_SWIFT_NAME(CAFilterArrayAppend(_:_:));

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* CoreAnimation.h */

#endif /* CAFilterPrivate_h */
