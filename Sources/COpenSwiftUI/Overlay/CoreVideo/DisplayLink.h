//
//  DisplayLink.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef DisplayLink_h
#define DisplayLink_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_OSX

#include <CoreFoundation/CoreFoundation.h>
#include <CoreVideo/CoreVideo.h>

typedef struct DisplayLink * OPENSWIFTUI_SWIFT_STRUCT DisplayLinkRef OPENSWIFTUI_SWIFT_NAME(DisplayLink);

typedef void(^ DisplayLinkCallback)(DisplayLinkRef __nonnull, double);

extern DisplayLinkRef __nullable DisplayLinkCreate(CGDirectDisplayID displayID, DisplayLinkCallback __nonnull callback);

extern void DisplayLinkDestroy(DisplayLinkRef __nonnull displayLink);

extern void DisplayLinkSetNextTime(DisplayLinkRef __nonnull displayLink, double nextTime);

extern double DisplayLinkGetNextTime(DisplayLinkRef __nonnull displayLink);

#endif

#endif /* DisplayLink_h */
