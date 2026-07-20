//
//  FLEXGlobalsEntryTests.m
//  FLEXTests
//

#import <XCTest/XCTest.h>
#import "FLEXManager.h"
#import "FLEXManager+Extensibility.h"
#import "FLEXManager+Private.h"
#import "FLEXGlobalsEntry.h"

@interface FLEXGlobalsEntryTests : XCTestCase
@end

@implementation FLEXGlobalsEntryTests

- (void)setUp {
    [super setUp];
    // Abort the test on the first failed assert; lastRegisteredEntry relies on
    // this to stop tests before they invoke a block property on a nil entry.
    self.continueAfterFailure = NO;
    [FLEXManager.sharedManager clearGlobalEntries];
}

- (void)tearDown {
    [FLEXManager.sharedManager clearGlobalEntries];
    [super tearDown];
}

- (FLEXGlobalsEntry *)lastRegisteredEntry {
    FLEXGlobalsEntry *entry = FLEXManager.sharedManager.userGlobalEntries.lastObject;
    XCTAssertNotNil(entry, @"registration did not add an entry to userGlobalEntries");
    return entry;
}

#pragma mark - Symbol and color registration

- (void)testObjectEntryStoresSymbolNameAndIconColor {
    [FLEXManager.sharedManager registerGlobalEntryWithName:@"Current User"
                                                symbolName:@"person.crop.circle"
                                                 iconColor:UIColor.systemTealColor
                                         objectFutureBlock:^id { return @"user"; }];

    FLEXGlobalsEntry *entry = [self lastRegisteredEntry];
    XCTAssertEqualObjects(entry.entryNameFuture(), @"Current User");
    XCTAssertEqualObjects(entry.symbolName, @"person.crop.circle");
    XCTAssertEqualObjects(entry.iconColor, UIColor.systemTealColor);
    XCTAssertNotNil(entry.viewControllerFuture);
    XCTAssertNil(entry.rowAction);
}

- (void)testViewControllerEntryStoresSymbolNameAndIconColor {
    [FLEXManager.sharedManager registerGlobalEntryWithName:@"Debug Menu"
                                                symbolName:@"ladybug.fill"
                                                 iconColor:UIColor.systemRedColor
                                 viewControllerFutureBlock:^UIViewController * { return [UIViewController new]; }];

    FLEXGlobalsEntry *entry = [self lastRegisteredEntry];
    XCTAssertEqualObjects(entry.entryNameFuture(), @"Debug Menu");
    XCTAssertEqualObjects(entry.symbolName, @"ladybug.fill");
    XCTAssertEqualObjects(entry.iconColor, UIColor.systemRedColor);
    XCTAssertNotNil(entry.viewControllerFuture);
    XCTAssertNil(entry.rowAction);
}

- (void)testActionEntryStoresSymbolNameAndIconColor {
    [FLEXManager.sharedManager registerGlobalEntryWithName:@"Reset Cache"
                                                symbolName:@"trash.fill"
                                                 iconColor:UIColor.systemOrangeColor
                                                    action:^(UITableViewController *host) {}];

    FLEXGlobalsEntry *entry = [self lastRegisteredEntry];
    XCTAssertEqualObjects(entry.entryNameFuture(), @"Reset Cache");
    XCTAssertEqualObjects(entry.symbolName, @"trash.fill");
    XCTAssertEqualObjects(entry.iconColor, UIColor.systemOrangeColor);
    XCTAssertNotNil(entry.rowAction);
    XCTAssertNil(entry.viewControllerFuture);
}

#pragma mark - Nil passthrough

- (void)testNilSymbolNameAndIconColorStayNil {
    [FLEXManager.sharedManager registerGlobalEntryWithName:@"Plain"
                                                symbolName:nil
                                                 iconColor:nil
                                         objectFutureBlock:^id { return @"plain"; }];

    FLEXGlobalsEntry *entry = [self lastRegisteredEntry];
    XCTAssertNil(entry.symbolName);
    XCTAssertNil(entry.iconColor);
}

#pragma mark - Legacy methods unchanged

- (void)testLegacyObjectEntryHasNoSymbolOrColor {
    [FLEXManager.sharedManager registerGlobalEntryWithName:@"Legacy Object"
                                         objectFutureBlock:^id { return @"legacy"; }];

    FLEXGlobalsEntry *entry = [self lastRegisteredEntry];
    XCTAssertEqualObjects(entry.entryNameFuture(), @"Legacy Object");
    XCTAssertNil(entry.symbolName);
    XCTAssertNil(entry.iconColor);
}

- (void)testLegacyViewControllerEntryHasNoSymbolOrColor {
    [FLEXManager.sharedManager registerGlobalEntryWithName:@"Legacy VC"
                                 viewControllerFutureBlock:^UIViewController * { return [UIViewController new]; }];

    FLEXGlobalsEntry *entry = [self lastRegisteredEntry];
    XCTAssertNil(entry.symbolName);
    XCTAssertNil(entry.iconColor);
}

- (void)testLegacyActionEntryHasNoSymbolOrColor {
    [FLEXManager.sharedManager registerGlobalEntryWithName:@"Legacy Action"
                                                    action:^(UITableViewController *host) {}];

    FLEXGlobalsEntry *entry = [self lastRegisteredEntry];
    XCTAssertNil(entry.symbolName);
    XCTAssertNil(entry.iconColor);
}

@end
