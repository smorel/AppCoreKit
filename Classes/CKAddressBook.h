//
//  CKAddressBook.h
//
//  Created by Fred Brunel on 07/08/09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

//
// CKAddressBookPerson
//

@interface CKAddressBookPerson : NSObject {
	ABRecordRef _record;
	NSString *_fullName;
	NSString *_email;
	UIImage *_image;
	NSArray *_phoneNumbers;
}

@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) NSArray *phoneNumbers;

+ (id)personWithRecord:(ABRecordRef)record;
- (id)initWithRecord:(ABRecordRef)record;

@end

//
// CKAddressBook
//

@interface CKAddressBook : NSObject {
	ABAddressBookRef _addressBook;
}

+ (CKAddressBook *)defaultAddressBook;

//

- (NSArray *)findPeopleWithEmails:(NSArray *)emails;
- (NSArray *)findAllPeopleWithAnyEmails;

@end
