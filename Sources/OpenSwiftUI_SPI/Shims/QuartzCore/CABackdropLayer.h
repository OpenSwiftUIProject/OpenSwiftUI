//  CABackdropLayer.h
//  OpenSwiftUI_SPI

#ifndef CABackdropLayer_h
#define CABackdropLayer_h

#if __has_include(<QuartzCore/CALayer.h>)

#import <Foundation/Foundation.h>
#import <QuartzCore/CALayer.h>

@interface CABackdropLayer : CALayer

@property (nonatomic) CGFloat scale;
@property (nonatomic) BOOL allowsInPlaceFiltering;
@property (nonatomic, copy, nullable) NSString *groupName;

@end

#endif /* __has_include(<QuartzCore/CALayer.h>) */

#endif /* CABackdropLayer_h */
