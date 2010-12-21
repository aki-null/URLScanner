#import <Foundation/Foundation.h>
#import "NSString+URLScanning.h"

void testString(NSString *testTarget) {
	NSLog(@"Testing: %@", testTarget);
	
	NSArray *allURLRanges = [testTarget rangesOfURL];
	for (NSValue *currentRange in allURLRanges) {
		NSLog(@"'%@'", [testTarget substringWithRange:[currentRange rangeValue]]);
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
    
    [pool drain];
    return 0;
}
