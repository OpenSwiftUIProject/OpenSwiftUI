/*
* This header is generated by classdump-dyld 1.0
* on Friday, January 21, 2022 at 6:51:04 AM Pacific Standard Time
* Operating System: Version 15.2.1 (Build 19C63)
* Image Source: /System/Library/Frameworks/CoreServices.framework/CoreServices
* classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
*/

#import <Foundation/Foundation.h>
#import "_LSOpenConfiguration.h"

@interface LSApplicationWorkspace : NSObject
+(nullable instancetype)defaultWorkspace;
-(void)openURL:(nonnull NSURL *)url configuration:(nonnull _LSOpenConfiguration *)config completionHandler:(void (^ _Nonnull)(BOOL))completion;

@end
