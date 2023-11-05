//
//  TLS.h
//  
//
//  Created by Kyle on 2023/11/5.
//

#ifndef TLS_h
#define TLS_h

#include <OpenFoundation/OpenFoundation.h>
#include <stdio.h>

OF_EXPORT
void _setThreadTransactionData(void  * _Nullable data);

OF_EXPORT
void * _Nullable _threadTransactionData(void);

#endif /* TLS_h */
