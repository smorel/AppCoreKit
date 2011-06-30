//
//  CKAddressBook.h
//
//  Created by Fred Brunel on 07/08/09.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

//
// CKAddressBookPerson
//

/** TODO
 */
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
@property (nonatomic, readonly) ABRecordRef record;

+ (id)personWithRecord:(ABRecordRef)record;
+ (id)person;
- (id)initWithRecord:(ABRecordRef)record;

- (void)setFirstName:(NSString *)name;
- (void)setLastName:(NSString *)name;
- (void)setOrganizationName:(NSString *)name;
- (void)setPhone:(NSString *)phone forLabel:(NSString *)label;
- (void)setAddress:(NSDictionary *)address forLabel:(NSString *)label;
- (void)setWebsite:(NSString *)url forLabel:(NSString *)label;
- (void)setImage:(UIImage *)image;

@end

//
// CKAddressBook
//

/** TODO
 */
@interface CKAddressBook : NSObject {
	ABAddressBookRef _addressBook;
}

+ (CKAddressBook *)defaultAddressBook;

//

- (NSArray *)findPeopleWithEmails:(NSArray *)emails;
- (NSArray *)findAllPeopleWithAnyEmails;

@end
