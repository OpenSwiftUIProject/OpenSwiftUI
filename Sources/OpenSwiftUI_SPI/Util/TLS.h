//
//  TLS.h
//  OpenSwiftUI_SPI
//
//  Audited for RELEASE_2024
//  Status: Complete

#ifndef TLS_h
#define TLS_h

#include "OpenSwiftUIBase.h"

OPENSWIFTUI_EXPORT
void _setThreadTransactionData(void  * _Nullable data);

OPENSWIFTUI_EXPORT
void * _Nullable _threadTransactionData(void);

OPENSWIFTUI_EXPORT
uint32_t _threadTransactionID(bool increase);

#endif /* TLS_h */
