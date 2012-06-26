//
//  CKLocalizationManager.m
//  Volvo
//
//  Created by Sebastien Morel on 11-11-10.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKLocalizationManager.h"
#import "CKLocalization.h"
#import <UIKit/UIKit.h>
#import "CKNSObject+CKRuntime.h"
#import "CKLocalizationManager_Private.h"
#import "CKDebug.h"

@interface CKLocalizationManager() {
    NSBundle *bundle;
}
#if TARGET_IPHONE_SIMULATOR
@property (nonatomic, assign) BOOL needsRefresh;
#endif
@end

@implementation CKLocalizationManager
@synthesize language = _language;

#if TARGET_IPHONE_SIMULATOR
@synthesize needsRefresh;
#endif

//Current application bungle to get the languages.
static CKLocalizationManager *sharedInstance = nil;

+ (CKLocalizationManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CKLocalizationManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if ((self = [super init])) 
    {
#if TARGET_IPHONE_SIMULATOR
        self.needsRefresh = NO;
#endif
        bundle = [NSBundle mainBundle];
        
        //Do not trigger KVO in init when setting the language value
        NSString *deviceLang = [[NSLocale preferredLanguages] objectAtIndex:0];
        [_language release];
        _language = [deviceLang retain];
	}
    return self;
}

// Gets the current localized string as in NSLocalizedString.
//
// example calls:
// AMLocalizedString(@"Text to localize",@"Alternative text, in case hte other is not find");
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value {
    return CKGetLocalizedString(bundle,key,value);
}


// Sets the desired language of the ones you have.
// example calls:
// LocalizationSetLanguage(@"Italian");
// LocalizationSetLanguage(@"German");
// LocalizationSetLanguage(@"Spanish");
// 
// If this function is not called it will use the default OS language.
// If the language does not exists y returns the default OS language.
- (void) setLanguage:(NSString*) l{
    if(![l isEqualToString:_language]){
        CKDebugLog(@"preferredLang: %@", l);
        
        [CKLocalizationStringTableNames release];
        CKLocalizationStringTableNames = nil;
        
        NSString *path = [[ NSBundle mainBundle ] pathForResource:l ofType:@"lproj" ];
        
        if (path == nil)
            //in case the language does not exists
            [self resetToSystemDefaultLanguage];
        else
            bundle = [[NSBundle bundleWithPath:path] retain];
        
        [_language release];
        _language = [l retain];
        
        [self refreshUI];
    }
}

@end



@implementation CKLocalizationManager(CKPrivate)

// Resets the localization system, so it uses the OS default language.
//
// example call:
// LocalizationReset;
- (void) resetToSystemDefaultLanguage
{
    self.language = [[NSLocale preferredLanguages] objectAtIndex:0];
}


- (void)refreshView:(UIView*)view viewStack:(NSMutableSet*)viewStack{
    if(view == nil || [viewStack containsObject:view])
        return;
    
    [viewStack addObject:view];
    [view setNeedsDisplay];
    [view setNeedsLayout];
    for(UIView* v in [view subviews]){
        [self refreshView:v viewStack:viewStack];
    }
}

- (void)refreshViewController:(UIViewController*)controller controllerStack:(NSMutableSet*)controllerStack viewStack:(NSMutableSet*)viewStack{
    if(controller == nil || [controllerStack containsObject:controller])
        return;
    
    [controllerStack addObject:controller];
    
    controller.title = controller.title;
    if([controller respondsToSelector:@selector(reload)]){
        [controller performSelector:@selector(reload)];
    }
    [self refreshViewController:[controller modalViewController] controllerStack:controllerStack viewStack:viewStack];
    
    [self refreshView:[controller view] viewStack:viewStack];
    
    if([NSObject isClass:[controller class] kindOfClassNamed:@"CKContainerViewController"]
       || [NSObject isClass:[controller class] kindOfClassNamed:@"CKSplitViewController"]){
        NSArray* controllers = [controller performSelector:@selector(viewControllers)];
        for(UIViewController* c in controllers){
            [self refreshViewController:c controllerStack:controllerStack viewStack:viewStack];
        }
    }
}

- (void)refreshUI{
#if TARGET_IPHONE_SIMULATOR
    self.needsRefresh = YES;
#endif
    
    NSMutableSet* controllerStack = [NSMutableSet set];
    NSMutableSet* viewStack = [NSMutableSet set];
    NSArray* windows = [[UIApplication sharedApplication]windows];
    for(UIWindow* window in windows){
        UIViewController* c = [window rootViewController];
        [self refreshViewController:c controllerStack:controllerStack viewStack:viewStack];
        [self refreshView:window viewStack:viewStack];
    }
    
#if TARGET_IPHONE_SIMULATOR
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.needsRefresh = NO;
    });
#endif
}

- (void)reloadBundleAtPath:(NSString *)path {
#if TARGET_IPHONE_SIMULATOR
    bundle = [NSBundle bundleWithPath:path];
#endif
}

@end