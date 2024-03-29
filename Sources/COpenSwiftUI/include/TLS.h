//
//  TLS.h
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#ifndef TLS_h
#define TLS_h

#include "OpenSwiftUIBase.h"

OPENSWIFTUI_EXPORT
void _setThreadTransactionData(void  * _Nullable data);

OPENSWIFTUI_EXPORT
void * _Nullable _threadTransactionData(void);

#endif /* TLS_h */
