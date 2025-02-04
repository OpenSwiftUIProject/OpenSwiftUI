//
//  ViewListTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct _ViewList_IteratorStyleTests {
    @Test
    func granularityAndApplyGranularity() {
        var iteratorStyle = _ViewList_IteratorStyle()
        #expect(iteratorStyle.granularity == 1)
        #expect(iteratorStyle.applyGranularity == false)
        
        iteratorStyle.granularity = 2
        iteratorStyle.applyGranularity = true
        
        #expect(iteratorStyle.granularity == 2)
        #expect(iteratorStyle.applyGranularity == true)
    }
    
    @Test(arguments: [
        (_ViewList_IteratorStyle(granularity: 1), 0, 0, 0),
        (_ViewList_IteratorStyle(granularity: 1), 1, 1, 1),
        (_ViewList_IteratorStyle(granularity: 1), 2, 2, 2),
        (_ViewList_IteratorStyle(granularity: 2), 0, 0, 0),
        (_ViewList_IteratorStyle(granularity: 2), 1, 0, 2),
        (_ViewList_IteratorStyle(granularity: 2), 2, 2, 2),
        (_ViewList_IteratorStyle(granularity: 2), 3, 2, 4),
        (_ViewList_IteratorStyle(granularity: 3), 0, 0, 0),
        (_ViewList_IteratorStyle(granularity: 3), 1, 0, 3),
        (_ViewList_IteratorStyle(granularity: 3), 2, 0, 3),
        (_ViewList_IteratorStyle(granularity: 3), 3, 3, 3),
        (_ViewList_IteratorStyle(granularity: 3), 4, 3, 6),
    ])
    func alignment(
        _ iteratorStyle: _ViewList_IteratorStyle,
        _ initialValue: Int,
        _ expectedPrevious: Int,
        _ expectedNext: Int
    ) {
        var previous = initialValue
        iteratorStyle.alignToPreviousGranularityMultiple(&previous)
        #expect(previous == expectedPrevious)
        
        var next = initialValue
        iteratorStyle.alignToNextGranularityMultiple(&next)
        #expect(next == expectedNext)
    }
}
