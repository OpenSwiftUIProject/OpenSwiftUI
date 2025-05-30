//
//  TLS.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.4.41
//  Status: Complete

#ifndef TLS_h
#define TLS_h

#include "OpenSwiftUIBase.h"

OPENSWIFTUI_EXPORT
void _setThreadGeometryProxyData(void  * _Nullable data);

OPENSWIFTUI_EXPORT
void * _Nullable _threadGeometryProxyData(void);

OPENSWIFTUI_EXPORT
uint32_t _threadTransactionID(bool increase);


OPENSWIFTUI_EXPORT
void _setThreadTransactionData(void  * _Nullable data);

OPENSWIFTUI_EXPORT
void * _Nullable _threadTransactionData(void);

OPENSWIFTUI_EXPORT
void _setThreadLayoutData(void * _Nullable data);

OPENSWIFTUI_EXPORT
void * _Nullable _threadLayoutData(void);

#endif /* TLS_h */
