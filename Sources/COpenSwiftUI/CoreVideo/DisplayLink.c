//
//  DisplayLink.c
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#include "DisplayLink.h"

#if OPENSWIFTUI_TARGET_OS_OSX

#include <os/lock.h>
#include <QuartzCore/QuartzCore.h>
#include <stdatomic.h>

extern void CVDisplayLinkSetPaused(CVDisplayLinkRef displayLink, bool paused);
static void remove_link(DisplayLinkRef displayLink);

typedef struct DisplayLinkManager {
    struct DisplayLinkManager *nextManager;
    
    CGDirectDisplayID displayID;
    
    uint32_t _padding1;
    
    CVDisplayLinkRef displayLink;
    
    struct DisplayLink *listHead;
    
    uint32_t totalDisplayLinks;
    
    uint32_t pausedDisplayLinks;
    
    uint32_t state;
    
    uint32_t _padding2;
    
    _Atomic uint64_t timestamp;
} DisplayLinkManager;

struct DisplayLink {
    uint32_t unknown_field_1;
    
    uint32_t _padding1;
    
    struct DisplayLinkManager *manager;
    
    struct DisplayLink *nextDisplayLink;
    
    DisplayLinkCallback callback;
    
    double nextTime;
    
    uint32_t state;
    
    struct {
        uint8_t isScheduled;
        uint8_t isDestroyed;
        uint16_t _padding2;
    } flags;
};

static os_unfair_lock link_lock = OS_UNFAIR_LOCK_INIT;
static dispatch_queue_t link_queue = NULL;
static DisplayLinkManager *link_list = NULL;

static void dispatch_items(void *context) {
    DisplayLinkManager *manager = (DisplayLinkManager *)context;
    
    double callback_time = *(double*)&manager->timestamp;
    
    os_unfair_lock_lock(&link_lock);
    
    DisplayLinkRef *links_to_process = NULL;
    
    size_t num_links = 0;
    
    struct DisplayLink *current = manager->listHead;
    size_t count = 0;
    while (current) {
        count++;
        current = current->nextDisplayLink;
    }
    
    if (count > 0) {
        links_to_process = (DisplayLinkRef *)alloca(count * sizeof(DisplayLinkRef));
        
        current = manager->listHead;
        while (current) {
            os_unfair_lock_lock((os_unfair_lock_t)current);
            
            if (!current->flags.isDestroyed) {
                if (current->nextTime == INFINITY) {
                    if (current->state != 0) {
                        current->state--;
                        if (current->state == 0) {
                            manager->pausedDisplayLinks++;
                            manager->state = 5;
                        }
                    }
                } else {
                    links_to_process[num_links++] = current;
                    current->nextTime = INFINITY;
                    current->flags.isScheduled = 1;
                }
            }
            
            os_unfair_lock_unlock((os_unfair_lock_t)current);
            current = current->nextDisplayLink;
        }
    }
    
    os_unfair_lock_unlock(&link_lock);
    
    for (size_t i = 0; i < num_links; i++) {
        DisplayLinkRef link = links_to_process[i];
        if (link->callback) {
            link->callback(link, callback_time);
        }
    }
    
    os_unfair_lock_lock(&link_lock);
    
    for (size_t i = 0; i < num_links; i++) {
        DisplayLinkRef link = links_to_process[i];
        
        os_unfair_lock_lock((os_unfair_lock_t)link);
        link->flags.isScheduled = 0;
        bool should_free = link->flags.isDestroyed;
        os_unfair_lock_unlock((os_unfair_lock_t)link);
        
        if (should_free) {
            remove_link(link);
            Block_release(link->callback);
            free(link);
        }
    }
    
    bool should_pause = false;
    bool should_destroy = false;
    
    if (manager->pausedDisplayLinks == manager->totalDisplayLinks) {
        if (manager->state != 0) {
            manager->state--;
            if (manager->state == 0 && manager->pausedDisplayLinks != 0) {
                should_pause = true;
            }
        }
    }
    
    if (manager->pausedDisplayLinks == 0 &&
        manager->totalDisplayLinks == 0) {
        should_destroy = true;
        
        DisplayLinkManager **current_mgr = &link_list;
        while (*current_mgr) {
            if (*current_mgr == manager) {
                *current_mgr = manager->nextManager;
                break;
            }
            current_mgr = &(*current_mgr)->nextManager;
        }
    }
    
    os_unfair_lock_unlock(&link_lock);
    
    if (should_pause) {
        CVDisplayLinkSetPaused(manager->displayLink, true);
    }
    
    atomic_store(&manager->timestamp, 0);
    
    if (should_destroy) {
        CVDisplayLinkRelease(manager->displayLink);
        free(manager);
    }
    
}

