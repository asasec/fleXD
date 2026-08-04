//
//  FLEXRuntimeSafetyTests.m
//  FLEXTests
//
//  Created by Tim Oliver on 8/1/26.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "FLEXRuntimeSafety.h"

@interface FLEXRuntimeSafetyTests : XCTestCase
@end

@implementation FLEXRuntimeSafetyTests

/// The unsafe ivar set is built from exactly two source entries:
/// NSURL._urlString and NSURL._baseURL, where an ivar that no longer
/// exists is substituted with kCFNull. Anything else in the set means
/// the set was constructed from memory beyond the source array.
- (void)testKnownUnsafeIvarSetContainsOnlyDeclaredEntries {
    XCTAssertTrue(FLEXKnownUnsafeIvars != NULL);

    const void *urlString = class_getInstanceVariable(NSURL.class, "_urlString") ?: (void *)kCFNull;
    const void *baseURL = class_getInstanceVariable(NSURL.class, "_baseURL") ?: (void *)kCFNull;

    CFIndex count = CFSetGetCount(FLEXKnownUnsafeIvars);
    XCTAssertTrue(count >= 1 && count <= 2,
        @"Expected 1–2 entries (two sources, deduplicated), found %ld", (long)count
    );

    const void **values = calloc(count, sizeof(void *));
    CFSetGetValues(FLEXKnownUnsafeIvars, values);
    for (CFIndex i = 0; i < count; i++) {
        XCTAssertTrue(values[i] == urlString || values[i] == baseURL,
            @"Unexpected value %p in FLEXKnownUnsafeIvars", values[i]
        );
    }
    free(values);
}

/// Same shape of guarantee for the unsafe class set: every member must
/// come from the declared class list (kCFNull standing in for classes
/// that don't exist in this runtime).
- (void)testKnownUnsafeClassSetContainsOnlyDeclaredEntries {
    XCTAssertTrue(FLEXKnownUnsafeClasses != NULL);

    CFIndex count = CFSetGetCount(FLEXKnownUnsafeClasses);
    XCTAssertTrue(count >= 1 && count <= (CFIndex)kFLEXKnownUnsafeClassCount,
        @"Expected at most %lu entries, found %ld", (unsigned long)kFLEXKnownUnsafeClassCount, (long)count
    );

    const Class *list = FLEXKnownUnsafeClassList();
    const void **values = calloc(count, sizeof(void *));
    CFSetGetValues(FLEXKnownUnsafeClasses, values);
    for (CFIndex i = 0; i < count; i++) {
        BOOL found = NO;
        for (NSUInteger j = 0; j < kFLEXKnownUnsafeClassCount; j++) {
            if (values[i] == (__bridge const void *)list[j]) {
                found = YES;
                break;
            }
        }
        XCTAssertTrue(found, @"Unexpected value %p in FLEXKnownUnsafeClasses", values[i]);
    }
    free(values);
}

@end
