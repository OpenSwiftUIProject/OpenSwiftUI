//
//  AnimationDebugControllerHelper.h
//  OpenSwiftUIUITests

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (OpenSwiftUIUITests)
@property(nonatomic, readonly, nullable) UIViewController *_viewControllerForAncestor;
@end

void superLayoutSubviews(Class cls);

NS_ASSUME_NONNULL_END


#endif
