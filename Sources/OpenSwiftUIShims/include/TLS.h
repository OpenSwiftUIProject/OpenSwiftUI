//
//  TLS.h
//  
//
//  Created by Kyle on 2023/11/5.
//

#ifndef TLS_h
#define TLS_h

#include "OpenSwiftUIBase.h"

OPENSWIFTUI_EXPORT
void _setThreadTransactionData(void  * _Nullable data);

OPENSWIFTUI_EXPORT
void * _Nullable _threadTransactionData(void);

#endif /* TLS_h */
