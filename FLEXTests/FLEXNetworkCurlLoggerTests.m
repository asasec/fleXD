//
//  FLEXNetworkCurlLoggerTests.m
//  FLEXTests
//
//  Created by Tim Oliver on 8/1/26.
//

#import <XCTest/XCTest.h>
#import "FLEXNetworkCurlLogger.h"

@interface FLEXNetworkCurlLoggerTests : XCTestCase
@end

@implementation FLEXNetworkCurlLoggerTests

/// Each part of the command sits on its own line, joined by shell
/// line continuations, so the copied command is readable. (FLEXTool/FLEX#666)
- (void)testCurlCommandPutsEachPartOnItsOwnLine {
    NSMutableURLRequest *request = [NSMutableURLRequest
        requestWithURL:[NSURL URLWithString:@"https://api.flexd.test/items"]
    ];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [@"{\"a\":1}" dataUsingEncoding:NSUTF8StringEncoding];

    NSString *expected =
        @"curl -v -X POST \\\n"
        @"  'https://api.flexd.test/items' \\\n"
        @"  -H 'Content-Type: application/json' \\\n"
        @"  -d '{\"a\":1}'";
    XCTAssertEqualObjects([FLEXNetworkCurlLogger curlCommandString:request], expected);
}

- (void)testCurlCommandJoinsAllHeadersWithContinuations {
    NSMutableURLRequest *request = [NSMutableURLRequest
        requestWithURL:[NSURL URLWithString:@"https://api.flexd.test/items"]
    ];
    request.HTTPMethod = @"GET";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    NSString *command = [FLEXNetworkCurlLogger curlCommandString:request];
    XCTAssertTrue([command containsString:@"-H 'Content-Type: application/json'"]);
    XCTAssertTrue([command containsString:@"-H 'Accept-Encoding: gzip'"]);

    // Command, URL, and one line per header
    NSArray *lines = [command componentsSeparatedByString:@" \\\n  "];
    XCTAssertEqual(lines.count, 4);
}

/// No Cookie header should be emitted when the cookie storage has no
/// cookies for the request's URL.
- (void)testCurlCommandOmitsCookieHeaderWhenNoCookiesExist {
    NSURLRequest *request = [NSURLRequest
        requestWithURL:[NSURL URLWithString:@"https://cookieless.flexd.test/"]
    ];

    NSString *command = [FLEXNetworkCurlLogger curlCommandString:request];
    XCTAssertFalse([command containsString:@"Cookie"]);
}

/// Bodies that aren't valid UTF-8 fall back to piping base64 into curl.
- (void)testCurlCommandPipesBase64ForBinaryBody {
    NSMutableURLRequest *request = [NSMutableURLRequest
        requestWithURL:[NSURL URLWithString:@"https://api.flexd.test/upload"]
    ];
    request.HTTPMethod = @"POST";
    const uint8_t bytes[] = {0xFF, 0xFE, 0x00, 0x01};
    request.HTTPBody = [NSData dataWithBytes:bytes length:sizeof(bytes)];

    NSString *command = [FLEXNetworkCurlLogger curlCommandString:request];
    XCTAssertTrue([command hasPrefix:@"echo -n '"]);
    XCTAssertTrue([command containsString:@"' | base64 -D | curl"]);
    XCTAssertTrue([command containsString:@"--data-binary @-"]);
}

@end
