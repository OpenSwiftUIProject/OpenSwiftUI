import Foundation

public protocol DynamicProperty {
    static func _makeProperty<V>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<V>, fieldOffset: Int, inputs: inout _GraphInputs)
    static var _propertyBehaviors: UInt32 { get }
    mutating func update()
}

extension DynamicProperty {
    public static func _makeProperty<V>(in buffer: inout _DynamicPropertyBuffer, container: _GraphValue<V>, fieldOffset: Int, inputs: inout _GraphInputs) {
        
    }
    public mutating func update() {}
      public static var _propertyBehaviors: UInt32 {
          0
      }
}
