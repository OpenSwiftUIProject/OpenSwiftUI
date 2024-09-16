//
//  TLS.c
//  
//
//

#include "TLS.h"

static _Thread_local int64_t _perThreadUpdateCount = 0;
static _Thread_local void * _perThreadTransactionData = NULL;
static _Thread_local void * _perThreadGeometryProxyData = NULL;

void _setThreadTransactionData(void * data) {
    _perThreadTransactionData = data;
}

void * _threadTransactionData(void) {
    return _perThreadTransactionData;
}
