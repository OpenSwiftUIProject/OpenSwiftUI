//
//  TraceID.h
//  OpenSwiftUI_SPI

#ifndef TraceID_h
#define TraceID_h

#include "OpenSwiftUIBase.h"
#include <stdatomic.h>

static inline uint32_t _incrementTraceIDThreadSafe(uint32_t *traceID) {
    uint32_t old = atomic_fetch_add_explicit(
        (_Atomic(uint32_t) *)traceID,
        2u,
        memory_order_relaxed
    );
    return (old >> 1) + 1u;
}

#endif /* TraceID_h */
