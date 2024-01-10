//
//  OpenSwiftUI_SPI.h
//
//
//  Created by Kyle on 2024/1/9.
//

#ifndef OpenSwiftUI_SPI_h
#define OpenSwiftUI_SPI_h

#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
@interface UIApplication (OpenSwiftUI_SPI)
- (void)startedTest:(nullable NSString *)name;
- (void)finishedTest:(nullable NSString *)name;
- (void)failedTest:(nullable NSString *)name withFailure:(nullable NSError*)failure;
@end
#else

#endif

#endif /* OpenSwiftUI_SPI_h */
