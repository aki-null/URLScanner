//
//  NSString+URLScanning.m
//  URLScanner
//
//  Created by Akihiro Noguchi on 20/12/10.
//  Copyright 2010 Akihiro Noguchi. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are
//  met:
//  
//   1. Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//  
//   2. Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in
//      the documentation and/or other materials provided with the
//      distribution.
//  
//   3. Neither the name of Akihiro Noguchi nor the names of its
//      contributors may be used to endorse or promote products derived
//      from this software without specific prior written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
//  IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

#import "NSString+URLScanning.h"

// Define the URL starting pattern. URL can be ended by an empty character or at the end of a group.
// A group is parsed dynamically by looking at the start and the end of parentheses.
#define START_PTNS              { "http://", "https://" }
#define START_PTNS_MAX_LENGTH   8
#define START_PTNS_MIN_LENGTH   7

// List of domains that can only have ASCII characters
#define EXC_DOMAINS_MAX_LENGTH  64
#define EXC_DOMAINS             { "tinyurl.com", "is.gd", "snipurl.com", "snurl.com", "tiny.cc", "bit.ly", "twurl.nl",\
                                  "cli.gs", "tr.im", "kl.am", "htn.to", "tot.to", "lnk.ms", "ur.ly", "t.co", "budurl.com",\
                                  "ff.im", "twitthis.com", "digg.com", "u.nu", "qurl.com", "bctiny.com", "j.mp", "ow.ly",\
                                  "ht.ly", "post.ly", "ping.fm", "fb.me", "on.fb.me", "su.pr", "p.tl", "icio.us", "dlvr.it",\
                                  "ux.nu", "tiny.ly", "me.lt" }

// List of empty characters
#define EMPTY_CHARS            { 0x0009, 0x000a, 0x000b, 0x000c, 0x000d, 0x0020, 0x0085, 0x00a0, 0x1680, 0x180e,\
                                 0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007, 0x2008, 0x2009,\
                                 0x200a, 0x2028, 0x2029, 0x202f, 0x205f, 0x3000 }

#define isHexCharacter(c) (c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')

@implementation NSString (URLScanning)

static const char startPatterns[][START_PTNS_MAX_LENGTH] = START_PTNS;
static NSUInteger startPatternCount = 0;

// Array of empty characters that are used to determine the end of URL
static const unichar emptyChars[] = EMPTY_CHARS;
static NSUInteger emptyCharsCount = 0;

// Domain exceptions
static const char domainExceptions[][EXC_DOMAINS_MAX_LENGTH] = EXC_DOMAINS;
static NSUInteger domainCount = 0;

+ (void)load {
    startPatternCount = sizeof(startPatterns) / (sizeof(char) * START_PTNS_MAX_LENGTH);
    domainCount = sizeof(domainExceptions) / (sizeof(char) * EXC_DOMAINS_MAX_LENGTH);
    emptyCharsCount = sizeof(emptyChars) / sizeof(unichar);
}

unichar unicharToLower(unichar input) {
    if (input >= 'A' && input <= 'Z') {
        return input + 0x20;
    } else {
        return input;
    }
}

// Fetch the matching parenthesis character
unichar getMatchingClosingCharacter(unichar startChar) {
    switch (startChar) {
        case 0x005B:
            return 0x005D;
            break;
        case 0xFF3B:
            return 0xFF3D;
            break;
        case 0x0028:
            return 0x0029;
            break;
        case 0xFF08:
            return 0xFF09;
            break;
        case 0x007B:
            return 0x007D;
            break;
        case 0xFF5B:
            return 0xFF5D;
            break;
        case 0x2018:
            return 0x2019;
            break;
        case 0x201C:
            return 0x201D;
            break;
        case 0x0022:
            return 0x0022;
            break;
        case 0x0027:
            return 0x0027;
            break;
        case 0xFF5F:
            return 0xFF60;
            break;
        case 0x2E28:
            return 0x2E29;
            break;
        case 0x300C:
            return 0x300D;
            break;
        case 0xFF62:
            return 0xFF63;
            break;
        case 0x300E:
            return 0x300F;
            break;
        case 0x301A:
            return 0x301B;
            break;
        case 0x27E6:
            return 0x27E7;
            break;
        case 0x3014:
            return 0x3015;
            break;
        case 0x2772:
            return 0x2773;
            break;
        case 0x3018:
            return 0x3019;
            break;
        case 0x27EC:
            return 0x27ED;
            break;
        case 0x3008:
            return 0x3009;
            break;
        case 0x2329:
            return 0x232A;
            break;
        case 0x27E8:
            return 0x27E9;
            break;
        case 0x300A:
            return 0x300B;
            break;
        case 0x27EA:
            return 0x27EB;
            break;
        case 0x003C:
            return 0x003E;
            break;
        case 0xFF1C:
            return 0xFF1E;
            break;
        case 0x00AB:
            return 0x00BB;
            break;
        case 0x2039:
            return 0x203A;
            break;
        case 0x3010:
            return 0x3011;
            break;
        case 0x3016:
            return 0x3017;
            break;
        default:
            return 0x00;
            break;
    }
}

