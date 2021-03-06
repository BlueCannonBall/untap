#include <Carbon/Carbon.h>
#include <Cocoa/Cocoa.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

uint64_t min_gap = 1000;

uint64_t get_utime() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return ((uint64_t) tv.tv_sec) * 1000000ull + tv.tv_usec;
}

size_t type_to_idx(CGEventType type) {
    switch (type) {
        default: {
            NSLog(@"type_to_idx: Invalid event");
            exit(1);
        }

        case kCGEventKeyDown: {
            return 0;
        }

        case kCGEventKeyUp: {
            return 1;
        }
    }
}

CGEventRef event_cb(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void* refcon) {
    if (type == kCGEventKeyDown || type == kCGEventKeyUp) {
        uint64_t*(*time_table)[2] = refcon;
        uint64_t time = get_utime();

        if (time - (*time_table)[type_to_idx(type)][CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode)] < min_gap) {
            return NULL;
        } else {
            (*time_table)[type_to_idx(type)][CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode)] = time;
            return event;
        }
    } else {
        return event;
    }
}

int main(int argc, char** argv) {
    if (argc >= 2) {
        min_gap = atoi(argv[1]);
    }

    uint64_t* time_table[2] = {malloc(UINT16_MAX * 8), malloc(UINT16_MAX * 8)};
    memset(time_table[0], 0, UINT16_MAX * 8);
    memset(time_table[1], 0, UINT16_MAX * 8);

    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    CFRunLoopSourceRef run_loop_source;

    CFMachPortRef event_tap = CGEventTapCreate(
        kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, kCGEventMaskForAllEvents, event_cb, &time_table);

    if (!event_tap) {
        NSLog(@"Failed to create event tap");
        return 1;
    }

    run_loop_source =
        CFMachPortCreateRunLoopSource(kCFAllocatorDefault, event_tap, 0);

    CFRunLoopAddSource(CFRunLoopGetCurrent(), run_loop_source, kCFRunLoopCommonModes);

    CGEventTapEnable(event_tap, true);

    CFRunLoopRun();

    CFRelease(event_tap);
    CFRelease(run_loop_source);
    [pool release];
    free(time_table[0]);
    free(time_table[1]);

    return 0;
}
