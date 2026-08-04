//
// FLEXCurlLogger.m
//
//
// Created by Ji Pei on 07/27/16
//

#import "FLEXNetworkCurlLogger.h"
#import "FLEXUtility.h"

@implementation FLEXNetworkCurlLogger

+ (NSString *)curlCommandString:(NSURLRequest *)request {
    __block NSMutableArray<NSString *> *components = [NSMutableArray new];
    [components addObject:[NSString stringWithFormat:@"curl -v -X %@", request.HTTPMethod]];

    [components addObject:[NSString stringWithFormat:@"\'%@\'", request.URL.absoluteString]];

    [request.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *val, BOOL *stop) {
        [components addObject:[NSString stringWithFormat:@"-H \'%@: %@\'", key, val]];
    }];

    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:request.URL];
    if (cookies.count) {
        NSMutableString *cookieString = [NSMutableString stringWithString:@"-H \'Cookie:"];
        for (NSHTTPCookie *cookie in cookies) {
            [cookieString appendFormat:@" %@=%@;", cookie.name, cookie.value];
        }
        [cookieString appendString:@"\'"];
        [components addObject:cookieString];
    }

    NSString *prefix = @"";
    if (request.HTTPBody) {
        NSData *bodyData = request.HTTPBody;
        if ([FLEXUtility hasCompressedContentEncoding:request]) {
            bodyData = [FLEXUtility inflatedDataFromCompressedData:bodyData];
        }
        NSString *body = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];

        if (body != nil) {
            [components addObject:[NSString stringWithFormat:@"-d \'%@\'", body]];
        } else {
            // Fallback to using base64 encoding
            [components addObject:@"--data-binary @-"];

            NSString *base64 = [request.HTTPBody base64EncodedStringWithOptions:0];
            prefix = [NSString stringWithFormat:@"echo -n '%@' | base64 -D | ", base64];
        }
    }

    // Join with shell line continuations so the command stays readable
    return [prefix stringByAppendingString:[components componentsJoinedByString:@" \\\n  "]];
}

@end
