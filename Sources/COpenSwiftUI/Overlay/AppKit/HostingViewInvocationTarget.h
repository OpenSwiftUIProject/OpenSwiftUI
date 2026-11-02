//
//  HostingViewInvocationTarget.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef HostingViewInvocationTarget_h
#define HostingViewInvocationTarget_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_OSX

#import <Foundation/Foundation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

/// A forwarding target for command selectors registered by NSHostingView.
///
/// NSHostingView uses this proxy for registered selectors that its superclass
/// does not implement. Each forwarded action must return void and take one
/// object argument. The proxy passes the selector to its handler and ignores
/// the sender argument.
///
/// The host's handler captures the host weakly and looks up the current command
/// action on each call. The host handles command validation.
OPENSWIFTUI_SWIFT_NAME(_TSHostingViewInvocationTarget)
@interface _OpenSwiftUITSHostingViewInvocationTarget : NSProxy

/// Creates a proxy that copies and retains the given selector handler.
///
/// @param handler The block to call with the selector of a forwarded command.
- (instancetype)initWithHandler:(void (^)(SEL))handler;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_OSX */

#endif /* HostingViewInvocationTarget_h */
