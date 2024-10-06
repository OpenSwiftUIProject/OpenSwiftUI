//
//  BindingTests.swift
//  OpenSwiftUITests

@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
@testable import OpenSwiftUICore
import Testing

struct BindingTests {
    @Test("Test Binding.init(get:set:)")
    func initWithGetterSetter() {
        var storage = 0
        let binding = Binding {
            storage
        } set: { newValue in
            storage = newValue
        }
        #expect(binding.wrappedValue == 0)
        
        let newValue = 10
        binding.wrappedValue = newValue
        #expect(binding.wrappedValue == newValue)
        #expect(storage == newValue)
    }
    
    @Test("Test Binding.init(get:set:) with transaction")
    func initWithGetterSetterWithTransaction() {
        var storage = 0
        var transaction = Transaction(animation: .default)
        
        let binding = Binding {
            storage
        } set: { newValue, newTransaction in
            storage = newValue
            transaction = newTransaction
        }
        
        #expect(binding.wrappedValue == 0)
        #expect(storage == 0)
        #expect(transaction.animation == .default)

        binding.wrappedValue = 10
        #expect(binding.wrappedValue == 10)
        #expect(storage == 10)
        #expect(transaction.animation == nil)
    }
    
    @Test("Test Binding.constant")
    func initWithConstantValue() {
        let binding = Binding.constant(0)
        #expect(binding.location.wasRead == true)
        binding.location.wasRead = false
        #expect(binding.location.wasRead == true)
        binding.wrappedValue = 5
        #expect(binding.wrappedValue == 0)
    }
    
    @Test("Test Binding's projectedValue")
    func bindingProjectingValue() {
        struct T {
            var name: String
        }
        
        let binding = Binding.constant(T(name: "test"))
        #expect(binding.location === binding.projectedValue.location)
        
        let newBinding = Binding(projectedValue: binding)
        #expect(binding.location === newBinding.location)

        let nameBinding = binding.name
        #expect(nameBinding.wrappedValue == "test")
    }
    
    @Test
    func initBindingToOptionalBinding() {
        var storage = 0
        let baseBinding = Binding {
            storage
        } set: { newValue in
            storage = newValue
        }
        #expect(baseBinding.wrappedValue == 0)
            
        let optionalBinding: Binding<Int?> = Binding(baseBinding)
        #expect(optionalBinding.wrappedValue == 0)
            
        optionalBinding.wrappedValue = 10
        #expect(optionalBinding.wrappedValue == 0)
        storage = 20
        #expect(optionalBinding.wrappedValue == 20)
        optionalBinding.wrappedValue = nil
        #expect(optionalBinding.wrappedValue == 20)
    }
    
    // Make block executed in a context where `GraphHost.isUpdating` is true
    private func updatingContext(_ closure: @escaping ()-> Void) {
        // FIXME: uncomment it when `GraphHost.isUpdating` is supported
        // closure()
    }
    
