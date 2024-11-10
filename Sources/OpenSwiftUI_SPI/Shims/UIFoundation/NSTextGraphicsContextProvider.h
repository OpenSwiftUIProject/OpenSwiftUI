//
//  NSTextGraphicsContextProvider.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef NSTextGraphicsContextProvider_h
#define NSTextGraphicsContextProvider_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include "NSTextGraphicsContext.h"

@protocol NSTextGraphicsContextProvider <NSObject>

@required
+ (id<NSTextGraphicsContext>)graphicsContextForApplicationFrameworkContext:(id)context;
@optional
+ (Class)colorClassForApplicationFrameworkContext:(id)context; // FIXME
@end

@interface NSTextGraphicsContextProvider : NSObject
+ (Class)textGraphicsContextProviderClass;
+ (void)setTextGraphicsContextProviderClass:(Class)cls;
+ (BOOL)textGraphicsContextProviderClassRespondsToColorQuery;
+ (Class)__defaultColorClass;
+ (Class)textGraphicsContextClass;
+ (void)setTextGraphicsContextClass:(Class)cls;
+ (void)setCurrentTextGraphicsContext:(id)context duringBlock:(void (^)(void))block;
@end

#endif

#endif /* NSTextGraphicsContextProvider_h */
