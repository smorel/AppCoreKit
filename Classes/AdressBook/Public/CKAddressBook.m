//
//  CKAddressBook.m
//
//  Created by Fred Brunel.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKAddressBook.h"
#import <AddressBook/AddressBook.h>
#import "UIImage+Transformations.h"

#import "NSArray+Additions.h"

@implementation CKAddressBookPerson {
	ABRecordRef _record;
	NSString *_fullName;
	NSString *_email;
	UIImage *_image;
	NSArray *_phoneNumbers;
}

+ (id)personWithRecord:(ABRecordRef)record {
	return [[[CKAddressBookPerson alloc] initWithRecord:record] autorelease];
}

+ (id)person {
	ABRecordRef ABPerson = ABPersonCreate();
	CKAddressBookPerson *person = [CKAddressBookPerson personWithRecord:ABPerson];
	CFRelease(ABPerson);
	return person;
}

- (id)initWithRecord:(ABRecordRef)record {
	if (self = [super init]) {
		_record = CFRetain(record);
	}
	return self;
}

- (void)dealloc {
	[_fullName release];
	[_email release];
	[_image release];
	[_phoneNumbers release];
	CFRelease(_record);
	[super dealloc];
}

// This methods returns the full name of a user (firstname, space, lastname) or the company name 
// if the record was tagged as a company.

- (NSString *)fullName {
	if (_fullName) { return _fullName; }
	
	CFStringRef firstName, lastName, companyName;
	NSMutableString *fullName = [NSMutableString string];
	
	firstName = ABRecordCopyValue(_record, kABPersonFirstNameProperty);
	lastName  = ABRecordCopyValue(_record, kABPersonLastNameProperty);
	companyName = ABRecordCopyValue(_record, kABPersonOrganizationProperty);
	
	// Add the firstname if it is provided
	if (firstName != nil) {
		[fullName appendString:(NSString *)firstName];
	}
	
	// Add the last name if it is specified
	if (lastName != nil) {
		(firstName != nil) ? [fullName appendString: @" "] : [fullName appendString: @""]; // Separate with a space if the firstname was provided
		[fullName appendString:(NSString *)lastName];
	}
	
	// Used the company name if we are unable to find the first and lastname
	if ([fullName length] == 0) { 
		// Use company name or email if none.
		if (companyName != nil) {
			[fullName appendString:(NSString *)companyName];
		}
		else {
			[fullName appendString:self.email];
		}
	}
	
	_fullName = [fullName retain];

	if (firstName) CFRelease(firstName);
	if (lastName) CFRelease(lastName);
	if (companyName) CFRelease(companyName);

	return _fullName;
}

- (NSString *)firstName {
	return ABRecordCopyValue(_record, kABPersonFirstNameProperty);
}

- (NSString *)lastName {
	return ABRecordCopyValue(_record, kABPersonLastNameProperty);
}

- (NSString *)nickName {
	return ABRecordCopyValue(_record, kABPersonNicknameProperty);
}

- (NSString *)email {
	if (_email) { return _email; }
	
	ABMultiValueRef personEmails = ABRecordCopyValue(_record, kABPersonEmailProperty);
	
	if (ABMultiValueGetCount(personEmails) > 0) {
		CFStringRef personEmail = ABMultiValueCopyValueAtIndex(personEmails, 0);
		_email = [(NSString *)personEmail retain];
	} else {
		_email = [[NSString string] retain];
	}

	CFRelease(personEmails);

	return _email;
}

//

- (UIImage *)image {
	if (_image) { return _image; }
	
	if (ABPersonHasImageData(_record)) {
		CFDataRef data = ABPersonCopyImageData(_record);
		_image = [[UIImage imageWithData:(NSData *)data] retain];
		CFRelease(data);
	}
	
	return _image;
}

- (NSArray *)phoneNumbers {
	if (_phoneNumbers) { return _phoneNumbers; }
	
	NSMutableArray *phoneNumbers = [NSMutableArray array];
	
	ABMultiValueRef thePhoneNumbers = ABRecordCopyValue(_record, kABPersonPhoneProperty);
	for (CFIndex i = 0; i < ABMultiValueGetCount(thePhoneNumbers); i++) {
		CFStringRef aLabel = ABMultiValueCopyLabelAtIndex(thePhoneNumbers, i);
		CFStringRef aLocalizedLabel = ABAddressBookCopyLocalizedLabel(aLabel);
		CFStringRef aNumber = ABMultiValueCopyValueAtIndex(thePhoneNumbers, i);
		
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
		[array insertObject:(NSString *)aLocalizedLabel atIndex:0];
		[array insertObject:(NSString *)aNumber atIndex:1];
		
		[phoneNumbers addObject:array];
		
		CFRelease(aLabel);
		CFRelease(aLocalizedLabel);
		CFRelease(aNumber);
	}
	
	_phoneNumbers = [phoneNumbers retain];
	
	CFRelease(thePhoneNumbers);
	
	return _phoneNumbers;
}


//
- (ABRecordRef)record {
	return _record;
}

