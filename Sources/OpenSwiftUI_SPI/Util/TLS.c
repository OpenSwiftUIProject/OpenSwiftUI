//
//  TLS.c
//  OpenSwiftUI_SPI
//
//  Audited for 6.4.41
//  Status: Complete

#include "TLS.h"
#include <stdatomic.h>

static _Thread_local void * _perThreadGeometryProxyData = NULL;
static _Thread_local int64_t _perThreadUpdateCount = 0;
static _Thread_local uint32_t _perThreadTransactionID = 0;
static _Thread_local void * _perThreadTransactionData = NULL;
static _Thread_local void * _perThreadLayoutData = NULL;

void _setThreadGeometryProxyData(void * data) {
    _perThreadGeometryProxyData = data;
}

void * _threadGeometryProxyData(void) {
    return _perThreadGeometryProxyData;
}

uint32_t _threadTransactionID(bool increase) {
    if (!increase && _perThreadTransactionID != 0) {
        return _perThreadTransactionID;
    } else {
        static atomic_int last_id = 0;
        uint32_t result = atomic_fetch_add_explicit(&last_id, 1, memory_order_relaxed);
        result += 1;
        _perThreadTransactionID = result;
        return result;
    }
}

void _setThreadTransactionData(void * data) {
    _perThreadTransactionData = data;
}

void * _threadTransactionData(void) {
    return _perThreadTransactionData;
}

void _setThreadLayoutData(void * data) {
    _perThreadLayoutData = data;
}

void *_threadLayoutData(void) {
    return _perThreadLayoutData;
}
