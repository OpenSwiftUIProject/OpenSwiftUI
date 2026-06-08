//
//  CategoryGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: BD70527AFCE562B27D7DD6D56847C2B8 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - Gesture + category

extension Gesture {
    package func category(
        _ category: GestureCategory,
        includeChildren: Bool = true
    ) -> ModifierGesture<CategoryGesture<Value>, Self> {
        modifier(CategoryGesture(category: category, includeChildren: includeChildren))
    }

    package func categoryReader(
        _ callback: @escaping (GestureCategory) -> Void
    ) -> ModifierGesture<GestureCategoryReader<Value>, Self> {
        modifier(GestureCategoryReader(callback: callback))
    }
}

// MARK: - CategoryGesture

package struct CategoryGesture<Value>: GestureModifier {
    private struct Combiner<Wrapped>: Rule {
        @Attribute var modifier: CategoryGesture<Wrapped>
        @OptionalAttribute var existingCategory: GestureCategory?

        typealias Value = GestureCategory

        var value: GestureCategory {
            var category = modifier.category
            if modifier.includeChildren {
                category.formUnion(existingCategory ?? [])
            }
            return category
        }
    }

    package var category: GestureCategory

    package var includeChildren: Bool

    package static func _makeGesture(
        modifier: _GraphValue<CategoryGesture<Value>>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<Value>
    ) -> _GestureOutputs<Value> {
        var outputs = body(inputs)
        guard inputs.preferences.containsGestureCategory else {
            return outputs
        }
        outputs.preferences.gestureCategory = Attribute(Combiner(
            modifier: modifier.value,
            existingCategory: OptionalAttribute(outputs.preferences.gestureCategory)
        ))
        return outputs
    }

    package typealias BodyValue = Value
}

// MARK: - GestureCategoryReader

package struct GestureCategoryReader<Value>: GestureModifier {
    private struct Reader<Wrapped>: Rule {
        @Attribute var modifier: GestureCategoryReader<Wrapped>
        @OptionalAttribute var gestureCategory: GestureCategory?

        typealias Value = GestureCategory

        var value: GestureCategory {
            Update.enqueueAction(reason: nil) {
                modifier.callback(gestureCategory ?? [])
            }
            return gestureCategory ?? []
        }
    }

    package var callback: (GestureCategory) -> Void

    package init(callback: @escaping (GestureCategory) -> Void) {
        self.callback = callback
    }

    package static func _makeGesture(
        modifier: _GraphValue<GestureCategoryReader<Value>>,
        inputs: _GestureInputs,
        body: (_GestureInputs) -> _GestureOutputs<Value>
    ) -> _GestureOutputs<Value> {
        var outputs = body(inputs)
        guard inputs.preferences.containsGestureCategory else {
            return outputs
        }
        outputs.preferences.gestureCategory = Attribute(Reader(
            modifier: modifier.value,
            gestureCategory: OptionalAttribute(outputs.preferences.gestureCategory)
        ))
        return outputs
    }

    package typealias BodyValue = Value
}
