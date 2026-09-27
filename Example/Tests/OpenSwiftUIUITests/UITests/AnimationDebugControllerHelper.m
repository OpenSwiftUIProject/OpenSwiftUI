//
//  AnimationDebugControllerHelper.m
//  OpenSwiftUIUITests

#import "AnimationDebugControllerHelper.h"
#import <objc/runtime.h>
#import <objc/message.h>

#if TARGET_OS_IPHONE

void superLayoutSubviews(Class cls) {
    ((void (*)(struct objc_super *, SEL))(void *)objc_msgSendSuper)(&((struct objc_super){(id)cls, (id)class_getSuperclass(cls)}), sel_registerName("layoutSubviews"));
}

#endif
