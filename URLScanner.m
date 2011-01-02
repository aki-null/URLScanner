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
}

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

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
    
    [pool drain];
    return 0;
}