static CVReturn link_callback(
    CVDisplayLinkRef displayLink,
    const CVTimeStamp* inNow,
    const CVTimeStamp* inOutputTime,
    CVOptionFlags flagsIn,
    CVOptionFlags* flagsOut,
    void* displayLinkContext
) {
    DisplayLinkManager* manager = (DisplayLinkManager*)displayLinkContext;
    
    double current_time = CACurrentMediaTime();
    uint64_t time_bits = *(uint64_t*)&current_time;
    
    uint64_t expected = 0;
    if (atomic_compare_exchange_strong(&manager->timestamp, &expected, time_bits)) {
        dispatch_async_f(link_queue, manager, dispatch_items);
    }
    
    return kCVReturnSuccess;
}

static void remove_link(DisplayLinkRef displayLink) {
    DisplayLinkManager *manager = displayLink->manager;
    
    struct DisplayLink **current = &manager->listHead;
    while (*current) {
        if (*current == displayLink) {
            *current = displayLink->nextDisplayLink;
            
            manager->totalDisplayLinks--;
            break;
        }
        current = &(*current)->nextDisplayLink;
    }
    
    if (displayLink->state == 0) {
        manager->pausedDisplayLinks--;
    }
}

DisplayLinkRef DisplayLinkCreate(CGDirectDisplayID displayID, DisplayLinkCallback callback) {
    DisplayLinkManager *manager = NULL;
    DisplayLinkRef displayLink = NULL;

    os_unfair_lock_lock(&link_lock);

    if (!link_queue) {
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(
            DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INTERACTIVE, 0
        );
        link_queue = dispatch_queue_create("com.apple.SwiftUI.DisplayLink", attr);
    }
    
    manager = link_list;
    while (manager) {
        if (manager->displayID == displayID) {
            break;
        }
        manager = manager->nextManager;
    }
    
    if (!manager) {
        manager = (DisplayLinkManager *)calloc(1, sizeof(DisplayLinkManager));
        if (!manager) goto cleanup_and_fail;
        
        manager->displayID = displayID;
        manager->state = 5;
        
        CVReturn status = CVDisplayLinkCreateWithCGDisplay(displayID, &manager->displayLink);
        
        if (status != kCVReturnSuccess) {
            free(manager);
            goto cleanup_and_fail;
        }
        
        manager->nextManager = link_list;
        link_list = manager;
        
        CVDisplayLinkSetOutputCallback(manager->displayLink, link_callback, manager);
        CVDisplayLinkStart(manager->displayLink);
    }
    
    displayLink = (DisplayLinkRef)calloc(1, sizeof(struct DisplayLink));
    
    if (!displayLink) goto cleanup_and_fail;
    
    displayLink->manager = manager;
    displayLink->callback = Block_copy(callback);
    displayLink->nextTime = INFINITY;
    displayLink->state = 0;
    
    displayLink->nextDisplayLink = manager->listHead;
    manager->listHead = displayLink;
    
    manager->pausedDisplayLinks++;
    manager->totalDisplayLinks++;
    
    os_unfair_lock_unlock(&link_lock);
    return displayLink;
cleanup_and_fail:
    os_unfair_lock_unlock(&link_lock);
    return NULL;
}

void DisplayLinkDestroy(DisplayLinkRef displayLink) {
    if (!displayLink) return;
    
    os_unfair_lock_lock((os_unfair_lock_t)displayLink);
    
    bool wasScheduled = displayLink->flags.isScheduled;
    displayLink->flags.isDestroyed = true;
    
    os_unfair_lock_unlock((os_unfair_lock_t)displayLink);
    
    if (wasScheduled) return;
    
    os_unfair_lock_lock(&link_lock);
    
    DisplayLinkManager *manager = displayLink->manager;
    
    remove_link(displayLink);
    
    bool shouldDestroyManager = (manager->totalDisplayLinks == 0 &&
                                 manager->state == 0);
    
    if (shouldDestroyManager) {
        DisplayLinkManager **current = &link_list;
        while (*current) {
            if (*current == manager) {
                *current = manager->nextManager;
                break;
            }
            current = &(*current)->nextManager;
        }
    }
    
    os_unfair_lock_unlock(&link_lock);
    
    if (shouldDestroyManager) {
        CVDisplayLinkRelease(manager->displayLink);
        free(manager);
    }
    
    Block_release(displayLink->callback);
    free(displayLink);
}

void DisplayLinkSetNextTime(DisplayLinkRef displayLink, double nextTime) {
    if (!displayLink) return;

    os_unfair_lock_lock(&link_lock);

    if (displayLink->nextTime != nextTime) {
        if (nextTime != INFINITY && displayLink->state == 0) {
            
            DisplayLinkManager *manager = displayLink->manager;
            
            manager->pausedDisplayLinks--;
            
            if (manager->state == 0) {
                 CVDisplayLinkSetPaused(manager->displayLink, false);
            }
            
            manager->state = 5;
            displayLink->state = 5;
        }

        displayLink->nextTime = nextTime;
    }

    os_unfair_lock_unlock(&link_lock);
}

double DisplayLinkGetNextTime(DisplayLinkRef displayLink) {
    if (!displayLink) return NAN;

    os_unfair_lock_lock(&link_lock);
    double time = displayLink->nextTime;
    os_unfair_lock_unlock(&link_lock);

    return time;
}

#endif
