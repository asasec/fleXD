//
//  FLEXLiveObjectsControllerTests.m
//  FLEXTests
//
//  Created by Tim Oliver on 8/1/26.
//

#import <XCTest/XCTest.h>
#import "FLEXLiveObjectsController.h"
#import "FLEXTableViewController.h"

/// Exposes internals under test
@interface FLEXLiveObjectsController (FLEXTesting)
@property (nonatomic) NSArray<NSString *> *filteredClassNames;
- (void)refreshControlDidRefresh:(id)sender;
- (void)updateSearchResults:(NSString *)newText;
@end

@interface FLEXLiveObjectsControllerTests : XCTestCase
@end

@implementation FLEXLiveObjectsControllerTests

/// Pulling to refresh re-scans the heap, but must keep filtering by the
/// text still sitting in the search bar. (FLEXTool/FLEX#484)
- (void)testRefreshPreservesActiveSearchFilter {
    FLEXLiveObjectsController *controller = [FLEXLiveObjectsController new];
    [controller loadViewIfNeeded];

    // NSString is guaranteed to have live instances (and non-matching
    // classes like this test case are guaranteed to exist alongside it)
    controller.searchController.searchBar.text = @"NSString";
    [controller updateSearchResults:@"NSString"];
    XCTAssertTrue(controller.filteredClassNames.count > 0);

    [controller refreshControlDidRefresh:nil];

    XCTAssertTrue(controller.filteredClassNames.count > 0);
    for (NSString *className in controller.filteredClassNames) {
        XCTAssertTrue(
            [className rangeOfString:@"NSString" options:NSCaseInsensitiveSearch].location != NSNotFound,
            @"'%@' does not match the active search term", className
        );
    }
}

@end
