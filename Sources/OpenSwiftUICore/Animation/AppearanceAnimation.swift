//
//  AppearanceAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 2B78C51D4C716343C69656953A2BEA60 (SwiftUICore)

import Foundation

// MARK: - View + appearanceAnimation

extension View {
    nonisolated package func appearanceAnimation<V>(
        animation: Animation = Animation.default,
        strategy: AppearanceAnimationStrategy = .withAnimation,
        modifier: (Self, Bool) -> V
    ) -> some View where V: View {
        AppearanceAnimationView(
            content: self,
            from: modifier(self, false),
            to: modifier(self, true),
            animation: animation,
            strategy: strategy
        )
    }
}

// MARK: - AppearanceAnimationStrategy

package enum AppearanceAnimationStrategy: Hashable {
    case withAnimation
    case animationValue
}

// MARK: - AppearanceAnimationView

package struct AppearanceAnimationView<Content, Modified>: ConditionallyArchivableView where Content: View, Modified: View {
    var content: Content
    var from: Modified
    var to: Modified
    var animation: Animation
    var strategy: AppearanceAnimationStrategy

    package var body: some View {
        switch strategy {
        case .withAnimation:
            NormalBody_WithAnimation(view: self)
        case .animationValue:
            NormalBody_AnimationValue(view: self)
        }
    }

    package var archivedBody: some View {
        content.modifier(AnimationEffect(animation: displayListAnimation))
    }

    var displayListAnimation: (any DisplayList.AnyEffectAnimation)? {
        if let from = from as? ModifiedContent<Content, _OpacityEffect>,
           let to = to as? ModifiedContent<Content, _OpacityEffect> {
            return DisplayList.OpacityAnimation(from: from.modifier, to: to.modifier, animation: animation)
        } else if let from = from as? ModifiedContent<Content, _OffsetEffect>,
                  let to = to as? ModifiedContent<Content, _OffsetEffect> {
            return DisplayList.OffsetAnimation(from: from.modifier, to: to.modifier, animation: animation)
        } else if let from = from as? ModifiedContent<Content, _ScaleEffect>,
                  let to = to as? ModifiedContent<Content, _ScaleEffect> {
            return DisplayList.ScaleAnimation(from: from.modifier, to: to.modifier, animation: animation)
        } else if let from = from as? ModifiedContent<Content, _RotationEffect>,
                  let to = to as? ModifiedContent<Content, _RotationEffect> {
            return DisplayList.RotationAnimation(from: from.modifier, to: to.modifier, animation: animation)
        } else {
            return nil
        }
    }

    struct AnimationEffect: RendererEffect {
        var animation: (any DisplayList.AnyEffectAnimation)?

        func effectValue(size: CGSize) -> DisplayList.Effect {
            if let animation {
                .animation(animation)
            } else {
                .identity
            }
        }
    }

    struct NormalBody_WithAnimation: View {
        @State private var state = AnimationState()
        var view: AppearanceAnimationView

        var body: some View {
            (state.active ? view.to : view.from)
                .id(state.seed)
                .modifier(_AppearanceActionModifier(
                    appear: {
                        withAnimation(view.animation) {
                            state.active.toggle()
                        }
                    },
                    disappear: {
                        state.active = false
                        state.seed.unsafeIncrement()
                    }
                ))
        }

        struct AnimationState {
            var seed: UInt32 = 0
            var active: Bool = false
        }
    }

    struct NormalBody_AnimationValue: View {
        @State private var state = AnimationState()
        var view: AppearanceAnimationView

        var body: some View {
            (state.active ? view.to : view.from)
                .animation(view.animation, value: state.active)
                .id(state.seed)
                .modifier(_AppearanceActionModifier(
                    appear: {
                        state.active.toggle()
                    },
                    disappear: {
                        state.active = false
                        state.seed.unsafeIncrement()
                    }
                ))
        }

        struct AnimationState {
            var seed: UInt32 = 0
            var active: Bool = false
        }
    }
}
