//
//  ObjectCache.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete
//  ID: FCB2944DC319042A861E82C8B244E212

final package class ObjectCache<Key, Value> where Key: Hashable {
    let constructor: (Key) -> Value
    
    @AtomicBox
    private var data: Data
    
    @inlinable
    package init(constructor: @escaping (Key) -> Value) {
        self.constructor = constructor
        self.data = Data()
    }
    
    final package subscript(key: Key) -> Value {
        let hash = key.hashValue
        let bucket = (hash & ((1 << 3) - 1)) << 2
        var targetOffset: Int = 0
        var diff: Int32 = Int32.min
        let value = $data.access { data -> Value? in
            for offset in 0 ..< 3 {
                let index = bucket + offset
                if let itemData = data.table[index].data {
                    if itemData.hash == hash, itemData.key == key {
                        data.clock &+= 1
                        data.table[index].used = data.clock
                        return itemData.value
                    } else {
                        if diff < Int32(bitPattern: data.clock &- data.table[index].used) {
                            targetOffset = offset
                            diff = Int32.max
                        }
                    }
                } else {
                    if diff != Int32.max {
                        targetOffset = offset
                        diff = Int32.max
                    }
                }
            }
            return nil
        }
        if let value {
            return value
        } else {
            let value = constructor(key)
            $data.access { data in
                data.clock += 1
                data.table[bucket + targetOffset] = Item(data: (key, hash, value), used: data.clock)
            }
            return value
        }
    }
    
    private struct Item {
        var data: (key: Key, hash: Int, value: Value)?
        var used: UInt32
        
        init(data: (key: Key, hash: Int, value: Value)?, used: UInt32) {
            self.data = data
            self.used = used
        }
    }
    
    private struct Data {
        var table: [Item]
        var clock: UInt32
        
        init() {
            self.table = Array(repeating: Item(data: nil, used: 0), count: 32)
            self.clock = 0
        }
    }
}
