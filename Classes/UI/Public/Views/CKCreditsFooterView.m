//
//  CKCreditsFooterView.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKCreditsFooterView.h"
#import "UIColor+Additions.h"
#import "CKLocalization.h"
#import "UIGestureRecognizer+BlockBasedInterface.h"
#import "CKPropertyExtendedAttributes+Attributes.h"
#import <AdSupport/AdSupport.h>

@interface UIImageView (CKCreditsView)

+ (UIImageView *)imageViewWithImageNamed:(NSString *)imageName;

@end

@implementation UIImageView (CKCreditsView)

+ (UIImageView *)imageViewWithImageNamed:(NSString *)imageName {
	return [[[UIImageView alloc] initWithImage:_img(imageName)] autorelease];
}

@end

//

@interface CKCreditsFooterView ()

- (id)initWithStyle:(CKCreditsViewStyle)style;

@property (nonatomic, assign) CKCreditsViewStyle style;
@property (nonatomic, assign) BOOL displayingFrontPlate;
@property (nonatomic, retain) UIImageView *titleView;
@property (nonatomic, retain) UIImageView *plateView;
@property (nonatomic, retain) UIImageView *plateBackView;
@property (nonatomic, retain) UILabel *versionLabel;

@property (nonatomic, retain) UIButton *versionLabelSwitchButton;
@property (nonatomic, retain) NSMutableArray* versionLabels;
@property (nonatomic, assign) NSInteger versionIndex;

@end

//

@implementation CKCreditsFooterView

@synthesize style = _style;
@synthesize displayingFrontPlate = _displayingFrontPlate;
@synthesize titleView = _titleView;
@synthesize plateView = _plateView;
@synthesize plateBackView = _plateBackView;
@synthesize versionLabel = _versionLabel;
@synthesize versionLabelSwitchButton;
@synthesize versionLabels;

+ (NSString*)frameworkVersion:(NSString*)frameworkName{
    NSURL* apprelayBundleUrl = [[NSBundle mainBundle]URLForResource:frameworkName withExtension:@"plist"];
    if(!apprelayBundleUrl)
        return nil;
    
    NSDictionary* AppRelayBundle = [NSDictionary dictionaryWithContentsOfURL:apprelayBundleUrl];
    
    NSString *versionNumber = [AppRelayBundle objectForKey:@"CFBundleShortVersionString"];
	NSString *buildNumber = [AppRelayBundle objectForKey:@"CFBundleVersion"];
    
	NSString *version = [NSString stringWithFormat:@"%@ version: %@ (%@)", frameworkName, versionNumber, [versionNumber isEqualToString:buildNumber] ? @"dev" : buildNumber];
	return version;
}

+ (NSString*)appRelayUserId{
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"com.wherecloud.userid.%@",[[NSBundle mainBundle] bundleIdentifier]]];
}

+ (NSString*)vendorId{
    if([[UIDevice currentDevice]respondsToSelector:@selector(identifierForVendor)]){
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return @"";
}

+ (NSString*)advertisingId{
    Class ASIdentifierManagerClass =  NSClassFromString(@"ASIdentifierManager");
    if(ASIdentifierManagerClass == NULL)
        return @"";
    
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

- (id)initWithStyle:(CKCreditsViewStyle)style {
    _style = style;
	self = [super init];
	return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
	if (self) {
        [self setupView];
	}
	return self;
}

- (void)styleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKCreditsViewStyle",
                                                 CKCreditsViewStyleLight,
                                                 CKCreditsViewStyleDark
                                                 );
}

