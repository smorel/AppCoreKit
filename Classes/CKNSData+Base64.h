//
//  CKNSData+Base64.h
//
//  Created by Matt Gallagher.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Foundation/Foundation.h>

/** TODO
 */
@interface NSData (CKNSDataBase64Additions)

+ (NSData *)dataWithBase64EncodedString:(NSString *)aString;
- (NSString *)base64EncodedString;

@end
