//
//  NSTextGraphicsContextInternal.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef NSTextGraphicsContextInternal_h
#define NSTextGraphicsContextInternal_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include "NSTextGraphicsContext.h"

@protocol NSTextGraphicsContextInternal <NSTextGraphicsContext>
@required
-(void)saveGraphicsState;
-(void)restoreGraphicsState;
@optional
- (void)becomeCurrentGraphicsContextDuringBlock:(void (^)(void))block;
@end

#endif

#endif /* NSTextGraphicsContextInternal_h */