// Get the range of first URL encountered in the specified range
NSRange getRangeOfURL(CFStringInlineBuffer *charBuff, NSUInteger startPos, NSUInteger endPos) {
    BOOL foundURL = NO;
    NSUInteger location = NSNotFound;
    NSUInteger length = 0;
    
    for (NSUInteger i = startPos; i < endPos + 1; i++) {
        // Iterate through all starting patterns
        for (NSUInteger j = 0; j < startPatternCount; j++) {
            // Get the current starting pattern
            const char *currentStr = startPatterns[j];
            
            // Check if the string matches the current pattern
            BOOL success = YES;
            length = 0;
            for (NSUInteger k = 0; k < START_PTNS_MAX_LENGTH; k++) {
                unichar currentPatternChar = unicharToLower(currentStr[k]);
                if (currentPatternChar != 0x00) {
                    if (currentPatternChar != unicharToLower(CFStringGetCharacterFromInlineBuffer(charBuff, i + k))) {
                        success = NO;
                        break;
                    }
                    length++;
                }
            }
            
            if (success) {
                foundURL = YES;
                location = i;
                
                // Check the ASCII domain exception list
                BOOL asciiOnly = NO;
                for (NSUInteger k = 0; k < domainCount; k++) {
                    const char *currentDomain = domainExceptions[k];
                    for (NSUInteger l = 0; l < EXC_DOMAINS_MAX_LENGTH; l++) {
                        char currentChar = currentDomain[l];
                        unichar targetChar = CFStringGetCharacterFromInlineBuffer(charBuff, location + length + l);
                        if (currentChar == 0x00) {
                            // The character after the exception domain name has to be either an empty
                            // character, slash '/' or non-ASCII character.
                            if (targetChar == '/' || targetChar >= 0x80) {
                                asciiOnly = YES;
                            } else {
                                for (NSUInteger m = 0; m < emptyCharsCount; m++) {
                                    if (targetChar == emptyChars[m]) {
                                        asciiOnly = YES;
                                        break;
                                    }
                                }
                            }
                            break;
                        } else if (unicharToLower(targetChar) != unicharToLower(currentChar)) {
                            break;
                        }
                    }
                    if (asciiOnly) {
                        break;
                    }
                }
                
                // Check if the URL contains percent encoded string. If it does, it cannot contain
                // non-ASCII characters after the domain name.
                if (!asciiOnly) {
                    NSUInteger percentEncodedStringState = 0;
                    for (NSUInteger k = location + length; k < endPos + 1; k++) {
                        unichar currentChar = CFStringGetCharacterFromInlineBuffer(charBuff, k);
                        
                        // Stop scanning at an empty character
                        BOOL foundEmptyChar = NO;
                        // Iterate through all empty characters
                        for (NSUInteger l = 0; l < emptyCharsCount; l++) {
                            if (currentChar == emptyChars[l]) {
                                foundEmptyChar = YES;
                                break;
                            }
                        }
                        if (foundEmptyChar) {
                            break;
                        }
                        
                        switch (percentEncodedStringState) {
                            case 0:
                                if (currentChar == '%') {
                                    percentEncodedStringState++;
                                }
                                break;
                            case 1:
                                if (isHexCharacter(currentChar)) {
                                    percentEncodedStringState++;
                                } else {
                                    percentEncodedStringState = 0;
                                }
                                break;
                            case 2:
                                if (isHexCharacter(currentChar)) {
                                    asciiOnly = YES;
                                } else {
                                    percentEncodedStringState = 0;
                                }
                                break;
                            default:
                                break;
                        }
                        if (asciiOnly) {
                            break;
                        }
                    }
                }
                
                // Do not find the ending character if the URL contains only the starting pattern
                if (location + length - 1 != endPos) {
                    BOOL foundEndOfDomain = NO;
                    // Find empty character
                    for (NSUInteger k = location + length; k < endPos + 1; k++) {
                        unichar currentEndChar = CFStringGetCharacterFromInlineBuffer(charBuff, k);
                        BOOL foundEndChar = NO;
                        // Iterate through all empty characters
                        for (NSUInteger l = 0; l < emptyCharsCount; l++) {
                            if (currentEndChar == emptyChars[l] ||
                                (foundEndOfDomain && asciiOnly && currentEndChar >= 0x80)) {
                                foundEndChar = YES;
                                break;
                            }
                        }
                        
                        if (foundEndChar) {
                            // Do not include the empty character as match. Simply stop scanning.
                            break;
                        } else {
                            length++;
                        }
                        
                        if (currentEndChar == '/') {
                            foundEndOfDomain = YES;
                        }
                    }
                }
                
                // The URL cannot end with , or .
                for (NSInteger k = location + length - 1; k >= 0; k--) {
                    unichar currentEndChar = CFStringGetCharacterFromInlineBuffer(charBuff, k);
                    if (currentEndChar == '.' || currentEndChar == ',') {
                        length--;
                    } else {
                        break;
                    }
                }
                
                // Found the URL. Stop.
                break;
            }
        }
        
        if (foundURL) {
            break;
        }
    }
    
    return NSMakeRange(location, length);
}

