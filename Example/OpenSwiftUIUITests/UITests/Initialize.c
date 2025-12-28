//
//  Initialize.c
//  OpenSwiftUIUITests
//
//  Created by Kyle on 12/29/25.
//

#include "Initialize.h"
#include <stdio.h>

extern void OpenSwiftUIUITests_InitializeSwift(void);

static void OpenSwiftUIUITests_Initialize(void) {
    OpenSwiftUIUITests_InitializeSwift();
}