- (void)setupView{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.displayingFrontPlate = YES;
    
    CGFloat topMargin = 5;
    CGFloat titlePlateMargin = 2;
    CGFloat plateVersionMargin = 5;
    
    NSString *versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    
    Class relayServiceClass = NSClassFromString(@"ARService");
    NSString *appVersion = (relayServiceClass != nil) ? [NSString stringWithFormat:@"Version %@ [%@]", versionNumber, buildNumber] : [NSString stringWithFormat:@"Version %@ (%@)", versionNumber, buildNumber];
    
    self.versionIndex = 0;
    self.versionLabels = [NSMutableArray array];
    [self.versionLabels addObject:appVersion];
    
    NSString* AppCoreKitVersion = [CKCreditsFooterView frameworkVersion:@"AppCoreKit"];
    if(AppCoreKitVersion)[self.versionLabels addObject:AppCoreKitVersion];
    
    NSString* VendorsKitVersion = [CKCreditsFooterView frameworkVersion:@"VendorsKit"];
    if(VendorsKitVersion)[self.versionLabels addObject:VendorsKitVersion];
    
    NSString* AppMotionVersion = [CKCreditsFooterView frameworkVersion:@"AppMotion"];
    if(AppMotionVersion)[self.versionLabels addObject:AppMotionVersion];
    
    NSString* AppRelayVersion = [CKCreditsFooterView frameworkVersion:@"AppRelay"];
    if(AppRelayVersion)[self.versionLabels addObject:AppRelayVersion];
    
    NSString* AppRelayUserId = [CKCreditsFooterView appRelayUserId];
    if(AppRelayUserId)[self.versionLabels addObject:[NSString stringWithFormat:@"ar:%@",AppRelayUserId]];
    
    NSString* vendorId = [CKCreditsFooterView vendorId];
    if(vendorId)[self.versionLabels addObject:[NSString stringWithFormat:@"ve:%@",vendorId]];
    
    NSString* advertisingId = [CKCreditsFooterView advertisingId];
    if(advertisingId)[self.versionLabels addObject:[NSString stringWithFormat:@"ad:%@",advertisingId]];
    
    self.plateView = nil;
    switch (self.style) {
        case CKCreditsViewStyleDark:
            self.titleView = [UIImageView imageViewWithImageNamed:@"wc-appsignature-type-dark-craftedby.png"];
            self.plateView = [UIImageView imageViewWithImageNamed:@"wc-appsignature-dark-front.png"];
            break;
            
        default:
            self.titleView = [UIImageView imageViewWithImageNamed:@"wc-appsignature-type-light-craftedby.png"];
            self.plateView = [UIImageView imageViewWithImageNamed:@"wc-appsignature-light-front.png"];
            break;
    }
    
   
    self.versionLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    _versionLabel.backgroundColor = [UIColor clearColor];
    _versionLabel.textAlignment = UITextAlignmentCenter;
    _versionLabel.font = [UIFont systemFontOfSize:14];
    _versionLabel.text = appVersion;
    _versionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _versionLabel.adjustsFontSizeToFitWidth = true;
    [_versionLabel sizeToFit];
    
    switch (self.style) {
        case CKCreditsViewStyleDark:
            _versionLabel.textColor = [UIColor colorWithRGBValue:0xa4a4a4];
            _versionLabel.shadowOffset = CGSizeMake(0, 1);
            _versionLabel.shadowColor = [UIColor colorWithRGBValue:0x000000];
            break;
            
        case CKCreditsViewStyleLight:
            _versionLabel.textColor = [UIColor colorWithRGBValue:0x4c566c];
            _versionLabel.shadowOffset = CGSizeMake(0, 1);
            _versionLabel.shadowColor = [UIColor colorWithRGBValue:0xffffff];
            break;
    }
    
    UIView *plateContainerView = [[[UIView alloc] initWithFrame:self.plateView.frame] autorelease];
    [plateContainerView addSubview:self.plateView];
    
    CGFloat height = topMargin + CGRectGetMaxY(self.titleView.bounds) + titlePlateMargin + CGRectGetMaxY(self.plateView.bounds) + plateVersionMargin + 18;
    self.frame = CGRectIntegral(CGRectMake(0, 0, 320, height));
    
    CGFloat titleViewOffsetX = roundf((CGRectGetMaxX(self.bounds) - CGRectGetMaxX(self.titleView.bounds)) / 2);
    self.titleView.frame = CGRectIntegral(CGRectOffset(self.titleView.frame, titleViewOffsetX, topMargin));
    self.titleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    CGFloat plateViewOffsetX = roundf((CGRectGetMaxX(self.bounds) - CGRectGetMaxX(plateContainerView.bounds)) / 2);
    CGFloat plateViewOffsetY = roundf(CGRectGetMaxY(self.titleView.frame) + titlePlateMargin);
    plateContainerView.frame = CGRectIntegral(CGRectOffset(plateContainerView.frame, plateViewOffsetX, plateViewOffsetY));
    plateContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    CGFloat versionLabelOffsetY = roundf(CGRectGetMaxY(plateContainerView.frame) + plateVersionMargin);
    _versionLabel.frame = CGRectIntegral(CGRectMake(10, versionLabelOffsetY, self.bounds.size.width - 20,_versionLabel.bounds.size.height));
    
    self.versionLabelSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.versionLabelSwitchButton.frame = _versionLabel.frame;
    self.versionLabelSwitchButton.autoresizingMask = _versionLabel.autoresizingMask;
    
    [self.versionLabelSwitchButton addTarget:self action:@selector(toggleVersion:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.titleView];
    [self addSubview:plateContainerView];
    [self addSubview:self.versionLabelSwitchButton];
    [self addSubview:_versionLabel];
    
    __block UILabel* bVersionLabel = _versionLabel;
    UILongPressGestureRecognizer* longPress = [[[UILongPressGestureRecognizer alloc]initWithBlock:^(UIGestureRecognizer *gestureRecognizer) {
        if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
            
            NSString *copyStringverse = _versionLabel.text;
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setString:copyStringverse];
            
            bVersionLabel.alpha = 0;
            [UIView animateWithDuration:1 animations:^{
                bVersionLabel.alpha = 1;
            }];
        }
    }]autorelease];
    longPress.numberOfTapsRequired = 0;
    
    [self.versionLabelSwitchButton addGestureRecognizer:longPress];
}