BOOL substringContainsURL(CFStringInlineBuffer *charBuff, NSUInteger startPos, NSUInteger endPos) {
    if (endPos - startPos + 1 < START_PTNS_MIN_LENGTH) {
        return NO;
    }
    
    for (NSUInteger i = startPos; i < endPos + 1; i++) {
        // Iterate through all starting patterns
        for (NSUInteger j = 0; j < startPatternCount; j++) {
            // Get the current starting pattern
            const char *currentStr = startPatterns[j];
            
            // Check if the string matches the current pattern
            BOOL success = YES;
            for (NSUInteger k = 0; k < START_PTNS_MAX_LENGTH; k++) {
                unichar currentPatternChar = unicharToLower(currentStr[k]);
                if (currentPatternChar != 0x00 &&
                    currentPatternChar != unicharToLower(CFStringGetCharacterFromInlineBuffer(charBuff, i + k))) {
                    success = NO;
                    break;
                }
            }
            
            if (success) {
                return YES;
            }
        }
    }
    
    return NO;
}

NSUInteger getGroupRangesForURL(NSString *self, NSUInteger *finalGroups, NSUInteger startIndex, CFStringInlineBuffer charBuff) {
    NSUInteger totalLength = [self length];
    
    if (startIndex >= totalLength) {
        return 0;
    }
    
    const NSUInteger length = totalLength - startIndex;
    
    if (length < START_PTNS_MIN_LENGTH) {
        return 0;
    }
    
    // Find all groups
    
    // Byte 1: Location
    // Byte 2: Length
    // Byte 3: Trimmed Flag
    NSUInteger *groups = calloc(length / START_PTNS_MIN_LENGTH * 3, sizeof(NSUInteger));
    NSUInteger currentGroupIndex = 0;
    for (NSUInteger i = 0; i < length; i++) {
        unichar currentChar = CFStringGetCharacterFromInlineBuffer(&charBuff, i);
        unichar matchingPar = getMatchingClosingCharacter(currentChar);
        
        // Find the end of group
        if (matchingPar != 0x00) {
            // Keep track of how many starting parenthesis were found
            NSUInteger nestCount = 0;
            
            // Find the end parenthesis character
            for (NSUInteger j = i + 1; j < length; j++) {
                unichar currentSecondChar = CFStringGetCharacterFromInlineBuffer(&charBuff, j);
                
                if (currentSecondChar == matchingPar) {
                    if (nestCount == 0) {
                        if (i + 1 <= j - 1 && substringContainsURL(&charBuff, i + 1, j - 1)) {
                            // Only record as group if the group contains URL
                            groups[currentGroupIndex * 3] = i + 1;            // Location
                            groups[currentGroupIndex * 3 + 1] = j - i  - 1;    // Length
                            currentGroupIndex++;
                        }
                        break;
                    } else {
                        // Found the end of a group
                        nestCount--;
                    }
                } else if (currentSecondChar == currentChar) {
                    // Found the duplicate parenthesis
                    nestCount++;
                }
            }
        }
    }
    
    // Solve group overlap issue
    for (NSUInteger i = 0; i < currentGroupIndex; i++) {
        if (i + 1 == currentGroupIndex) {
            break;
        }
        
        NSUInteger startPos = groups[i * 3];
        NSUInteger endPos = startPos + groups[i * 3 + 1] - 1;
        
        // Find a overlapping group
        for (NSUInteger j = i + 1; j < currentGroupIndex; j++) {
            NSUInteger targetStartPos = groups[j * 3];
            NSUInteger targetEndPos = targetStartPos + groups[j * 3 + 1] - 1;
            
            if (targetStartPos >= startPos && targetStartPos <= endPos &&
                targetEndPos > endPos) {
                // Two groups are overlapping. Trim the target group.
                NSUInteger modifiedLoc = endPos + 2;
                NSUInteger modifiedLen = targetEndPos - modifiedLoc + 1;
                
                // Check that the new length is longer than 0
                if (modifiedLen > 0) {
                    // Finally modify the overlapping group info
                    groups[j * 3] = modifiedLoc;
                    groups[j * 3 + 1] = modifiedLen;
                    groups[j * 3 + 2] = 1;    // Mark trimmed state
                }
            }
        }
    }
    
    NSUInteger *groupBuffer = calloc(length, sizeof(NSUInteger));
    // Fill group weight buffer
    for (NSUInteger i = 0; i < currentGroupIndex; i++) {
        NSUInteger currentLoc = groups[i * 3];
        NSUInteger currentLen = groups[i * 3 + 1];
        NSUInteger trimmed = groups[i * 3 + 2];
        
        // Increase the weight of the current group
        for (NSUInteger j = currentLoc; j < currentLoc + currentLen; j++) {
            groupBuffer[j]++;
        }
        
        // Parentheses need to have increased weight.
        // This is required to avoid two groups from getting concatenated.
        // e.g. [http://aki-null.net(]http://aki-null.net)
        if (trimmed == 0) {
            groupBuffer[currentLoc - 1] += 2;
        }
        groupBuffer[currentLoc + currentLen] += 2;
    }
    free(groups);
    
    // Scan the group weight buffer and create final groups
    
    currentGroupIndex = 0;
    
    {
        NSUInteger currentBufferIndex = groupBuffer[0];
        NSUInteger groupStartIndex = 0;
        for (NSUInteger i = 0; i < length; i++) {
            if (currentBufferIndex != groupBuffer[i]) {
                // Found new chunk of group
                finalGroups[currentGroupIndex * 2] = groupStartIndex;
                finalGroups[currentGroupIndex * 2 + 1] = i - groupStartIndex;
                currentGroupIndex++;
                
                currentBufferIndex = groupBuffer[i];
                groupStartIndex = i;
            }
            
            if (i == length - 1) {
                // Last buffer. Close current group.
                finalGroups[currentGroupIndex * 2] = groupStartIndex;
                finalGroups[currentGroupIndex * 2 + 1] = i - groupStartIndex + 1;
                currentGroupIndex++;
            }
        }
    }
    free(groupBuffer);
    
    return currentGroupIndex;
}