// NOT USED
//- (CFTypeRef)valueForProperty:(ABPropertyID)property {
//	return ABRecordCopyValue(_record, property);
//}

- (CFErrorRef)setValue:(CFTypeRef)value forProperty:(ABPropertyID)property {
	CFErrorRef error = NULL;
	ABRecordSetValue(_record, property, value, &error);
	return error;
}

- (CFErrorRef)setMultiValue:(CFTypeRef)value ofType:(ABPropertyType)type withLabel:(NSString *)label forProperty:(ABPropertyID)property {
	CFErrorRef error = NULL;
	
	ABMutableMultiValueRef multiStringProperty = ABRecordCopyValue(_record, property);
	if (multiStringProperty == nil) {
		multiStringProperty = ABMultiValueCreateMutable(type);
	}
	
	ABMultiValueIdentifier multivalueIdentifier;
	ABMultiValueAddValueAndLabel(multiStringProperty, value, (CFStringRef)label, &multivalueIdentifier);
	error = [self setValue:multiStringProperty forProperty:property];
	CFRelease(multiStringProperty);
	
	return error;
}

- (void)setFirstName:(NSString *)name {
	[self setValue:name forProperty:kABPersonFirstNameProperty];
}
- (void)setLastName:(NSString *)name {
	[self setValue:name forProperty:kABPersonLastNameProperty];
}
- (void)setOrganizationName:(NSString *)name {
	[self setValue:name forProperty:kABPersonOrganizationProperty];
}

- (void)setPhone:(NSString *)phone forLabel:(NSString *)label {
	[self setMultiValue:phone ofType:kABMultiStringPropertyType withLabel:label forProperty:kABPersonPhoneProperty];
}

- (void)setAddress:(NSDictionary *)address forLabel:(NSString *)label {
	[self setMultiValue:address ofType:kABDictionaryPropertyType withLabel:label forProperty:kABPersonAddressProperty];
}

- (void)setWebsite:(NSString *)url forLabel:(NSString *)label {
	[self setMultiValue:url ofType:kABMultiStringPropertyType withLabel:label forProperty:kABPersonURLProperty];
}

- (void)setImage:(UIImage *)image {
	if (!image) return;
	NSData *imageData = UIImagePNGRepresentation(image);
	ABPersonSetImageData(_record, (CFDataRef)imageData, nil);
}

- (NSArray*)identifiersForSocialServiceNamed:(NSString*)name{
    ABMultiValueRef socialProfiles = ABRecordCopyValue(_record, kABPersonSocialProfileProperty);
    
    NSMutableArray* result = [NSMutableArray array];
    for (int i=0; i<ABMultiValueGetCount(socialProfiles); i++) {
        NSDictionary *socialItem = (__bridge NSDictionary*)ABMultiValueCopyValueAtIndex(socialProfiles, i);
        NSString* socialService = [socialItem objectForKey:(NSString *)kABPersonSocialProfileServiceKey];
        if([[socialService lowercaseString]isEqualToString:[name lowercaseString]]){
            NSString *identifier = ([socialItem objectForKey:(NSString *)kABPersonSocialProfileUserIdentifierKey]);
            [result addObject:identifier];
        }
    }
    
    return result;
}


- (NSArray*)usernamesForSocialServiceNamed:(NSString*)name{
    ABMultiValueRef socialProfiles = ABRecordCopyValue(_record, kABPersonSocialProfileProperty);
    
    NSMutableArray* result = [NSMutableArray array];
    for (int i=0; i<ABMultiValueGetCount(socialProfiles); i++) {
        NSDictionary *socialItem = (__bridge NSDictionary*)ABMultiValueCopyValueAtIndex(socialProfiles, i);
        NSString* socialService = [socialItem objectForKey:(NSString *)kABPersonSocialProfileServiceKey];
        if([[socialService lowercaseString]isEqualToString:[name lowercaseString]]){
            NSString *identifier = ([socialItem objectForKey:(NSString *)kABPersonSocialProfileUsernameKey]);
            [result addObject:identifier];
        }
    }
    
    return result;
}

- (void)addUsername:(NSString*)username identifier:(NSString*)identifier forSocialServiceNamed:(NSString*)name{
    ABMultiValueRef social = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    ABMultiValueAddValueAndLabel(social, (__bridge CFTypeRef)(@{ (NSString*)kABPersonSocialProfileServiceKey        : name,
                                                                 (NSString*)kABPersonSocialProfileUsernameKey       : (username ? username : @""),
                                                                 (NSString*)kABPersonSocialProfileUserIdentifierKey : (identifier ? identifier : @"")
                                                              }),
                                 kABPersonSocialProfileServiceTwitter, NULL);
    
    ABRecordSetValue(_record, kABPersonSocialProfileProperty, social, NULL);
    CFRelease(social);
}

@end

//

@implementation CKAddressBook {
	ABAddressBookRef _addressBook;
}

+ (CKAddressBook *)defaultAddressBook {
	static CKAddressBook *_instance = nil;
	@synchronized(self) {
		if (! _instance) {
			_instance = [[CKAddressBook alloc] init];
		}
	}
	return _instance;
}

