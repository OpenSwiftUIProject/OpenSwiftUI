//
//  NSTextField_Private.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef NSTextField_Private_h
#define NSTextField_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<AppKit/AppKit.h>)

#import <AppKit/AppKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSTextField (OpenSwiftUI_SPI)
- (BOOL)_performMultiPassIntrinsicSize;
- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex
    OPENSWIFTUI_SWIFT_NAME(textView(_:clickedOnLink:at:));
@end

@interface NSTextFieldCell (OpenSwiftUI_SPI)
- (nullable id)_selectOrEdit:(const CGRect *)frame
                    inView:(nullable NSView *)controlView
                    target:(nullable id)target
                    editor:(nullable NSText *)editor
                     event:(nullable NSEvent *)event
                     start:(NSInteger)start
                       end:(NSInteger)end
    OPENSWIFTUI_SWIFT_NAME(_selectOrEdit(_:in:target:editor:event:start:end:));
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* __has_include(<AppKit/AppKit.h>) */

#endif /* NSTextField_Private_h */
