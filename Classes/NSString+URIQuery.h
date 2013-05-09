//
//  NSString+URIQuery.h
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//
//  by Jerry Krinock.
//

#import <Foundation/Foundation.h>

/**
 */
extern NSString * const CKSpecialURLCharacters;


/**
 */
@interface NSString (CKNSStringURIQueryAdditions)

///-----------------------------------
/// @name Encoding String content
///-----------------------------------

/** 
 */
- (NSString*)encodePercentEscapesPerRFC2396 ;

/** 
 */
- (NSString*)encodePercentEscapesStrictlyPerRFC2396 ;

/** Decodes any existing percent escapes which should not be encoded per RFC 2396 sec. 2.4.3
    Encodes any characters which should be encoded per RFC 2396 sec. 2.4.3.
 */
- (NSString*)encodePercentEscapesPerRFC2396ButNot:(NSString*)butNot butAlso:(NSString*)butAlso ;

/** butNot and/or butAlso may be nil
   I did an experiment to find out which ASCII characters are encoded,
   by encoding a string with all the nonalphanumeric characters available on the
   Macintosh keyboard, with and without the shift key down.  There were fourteen:
       ` # % ^ [ ] { } \ | " < >
   You only see thirteen because the fourtheenth one is the space character, " ".
   This agrees with the lists of "space" "delims" and "unwise" in  by RFC 2396 sec. 2.4.3
   Also, I found that all of the non-ASCII characters available on the Macintosh
   keyboard by using option or shift+option are also encoded.  Some of these have
   two bytes of unicode to encode, for example %C2%A4 for 0xC2A4

   Returns a string of the form "key0=value0&key1=value1&...".
   All keys and values are percent-escape encoded

   For compatibility with POST, does not prepend a "?"
   All keys must be NSString objects and all values must be NSString or NSArray objects
*/
+ (NSString *)stringWithQueryDictionary:(NSDictionary*)dictionary ;

/** Not sure how this is different than -stringByReplacingPercentEscapesUsingEncoding:
   Performing test in implementation to see if I can use that instead of this.
*/
- (NSString*)decodeAllPercentEscapes ;

/** Assuming that the receiver is a query string of key=value pairs,
   of the form "key0=value0&key1=value1&...", with keys and values percent-escape
   encoded per RFC 2396, returns a dictionary of the keys and values.

   Supports both ampersand "&" and semicolon ";" to delimit key-value
   pairs.  The latter is recommended here:
   http://www.w3.org/TR/1998/REC-html40-19980424/appendix/notes.html#h-B.2.2
*/
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding ;

@end

@interface NSURL (CKNSURLURIQueryAdditions)


/** Assuming that the receiver is a query string of key=value pairs,
 of the form "key0=value0&key1=value1&...", with keys and values percent-escape
 encoded per RFC 2396, returns a dictionary of the keys and values.
 
 Supports both ampersand "&" and semicolon ";" to delimit key-value
 pairs.  The latter is recommended here:
 http://www.w3.org/TR/1998/REC-html40-19980424/appendix/notes.html#h-B.2.2
 */
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding ;

@end
