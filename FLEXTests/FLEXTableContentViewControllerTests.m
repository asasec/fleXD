//
//  FLEXTableContentViewControllerTests.m
//  FLEXTests
//
//  Created by Tim Oliver on 8/1/26.
//

#import <XCTest/XCTest.h>
#import "FLEXTableContentViewController.h"
#import "FLEXDatabaseManager.h"

/// Mimics FLEXRealmDatabaseManager: implements only the required protocol
/// methods, so it provides no row IDs and no statement execution.
@interface FLEXStubDatabaseManager : NSObject <FLEXDatabaseManager>
@end

@implementation FLEXStubDatabaseManager

+ (instancetype)managerForDatabase:(NSString *)path { return [self new]; }
- (NSArray<NSString *> *)queryAllTables { return @[@"People"]; }
- (NSArray<NSString *> *)queryAllColumnsOfTable:(NSString *)tableName { return @[@"name"]; }
- (NSArray<NSArray *> *)queryAllDataInTable:(NSString *)tableName { return @[@[@"Tim"]]; }

@end

/// Exposes internals under test
@interface FLEXTableContentViewController (FLEXTesting)
- (BOOL)canDeleteRowAtIndex:(NSInteger)row;
@end

@interface FLEXTableContentViewControllerTests : XCTestCase
@end

@implementation FLEXTableContentViewControllerTests {
    NSArray<NSString *> *_columns;
    NSArray<NSArray<NSString *> *> *_rows;
    FLEXStubDatabaseManager *_manager;
}

- (void)setUp {
    [super setUp];
    _columns = @[@"name"];
    _rows = @[@[@"Tim"], @[@"Anna"]];
    _manager = [FLEXStubDatabaseManager new];
}

#pragma mark Initializer parameter shapes

/// The shape produced by opening a Realm database: the manager cannot
/// supply row IDs, but the table is still browsable. (FLEXTool/FLEX#621)
- (void)testInitAcceptsDatabaseAndTableNameWithoutRowIDs {
    NSArray<NSString *> *noRowIDs = nil;
    XCTAssertNoThrow([FLEXTableContentViewController
        columns:self->_columns rows:self->_rows rowIDs:noRowIDs
        tableName:@"People" database:self->_manager
    ]);
}

/// The shape produced by opening a SQLite database.
- (void)testInitAcceptsAllOptionalParameters {
    NSArray<NSString *> *rowIDs = @[@"1", @"2"];
    XCTAssertNoThrow([FLEXTableContentViewController
        columns:self->_columns rows:self->_rows rowIDs:rowIDs
        tableName:@"People" database:self->_manager
    ]);
}

/// The shape produced by displaying a static query result.
- (void)testInitAcceptsNoOptionalParameters {
    XCTAssertNoThrow([FLEXTableContentViewController
        columns:self->_columns rows:self->_rows
    ]);
}

/// Row IDs are meaningless without a table and manager to delete from;
/// that half of the original all-or-none guard is worth keeping.
- (void)testInitRejectsRowIDsWithoutDatabase {
    NSArray<NSString *> *rowIDs = @[@"1", @"2"];
    NSString *noTableName = nil;
    id<FLEXDatabaseManager> noManager = nil;
    XCTAssertThrows([FLEXTableContentViewController
        columns:self->_columns rows:self->_rows rowIDs:rowIDs
        tableName:noTableName database:noManager
    ]);
}

#pragma mark Row deletion gating

- (void)testCanDeleteRowWithRowIDPresent {
    FLEXTableContentViewController *vc = [FLEXTableContentViewController
        columns:self->_columns rows:self->_rows rowIDs:@[@"1", @"2"]
        tableName:@"People" database:self->_manager
    ];
    XCTAssertTrue([vc canDeleteRowAtIndex:0]);
    XCTAssertTrue([vc canDeleteRowAtIndex:1]);
}

/// Without row IDs (e.g. Realm), rows must not offer deletion even
/// though rows exist and the view can refresh.
- (void)testCannotDeleteRowWithoutRowIDs {
    NSArray<NSString *> *noRowIDs = nil;
    FLEXTableContentViewController *vc = [FLEXTableContentViewController
        columns:self->_columns rows:self->_rows rowIDs:noRowIDs
        tableName:@"People" database:self->_manager
    ];
    XCTAssertFalse([vc canDeleteRowAtIndex:0]);
}

- (void)testCannotDeleteRowOutOfRowIDBounds {
    FLEXTableContentViewController *vc = [FLEXTableContentViewController
        columns:self->_columns rows:self->_rows rowIDs:@[@"1"]
        tableName:@"People" database:self->_manager
    ];
    XCTAssertTrue([vc canDeleteRowAtIndex:0]);
    XCTAssertFalse([vc canDeleteRowAtIndex:1]);
    XCTAssertFalse([vc canDeleteRowAtIndex:-1]);
}

@end