- (id)init {
	if (self = [super init]) {
		_addressBook = ABAddressBookCreate();
	}
	return self;
}

- (void)dealloc {
	CFRelease(_addressBook);
	[super dealloc];
}

//
// Public API
//

- (NSArray *)findAllPeopleWithAnyEmails {
	NSMutableArray *match = [NSMutableArray array];
	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(_addressBook);
	
	for (CFIndex i = 0; i < CFArrayGetCount(people); i++) {
		ABRecordRef person = CFArrayGetValueAtIndex(people, i);
		ABMultiValueRef personEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
		if (ABMultiValueGetCount(personEmails) > 0) {
			[match addObject:[CKAddressBookPerson personWithRecord:person]];
		}
		CFRelease(personEmails);
	}
	
	CFRelease(people);
	
	return match;
}

- (NSArray *)findPeopleWithEmails:(NSArray *)emails {
	NSMutableArray *match = [NSMutableArray array];
	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(_addressBook);
	
	for (CFIndex i = 0; i < CFArrayGetCount(people); i++) {
		ABRecordRef person = CFArrayGetValueAtIndex(people, i);
		ABMultiValueRef personEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
		
		for (CFIndex j = 0; j < ABMultiValueGetCount(personEmails); j++) {
			CFStringRef personEmail = ABMultiValueCopyValueAtIndex(personEmails, j);
			
			if ([emails containsString:(NSString *)personEmail]) {
				[match addObject:[CKAddressBookPerson personWithRecord:person]];
				CFRelease(personEmail);
				break;
			}
			CFRelease(personEmail);
		}
		
		CFRelease(personEmails);
	}
	
	CFRelease(people);
	
	return match;
}

- (NSArray *)findPeopleWithFullName:(NSString *)filter{
    NSMutableArray *match = [NSMutableArray array];
	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(_addressBook);
	
	for (CFIndex i = 0; i < CFArrayGetCount(people); i++) {
		ABRecordRef person = CFArrayGetValueAtIndex(people, i);
		NSString* firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
		NSString* lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString* fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
        
        if ([fullName isEqualToString:filter]) {
            [match addObject:[CKAddressBookPerson personWithRecord:person]];
            break;
		}
		
	}
	
	CFRelease(people);
	
	return match;
}

- (NSArray *)findPeopleWithNickName:(NSString *)nickname{
    NSMutableArray *match = [NSMutableArray array];
	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(_addressBook);
	
	for (CFIndex i = 0; i < CFArrayGetCount(people); i++) {
		ABRecordRef person = CFArrayGetValueAtIndex(people, i);
		NSString* name = ABRecordCopyValue(person, kABPersonNicknameProperty);
        
        if ([name isEqualToString:nickname]) {
            [match addObject:[CKAddressBookPerson personWithRecord:person]];
            break;
		}
		
	}
	
	CFRelease(people);
	
	return match;
}


- (NSArray *)allPeople{
    NSMutableArray *match = [NSMutableArray array];
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(_addressBook);
    
    for (CFIndex i = 0; i < CFArrayGetCount(people); i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        [match addObject:[CKAddressBookPerson personWithRecord:person]];
    }
    
    CFRelease(people);
    
    return match;
}

- (void)savePerson:(CKAddressBookPerson*)person error:(NSError**)error{
    CFErrorRef cferror = NULL;
    
    // Save Address Book Person
    ABAddressBookAddRecord(_addressBook, [person record], &cferror);
    if(cferror){
        *error = (NSError*)cferror;
        return;
    }
    
    ABAddressBookSave(_addressBook, &cferror);
    if(cferror){
        *error = (NSError*)cferror;
        return;
    }
}

@end



@interface CKAddressBookPersonImageLoader()
@property(atomic,assign) BOOL hasBeenCancelled;
@property(nonatomic,retain) CKAddressBookPerson* person;
@end

static dispatch_queue_t CKAddressBookPersonImageLoader_queue;

@implementation CKAddressBookPersonImageLoader{
}

- (id)initWithPerson:(CKAddressBookPerson*)person{
    self = [super init];
    self.hasBeenCancelled = NO;
    self.person = person;
    
    return self;
}

- (void)loadImageWithSize:(CGSize)size completion:(void(^)(UIImage* image))completion{
    if(!completion)
        return;
    
    if(!CKAddressBookPersonImageLoader_queue){
        CKAddressBookPersonImageLoader_queue = dispatch_queue_create("com.appcorekit.addressbookimageloader", 0);
    }
    
    dispatch_async(CKAddressBookPersonImageLoader_queue, ^{
        UIImage* image = self.person.image;
        
        @synchronized(self) {
            if(self.hasBeenCancelled)
                return;
        }
        
        UIImage* resized = [image imageThatFits:size crop:NO];
        
        @synchronized(self) {
            if(self.hasBeenCancelled)
                return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(resized);
        });
        
    });
}

- (void)cancel{
    @synchronized(self) {
        self.hasBeenCancelled = YES;
    }
}

@end