- (NSRange *)rangesOfURL:(NSUInteger *)numberOfURLs startFrom:(NSUInteger)startIndex
         withGroupBuffer:(NSUInteger *)groups groupCount:(NSUInteger)groupCount andStringBuffer:(CFStringInlineBuffer) charBuff {
    NSUInteger totalLength = [self length];
    
    if (startIndex >= totalLength) {
        return NULL;
    }
    
    const NSUInteger length = totalLength - startIndex;
    *numberOfURLs = 0;
        
    NSRange *allMatches = malloc(sizeof(NSRange) * (length / START_PTNS_MIN_LENGTH));
    
    // Finally scan for URLs in groups
    for (NSUInteger i = 0; i < groupCount; i++) {
        NSUInteger startPos = groups[i * 2];
        NSUInteger endPos = startPos + groups[i * 2 + 1] - 1;
        
        NSUInteger tempStartPos = startPos;
        BOOL scanningFinished = NO;
        while (!scanningFinished) {
            NSRange urlRange = getRangeOfURL(&charBuff, tempStartPos, endPos);
            if (urlRange.location == NSNotFound) {
                scanningFinished = YES;
            } else {
                // Get the next part of the string to parse
                tempStartPos = urlRange.location + urlRange.length;
                if (tempStartPos > endPos) {
                    scanningFinished = YES;
                }
                
                // Offset location to be relative to the real string length
                urlRange.location += startIndex;
                
                // Record the range of URLs
                allMatches[*numberOfURLs] = urlRange;
                (*numberOfURLs)++;
            }
        }
    }
    
    // Create autoreleased mutable byte array
    NSRange *result = [[NSMutableData dataWithLength:*numberOfURLs * sizeof(NSRange)] mutableBytes];
    memcpy(result, allMatches, sizeof(NSRange) * *numberOfURLs);
    free(allMatches);
    
    return result;
}

