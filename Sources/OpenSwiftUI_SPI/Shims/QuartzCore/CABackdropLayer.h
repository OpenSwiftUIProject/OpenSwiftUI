//  CABackdropLayer.h
//  OpenSwiftUI_SPI

#ifndef CABackdropLayer_h
#define CABackdropLayer_h

#if __has_include(<QuartzCore/CALayer.h>)

#import <Foundation/Foundation.h>
#import <QuartzCore/CALayer.h>
#import <TargetConditionals.h>

@interface CABackdropLayer : CALayer

@property (nonatomic) CGFloat scale;
@property (nonatomic) BOOL allowsInPlaceFiltering;
@property (nonatomic, copy, nullable) NSString *groupName;
#if TARGET_OS_VISION
@property (nonatomic) BOOL captureOnly;
#endif

@end

#endif /* __has_include(<QuartzCore/CALayer.h>) */

#endif /* CABackdropLayer_h */