- (void)setStyle:(CKCreditsViewStyle)theStyle{
    _style = theStyle;
    
    switch (self.style) {
        case CKCreditsViewStyleDark:
            self.titleView.image = [UIImage imageNamed:@"wc-appsignature-type-dark-craftedby.png"];
            self.plateView.image = [UIImage imageNamed:@"wc-appsignature-dark-front.png"];
            _versionLabel.textColor = [UIColor colorWithRGBValue:0xa4a4a4];
            _versionLabel.shadowOffset = CGSizeMake(0, 1);
            _versionLabel.shadowColor = [UIColor colorWithRGBValue:0x000000];
            break;
            
        default:
            self.titleView.image = [UIImage imageNamed:@"wc-appsignature-type-light-craftedby.png"];
            self.plateView.image = [UIImage imageNamed:@"wc-appsignature-light-front.png"];
            _versionLabel.textColor = [UIColor colorWithRGBValue:0x4c566c];
            _versionLabel.shadowOffset = CGSizeMake(0, 1);
            _versionLabel.shadowColor = [UIColor colorWithRGBValue:0xffffff];
            break;
    }
    
}

- (void)toggleVersion:(id)sender{
    self.versionIndex++;
    if(self.versionIndex >= [self.versionLabels count]){
        self.versionIndex = 0;
    }
    _versionLabel.text = [self.versionLabels objectAtIndex:self.versionIndex];
}

+ (id)creditsViewWithStyle:(CKCreditsViewStyle)style {
	return [[[CKCreditsFooterView alloc] initWithStyle:style] autorelease];
}

- (void)dealloc {
	self.titleView = nil;
	self.plateView = nil;
	self.plateBackView = nil;
	self.versionLabel = nil;
    self.versionLabelSwitchButton = nil;
	[super dealloc];
}

- (UIImageView *)plateBackView {
	if (_plateBackView == nil) {
		switch(_style) {
			case CKCreditsViewStyleDark:
				_plateBackView = [[UIImageView imageViewWithImageNamed:@"wc-appsignature-dark-back.png"] retain];
				break;
				
			default:
				_plateBackView = [[UIImageView imageViewWithImageNamed:@"wc-appsignature-light-back.png"] retain];
				break;
		}
		_plateBackView.frame = CGRectOffset(_plateBackView.frame, self.plateView.frame.origin.x, self.plateView.frame.origin.y);
	}
	return _plateBackView;
}

- (void)togglePlateWithDirection:(UISwipeGestureRecognizerDirection)direction {
	[UIView transitionFromView:(_displayingFrontPlate ? self.plateView : self.plateBackView)
						toView:(_displayingFrontPlate ? self.plateBackView : self.plateView)
					  duration:0.4
					   options:((direction & UISwipeGestureRecognizerDirectionRight) ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight)
					completion:^(BOOL finished) {
						_displayingFrontPlate = !_displayingFrontPlate;
					}];
}

- (void)handleLeftSwipeGesture:(UISwipeGestureRecognizer *)gesture { [self togglePlateWithDirection:UISwipeGestureRecognizerDirectionLeft]; }
- (void)handleRightSwipeGesture:(UISwipeGestureRecognizer *)gesture { [self togglePlateWithDirection:UISwipeGestureRecognizerDirectionRight]; }

@end
