//
//  CKAddressBook.h
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

/**
 */
@interface CKAddressBookPerson : NSObject

///-----------------------------------
/// @name Creating AdressBookPerson 
///-----------------------------------

/**
 */
+ (id)personWithRecord:(ABRecordRef)record;

/**
 */
+ (id)person;

/**
 */
- (id)initWithRecord:(ABRecordRef)record;

///-----------------------------------
/// @name Accessing AdressBookPerson Attributes
///-----------------------------------

/**
 */
@property (nonatomic, readonly) NSString *firstName;
/**
 */
@property (nonatomic, readonly) NSString *lastName;
/** 
 */
@property (nonatomic, readonly) NSString *fullName;
/** 
 */
@property (nonatomic, readonly) NSString *email;
/** 
 */
@property (nonatomic, readonly) UIImage *image;
/** 
 */
@property (nonatomic, readonly) NSArray *phoneNumbers;
/** 
 */
@property (nonatomic, readonly) ABRecordRef record;

/**
 */
- (void)setFirstName:(NSString *)name;

/**
 */
- (void)setLastName:(NSString *)name;

/**
 */
- (void)setOrganizationName:(NSString *)name;

/**
 */
- (void)setPhone:(NSString *)phone forLabel:(NSString *)label;

/**
 */
- (void)setAddress:(NSDictionary *)address forLabel:(NSString *)label;

/**
 */
- (void)setWebsite:(NSString *)url forLabel:(NSString *)label;

/**
 */
- (void)setImage:(UIImage *)image;

@end




/**
 */
@interface CKAddressBook : NSObject

///-----------------------------------
/// @name Singleton
///-----------------------------------

/**
 */
+ (CKAddressBook *)defaultAddressBook;

///-----------------------------------
/// @name Querying the address book
///-----------------------------------

/**
 */
- (NSArray *)findPeopleWithEmails:(NSArray *)emails;

/**
 */
- (NSArray *)findAllPeopleWithAnyEmails;

@end
