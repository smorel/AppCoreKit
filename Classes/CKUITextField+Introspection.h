//
//  CKUITextView+Introspection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITextField (CKIntrospectionAdditions)
/* SEE HOW TO MAKE UITextResponder KVO complient
@property(nonatomic,assign) UITextAutocapitalizationType autocapitalizationType;
@property(nonatomic,assign) UITextAutocorrectionType autocorrectionType;        
@property(nonatomic,assign) UIKeyboardType keyboardType;   
@property(nonatomic,assign) UIKeyboardAppearance keyboardAppearance;            
@property(nonatomic,assign) UIReturnKeyType returnKeyType;                       
@property(nonatomic,assign) BOOL enablesReturnKeyAutomatically;                  
*/
@end