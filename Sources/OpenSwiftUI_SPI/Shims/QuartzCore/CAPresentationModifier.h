//
//  CAPresentationModifier.h
//  OpenSwiftUI_SPI
//
//  Status: Complete
//  Audited for 6.5.4

#ifndef CAPresentationModifier_h
#define CAPresentationModifier_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/QuartzCore.h>)

#import <QuartzCore/QuartzCore.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

// MARK: - CAPresentationModifierGroup

/// Private QuartzCore class that manages a group of presentation modifiers
/// sharing a single shared-memory region for efficient batch updates.
///
/// Available since iOS 12.4. Used by SwiftUI for async rendering and by
/// WebKit for off-main-thread animation updates.
///
/// Source: WebKit QuartzCoreSPI.h
@interface CAPresentationModifierGroup : NSObject

/// Create a group with a fixed capacity for modifier slots.
+ (instancetype)groupWithCapacity:(NSUInteger)capacity;

/// Flush all pending modifier values to the Render Server via atomic signal.
/// Safe to call from any thread.
- (void)flush;

/// Flush with a target timestamp for frame pacing.
- (void)flushWithTargetTime:(double)targetTime;

/// Flush locally (copy pending → current buffer) without notifying Render Server.
- (void)flushLocally;

/// Flush locally with target timestamp.
- (void)flushLocallyWithTargetTime:(double)targetTime;

/// Flush via CA::Transaction path. Must be called on the main thread.
- (void)flushWithTransaction;

/// Flush via CA::Transaction with target timestamp.
- (void)flushWithTransactionAndTargetTime:(double)targetTime;

/// Whether the group updates asynchronously (controls shmem header bit 30).
@property (nonatomic) BOOL updatesAsynchronously;

/// Number of modifiers currently in this group.
@property (nonatomic, readonly) NSUInteger count;

/// Maximum number of modifiers this group can hold.
@property (nonatomic, readonly) NSUInteger capacity;

@end

// MARK: - CAPresentationModifier

/// Private QuartzCore class that allows direct modification of CALayer
/// properties via shared memory, bypassing CATransaction.
///
/// Values written via `setValue:` are picked up by the Render Server on
/// the next frame without requiring a main-thread round-trip.
///
/// Available since iOS 12.4.
///
/// Source: WebKit QuartzCoreSPI.h
@interface CAPresentationModifier : NSObject

/// The target CALayer property keyPath (e.g. "opacity", "transform").
@property (nonatomic, copy, readonly) NSString *keyPath;

/// Whether this modifier is currently active.
@property (nonatomic, getter=isEnabled) BOOL enabled;

/// Whether the modifier value is additive (added to model value vs. replacing it).
@property (nonatomic, readonly) BOOL additive;

/// The group this modifier belongs to (nil for standalone modifiers).
@property (nonatomic, readonly, nullable) CAPresentationModifierGroup *group;

/// The current value.
@property (nonatomic, strong) id value;

/// Convenience initializer without a group (creates standalone shared memory).
- (instancetype)initWithKeyPath:(NSString *)keyPath
                   initialValue:(id)initialValue
                       additive:(BOOL)additive;

/// Convenience initializer with a group (allocates a slot in the group's shared memory).
- (instancetype)initWithKeyPath:(NSString *)keyPath
                   initialValue:(id)initialValue
                       additive:(BOOL)additive
                          group:(nullable CAPresentationModifierGroup *)group;

/// Designated initializer with full parameters.
- (instancetype)initWithKeyPath:(NSString *)keyPath
                   initialValue:(id)initialValue
                initialVelocity:(nullable id)initialVelocity
                       additive:(BOOL)additive
 preferredFrameRateRangeMaximum:(NSInteger)preferredFrameRateRangeMaximum
                          group:(nullable CAPresentationModifierGroup *)group;

/// Set a new value (thread-safe, writes to shared memory).
- (void)setValue:(id)value;

/// Set a new value with velocity for interpolation.
- (void)setValue:(id)value velocity:(nullable id)velocity;

- (instancetype)init NS_UNAVAILABLE;

@end

// MARK: - CALayer (PresentationModifiers)

@interface CALayer (OpenSwiftUI_PresentationModifiers)

/// The presentation modifiers currently attached to this layer.
@property (nonatomic, copy, nullable) NSArray<CAPresentationModifier *> *presentationModifiers;

/// Bind a presentation modifier to this layer.
/// Triggers a CA::Transaction; must be called on the main thread.
- (void)addPresentationModifier:(CAPresentationModifier *)modifier;

/// Remove a presentation modifier from this layer.
/// Triggers a CA::Transaction; must be called on the main thread.
- (void)removePresentationModifier:(CAPresentationModifier *)modifier;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* <QuartzCore/QuartzCore.h> */

#endif /* CAPresentationModifier_h */