- (NSRange *)rangesOfURL:(NSUInteger *)numberOfURLs startFrom:(NSUInteger)startIndex {
    *numberOfURLs = 0;
    NSUInteger totalLength = [self length];
    
    // Obtain string buffer
    CFStringInlineBuffer charBuff;
    CFStringInitInlineBuffer((CFStringRef)self, &charBuff, CFRangeMake(startIndex, totalLength - startIndex));
    
    const NSUInteger length = totalLength - startIndex;
    
    // Byte 1: Location
    // Byte 2: Length
    NSUInteger *finalGroups = calloc(length * 2, sizeof(NSUInteger));
    NSUInteger groupCount = getGroupRangesForURL(self, finalGroups, startIndex, charBuff);
    if (groupCount == 0) {
        free(finalGroups);
        return NULL;
    }
    
    NSRange *result = [self rangesOfURL:numberOfURLs startFrom:startIndex withGroupBuffer:finalGroups
                             groupCount:groupCount andStringBuffer:charBuff];
    free(finalGroups);
    return result;
}

- (NSRange *)rangesOfURL:(NSUInteger *)numberOfURLs {
    return [self rangesOfURL:numberOfURLs startFrom:0];
}

- (NSArray *)getURLStrings {
    NSUInteger numberOfURLs;
    NSRange *allRanges = [self rangesOfURL:&numberOfURLs];
    
    if (numberOfURLs == 0) {
        return nil;
    }
    
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:numberOfURLs];
    for (NSUInteger i = 0; i < numberOfURLs; i++) {
        [urls addObject:[self substringWithRange:allRanges[i]]];
    }
    
    return urls;
}

- (BOOL)containsURL {
    const NSUInteger length = [self length];
    
    if (length < START_PTNS_MIN_LENGTH) {
        return NO;
    }
    
    // Obtain string buffer
    CFStringInlineBuffer charBuff;
    CFStringInitInlineBuffer((CFStringRef)self, &charBuff, CFRangeMake(0, length));
    
    BOOL result = substringContainsURL(&charBuff, 0, length - 1);
    return result;
}

- (NSString *)stringByReplacingURL:(NSString *)sourceUrl withURL:(NSString *)targetUrl {
    return [self stringByReplacingURL:sourceUrl withURL:targetUrl all:YES];
}

