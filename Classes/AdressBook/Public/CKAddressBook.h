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
@property (nonatomic, readonly) NSString *nickName;
/** 
 */
@property (nonatomic, readonly) NSArray *emails;
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

/*
 */
- (NSArray*)identifiersForSocialServiceNamed:(NSString*)name;

/*
 */
- (NSArray*)usernamesForSocialServiceNamed:(NSString*)name;

/**
 */
- (void)addUsername:(NSString*)username identifier:(NSString*)identifier forSocialServiceNamed:(NSString*)name;

@end




/** This class allows to fetch and stretch the image from an addressbook person instance in background with the ability of cancelling the operation when needed.
 */
@interface CKAddressBookPersonImageLoader : NSObject

/**
 */
- (id)initWithPerson:(CKAddressBookPerson*)person;

/**
 */
- (void)loadImageWithSize:(CGSize)size completion:(void(^)(UIImage* image))completion;

/**
 */
- (void)cancel;

@end

extern NSString* CKAddressBookHasBeenModifiedExternallyNotification;

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
- (ABAddressBookRef)addressBook;

/**
 */
- (NSArray *)allPeople;

/**
 */
- (NSArray *)findPeopleWithEmails:(NSArray *)emails;

/** Full name means the following format : "%@ %@",firstName,lastName
 */
- (NSArray *)findPeopleWithFullName:(NSString *)fullName;

/**
 */
- (NSArray *)findPeopleWithNickName:(NSString *)nickname;

/**
 */
- (NSArray *)findAllPeopleWithAnyEmails;

/**
 */
- (void)savePerson:(CKAddressBookPerson*)person error:(NSError**)error;

@end