    @Test("Test Binding.init?(_:)")
    func initWithBindingOptionalValue() {
        struct FunctionalLocationWithWasRead<Value>: Location {
            static func == (lhs: FunctionalLocationWithWasRead<Value>, rhs: FunctionalLocationWithWasRead<Value>) -> Bool {
                false
            }
            
            var getValue: () -> Value
            var setValue: (Value, Transaction) -> Void
            var wasRead = false
            func get() -> Value { getValue() }
            func set(_ value: Value, transaction: Transaction) { setValue(value, transaction) }
        }
        class Wrapper {
            var storage: Int?
        }
        
        let wrapper = Wrapper()
        let location = LocationBox(FunctionalLocationWithWasRead(getValue: {
            wrapper.storage
        }, setValue: { newValue, _ in
            wrapper.storage = newValue
        }))
        
        _ = {
            wrapper.storage = nil
            let baseBinding = Binding(value: location.get(), location: location)
            #expect(baseBinding.location.wasRead == false)
            #expect(GraphHost.isUpdating == false)
            
            // _value: nil
            // location.get(): nil
            // GraphHost.isUpdating: false
            // - location.get()
            let binding1 = Binding(baseBinding)
            #expect(binding1 == nil)
            
            wrapper.storage = 0
            // _value: nil
            // location.get(): 0
            // GraphHost.isUpdating: false
            // - location.get()

            // MARK: Expected a forceUnwrap failure.

            // swift-testing is tracking it via https://github.com/apple/swift-testing/issues/157
            // #expectCrash(Binding(baseBinding))
            
            updatingContext {
                #expect(GraphHost.isUpdating == true)
                wrapper.storage = nil
                // _value: nil
                // location.get(): nil
                // GraphHost.isUpdating: true
                // - wasRead & _value
                let binding3 = Binding(baseBinding)
                #expect(baseBinding.location.wasRead == true)
                #expect(binding3 == nil)
                baseBinding.location.wasRead = false
                #expect(baseBinding.location.wasRead == false)
                
                wrapper.storage = 0
                // _value: nil
                // location.get(): 0
                // GraphHost.isUpdating: true
                // - wasRead & _value
                let binding4 = Binding(baseBinding)
                #expect(baseBinding.location.wasRead == true)
                #expect(binding4 == nil)
                baseBinding.location.wasRead = false
                #expect(baseBinding.location.wasRead == false)
            }
        }()
        
        _ = {
            wrapper.storage = 0
            let baseBinding = Binding(value: location.get(), location: location)
            #expect(baseBinding.location.wasRead == false)
            #expect(GraphHost.isUpdating == false)
            
            // _value: 0
            // location.get(): 0
            // GraphHost.isUpdating: false
            // - location.get()
            let binding1 = Binding(baseBinding)
            #expect(binding1 != nil)
            
            wrapper.storage = nil
            // _value: 0
            // location.get(): nil
            // GraphHost.isUpdating: false
            // - location.get()
            let binding2 = Binding(baseBinding)
            #expect(binding2 == nil)
            
            updatingContext {
                #expect(GraphHost.isUpdating == true)
                wrapper.storage = 0
                // _value: 0
                // location.get(): 0
                // GraphHost.isUpdating: true
                // - wasRead & _value
                let binding3 = Binding(baseBinding)
                #expect(baseBinding.location.wasRead == true)
                #expect(binding3 != nil)
                baseBinding.location.wasRead = false
                #expect(baseBinding.location.wasRead == false)
                
                wrapper.storage = nil
                // _value: 0
                // location.get(): nil
                // GraphHost.isUpdating: true
                // - wasRead & _value
                let binding4 = Binding(baseBinding)
                #expect(baseBinding.location.wasRead == true)
                #expect(binding4 != nil)
                baseBinding.location.wasRead = false
                #expect(baseBinding.location.wasRead == false)
            }
        }()
    }
    
    @Test
    func initToAnyHashableBinding() {
        var storage = 0
        let baseBinding = Binding {
            storage
        } set: { newValue in
            storage = newValue
        }
        #expect(baseBinding.wrappedValue == 0)
        
        let anyHashableBinding: Binding<AnyHashable> = Binding(baseBinding)
        #expect(anyHashableBinding.wrappedValue == AnyHashable(0))
        anyHashableBinding.wrappedValue = 10
        #expect(anyHashableBinding.wrappedValue == AnyHashable(0))
        storage = 20
        #expect(anyHashableBinding.wrappedValue == AnyHashable(20))
        // #expectCrash(optionalBinding.wrappedValue = 0.0)
    }
    
    @Test
    func identifiableValue() {
        struct Storage: Identifiable {
            var id: Int
            
            var bindableID: Int {
                get { id }
                set { id = newValue }
            }

            var name: String
        }
        var storage = Storage(id: 0, name: "")
        let binding = Binding {
            storage
        } set: { newValue in
            storage = newValue
        }
        #expect(type(of: binding.id) == Int.self)
        #expect(type(of: binding.bindableID) == Binding<Int>.self)
        #expect(type(of: binding.name) == Binding<String>.self)
        #expect(binding.id == storage.id)
    }
}
