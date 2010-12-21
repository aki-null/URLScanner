URLScanner - Lenient URL scanner with parentheses detection

##What is it?##
It's a category for NSString to support URL scanning.
It parses URLs in lenient manner, while making sure that parentheses in a string are recognized appropriately.

###Example 1:###
`String:	[https://テスト）.com]`  
`URL:		https://テスト）.com`

The URL above is grouped by parentheses, and the actual URL contains Japanese characters and a closing bracket (U+FF09).

###Example 2:###
`String:	(http://en.wikipedia.org/wiki/Perl_(disambiguation))`  
`URL:		http://en.wikipedia.org/wiki/Perl_(disambiguation)`

The second example shows an example of an URL that contains parentheses inside an URL, that is not escaped properly.

This URL Scanner can deal with cases like above, which is difficult to handle with just regular expressions.

##Notes##
The scanner is very lenient, because it is designed to parse Tweets in my Twitter client [YoruFukurou] [yorufukurou], which is expected to handle URLs pasted from a variety of sources (e.g. from Safari address bar, which does not percent escape the URL).

[yorufukurou]: http://sites.google.com/site/yorufukurou/