//
//  ProtocolDescriptor.c
//  COpenSwiftUI
//
//  Audit for 6.5.4
//  Status: Complete

#include "ProtocolDescriptor.h"

OPENSWIFTUI_EXPORT
const void *$s11OpenSwiftUI5SceneMp;

OPENSWIFTUI_EXPORT
const void *$s11OpenSwiftUI8CommandsMp;

const void *_sceneProtocolDescriptor(void) {
    return &$s11OpenSwiftUI5SceneMp;
}

const void *_commandsProtocolDescriptor(void) {
    return &$s11OpenSwiftUI8CommandsMp;
}

#if OPENSWIFTUI_OPENCOMBINE
OPENSWIFTUI_EXPORT
const void *$s11OpenCombine16ObservableObjectMp;

const void *_observableObjectProtocolDescriptor(void) {
    return &$s11OpenCombine16ObservableObjectMp;
}

#else
OPENSWIFTUI_EXPORT
const void *$s7Combine16ObservableObjectMp;

const void *_observableObjectProtocolDescriptor(void) {
    return &$s7Combine16ObservableObjectMp;
}
#endif