- (NSString *)stringByReplacingURL:(NSString *)sourceUrl withURL:(NSString *)targetUrl all:(BOOL)all {
    if (!sourceUrl || !targetUrl || [sourceUrl isEqualToString:targetUrl]) {
        return self;
    }
    
    NSUInteger scanIndex = 0;
    NSMutableString *result = [self mutableCopy];
    NSInteger lengthDiff = [targetUrl length] - [sourceUrl length];
    
    for(;;) {
        NSUInteger length = [result length];
        
        // Obtain string buffer
        CFStringInlineBuffer charBuff;
        CFStringInitInlineBuffer((CFStringRef)result, &charBuff, CFRangeMake(0, length));
        
        // Obtain group ranges
        // Byte 1: Location
        // Byte 2: Length
        NSUInteger *finalGroups = calloc(length * 2, sizeof(NSUInteger));
        NSUInteger groupCount = getGroupRangesForURL(result, finalGroups, 0, charBuff);
        if (groupCount == 0) {
            free(finalGroups);
            [result release];
            return self;
        }
        
        NSRange strRange = [result rangeOfString:sourceUrl
                                         options:0
                                           range:NSMakeRange(scanIndex, length - scanIndex)];
        if (strRange.location == NSNotFound) {
            free(finalGroups);
            break;
        } else {
            scanIndex = NSMaxRange(strRange);
        }
        
        for (NSUInteger i = 0; i < groupCount; i++) {
            // Check if the current group contains the source string range
            if (finalGroups[i * 2] <= strRange.location &&
                finalGroups[i * 2] + finalGroups[i * 2 + 1] >= strRange.location + strRange.length) {
                BOOL appendSpace = NO;
                // The source string has to not be positioned at the end of a group if extra space is required
                if (finalGroups[i * 2] + finalGroups[i * 2 + 1] != strRange.location + strRange.length) {
                    unichar nextStr = CFStringGetCharacterFromInlineBuffer(&charBuff, NSMaxRange(strRange));
                    if (nextStr != 0x00) {
                        // Assume that the next character is not an empty character
                        appendSpace = YES;
                        for (NSUInteger j = 0; j < emptyCharsCount; j++) {
                            if (nextStr == emptyChars[j]) {
                                // Found empty character
                                appendSpace = NO;
                                break;
                            }
                        }
                    }
                }
                
                if (appendSpace) {
                    [result replaceCharactersInRange:strRange withString:[targetUrl stringByAppendingString:@" "]];
                    scanIndex += lengthDiff + 1;
                } else {
                    [result replaceCharactersInRange:strRange withString:targetUrl];
                    scanIndex += lengthDiff;
                }
                
                if (!all) {
                    NSString *finalResult = [[result copy] autorelease];
                    [result release];
                    free(finalGroups);
                    
                    return finalResult;
                }
                
                break;
            }
        }
        
        free(finalGroups);
        
        if (scanIndex >= [result length]) {
            break;
        }
    }
    
    NSString *finalResult = [[result copy] autorelease];
    [result release];
    
    return finalResult;
}

@end

#ifdef __BLOCKS__

@implementation NSString (URLScanningBlockAdditions)

- (void)enumerateURLsUsingBlock:(void (^)(NSString *url, NSRange range, BOOL *stop))block {
    NSUInteger numberOfURLs;
    NSRange *allRanges = [self rangesOfURL:&numberOfURLs];
    
    if (numberOfURLs != 0) {
        for (NSUInteger i = 0; i < numberOfURLs; i++) {
            NSString *currentURL = [self substringWithRange:allRanges[i]];
            BOOL shouldStop = NO;
            block(currentURL, allRanges[i], &shouldStop);
            if (shouldStop) {
                break;
            }
        }
    }
}

- (void)enumerateURLRangesUsingBlock:(void (^)(NSRange range, BOOL *stop))block {
    NSUInteger numberOfURLs;
    NSRange *allRanges = [self rangesOfURL:&numberOfURLs];
    
    if (numberOfURLs != 0) {
        for (NSUInteger i = 0; i < numberOfURLs; i++) {
            BOOL shouldStop = NO;
            block(allRanges[i], &shouldStop);
            if (shouldStop) {
                break;
            }
        }
    }
}

@end

#endif
