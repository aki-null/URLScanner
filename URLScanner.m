#import <Foundation/Foundation.h>
#import "NSString+URLScanning.h"

void testString(NSString *testTarget) {
    NSLog(@"Testing: %@", testTarget);
    
    NSUInteger numberOfURLs;
    NSRange *allURLRanges = [testTarget rangesOfURL:&numberOfURLs];
    
    for (NSUInteger i = 0; i < numberOfURLs; i++) {
        NSLog(@"'%@'", [testTarget substringWithRange:allURLRanges[i]]);
    }
    
    NSLog(@"------------------------------");
    
    NSArray *allURLStrings = [testTarget getURLStrings];
    for (NSString *currentURL in allURLStrings) {
        NSLog(@"'%@'", currentURL);
    }
    
    NSLog(@"------------------------------");
    
    [testTarget enumerateURLsUsingBlock:^(NSString *url, NSRange range, BOOL *stop) {
        NSLog(@"'%@' at %@", url, NSStringFromRange(range));
    }];
    
    NSLog(@"------------------------------");
    
    [testTarget enumerateURLRangesUsingBlock:^(NSRange range, BOOL *stop) {
        NSLog(@"'%@' at %@", [testTarget substringWithRange:range], NSStringFromRange(range));
    }];
    
    NSLog(@"------------------------------");
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSLog(@"%@", [@"http://j.mp/b9PWcWテスト[http://j.mp/b9PWcW]http://j.mp/b9PWcWテスト" stringByReplacingURL:@"http://j.mp/b9PWcW"
                                                                                                 withURL:@"http://groups.google.com/group/twitter-api-announce"]);
    NSLog(@"%@", [@"http://j.mp/b9PWcWテスト[http://j.mp/b9PWcW]http://j.mp/b9PWcWテスト" stringByReplacingURL:@"http://j.mp/b9PWcW"
                                                                                                 withURL:@"http://groups.google.com/group/twitter-api-announce"
                                                                                                     all:NO]);
    
    testString(@"http://test.com http://test.com. http://test.com, http://test.com..,, http://test.com");
    testString(@"http://j.mp/b9PWcWテスト[http://j.mp/b9PWcW]http://j.mp/b9PWcWテストhttp://ja.wikipedia.org/wiki/バール_(単位){http://ja.wikipedia.org/wiki/バール_(単位)}");
    testString(@"http://ja.wikipedia.org/wiki/テスト http://ja.wikipedia.org/wiki/%E3%83%86%E3%82%B9%E3%83%88テスト テスト");
    testString(@"(http://en.wikipedia.org/wiki/Perl_(disambiguation))");
    testString(@"http://test.com");
    testString(@"http://test.com hello world");
    testString(@"helo world http://test.com");
    testString(@"[ https://test).com}]");
    testString(@"[test] http://test.com]");
    testString(@"[test]http://test].com");
    testString(@"[http://test.com)");
    testString(@"test [[ http://test.com/< ]{http://test.com](test)http://test.com}>http://test.com hi test");
    testString(@"(http://test.com/(hello world(http://test.com))http://test.com)");
    testString(@"(http://test.com/[)http://test.com/]");
    testString(@"(test[tes{t)http://test.com]t}");
    testString(@"[http://aki-nul(l.net/] http://test.com)");
    testString(@"[test]http://");
    testString(@"test [[test (http://test.com) http://(hello).com http://] http://] test");
    testString(@"()()()()()http://");
    testString(@"HtTPs://test.com");
    testString(@"hTTP://test.com");
    testString(@"test\"test http://www.test.com\"test");
    
    [pool drain];
    return 0;
}
