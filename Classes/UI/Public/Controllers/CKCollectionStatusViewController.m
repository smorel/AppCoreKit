//
//  CKCollectionStatusViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKCollectionStatusViewController.h"

@interface CKCollectionStatusViewController()
@property(nonatomic,retain,readwrite) CKCollection* collection;
@end

@implementation CKCollectionStatusViewController

- (instancetype)initWithCollection:(CKCollection*)collection{
    self = [super init];
    self.collection = collection;
    return self;
}

+ (instancetype)controllerWithCollection:(CKCollection*)collection{
    return [[[[self class]alloc]initWithCollection:collection]autorelease];
}

- (void)postInit{
    [super postInit];
    self.noObjectTitleFormat = _(@"No object");
    self.oneObjectTitleFormat = _(@"1 object");
    self.multipleObjectTitleFormat = _(@"%d objects");
}

- (void)dealloc{
    [_collection release];
    [_noObjectTitleFormat release];
    [_oneObjectTitleFormat release];
    [_multipleObjectTitleFormat release];
    [super dealloc];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    self.view.minimumHeight = 44;
    
    if([self isLayoutDefinedInStylesheet])
        return;
    
    UIActivityIndicatorView* ActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    ActivityIndicatorView.name = @"ActivityIndicatorView";
    
    UILabel* TitleLabel = [[UILabel alloc]init];
    TitleLabel.name = @"TitleLabel";
    TitleLabel.font = [UIFont boldSystemFontOfSize:17];
    TitleLabel.textColor = [UIColor blackColor];
    TitleLabel.numberOfLines = 1;
    TitleLabel.textAlignment = UITextAlignmentCenter;
    
    UILabel* SubtitleLabel = [[UILabel alloc]init];
    SubtitleLabel.name = @"SubtitleLabel";
    SubtitleLabel.font = [UIFont systemFontOfSize:14];
    SubtitleLabel.textColor = [UIColor blackColor];
    SubtitleLabel.numberOfLines = 1;
    SubtitleLabel.textAlignment = UITextAlignmentCenter;
    
    CKVerticalBoxLayout* vbox = [[[CKVerticalBoxLayout alloc]init]autorelease];
    vbox.flexibleSize = YES;
    vbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[ActivityIndicatorView,TitleLabel,SubtitleLabel]];
  
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[vbox]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    if(!self.view)
        return;
    
    [self.view beginBindingsContextWithScope:@"CKCollectionStatusViewController"];
    [self setupBindings];
    [self.view endBindingsContext];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view clearBindingsContextWithScope:@"CKCollectionStatusViewController"];
}

- (void)setupBindings{
    __unsafe_unretained CKCollectionStatusViewController* bself = self;
    [self.collection bind:@"isFetching" withBlock:^(id value) {
        [bself update];
    }];
    [self.collection bind:@"count" executeBlockImmediatly:YES withBlock:^(id value) {
        [bself update];
    }];
}

- (void)update{
    UIActivityIndicatorView* ActivityIndicatorView = [self.view viewWithName:@"ActivityIndicatorView"];
    UILabel* TitleLabel = [self.view viewWithName:@"TitleLabel"];
    UILabel* SubtitleLabel = [self.view viewWithName:@"SubtitleLabel"];
    
    ActivityIndicatorView.hidden = !self.collection.isFetching || self.view.frame.size.width <= 0 || self.view.frame.size.height <= 0;
    if(!ActivityIndicatorView.hidden){
        [ActivityIndicatorView startAnimating];
    }
    else{
        [ActivityIndicatorView stopAnimating];
    }
    
    TitleLabel.hidden = !ActivityIndicatorView.hidden;
    SubtitleLabel.hidden = [self.subtitleLabel length] <= 0;
    SubtitleLabel.text = self.subtitleLabel;
    
    if(ActivityIndicatorView.hidden){
        switch(self.collection.count){
            case 0:{
                TitleLabel.text = [NSString stringWithFormat:_(self.noObjectTitleFormat),self.collection.count];
                break;
            }
            case 1:{
                TitleLabel.text = [NSString stringWithFormat:_(self.oneObjectTitleFormat),self.collection.count];
                break;
            }
            default:{
                TitleLabel.text = [NSString stringWithFormat:_(self.multipleObjectTitleFormat),self.collection.count];
                break;
            }
        }
    }else{
        TitleLabel.text = nil;
    }

}

@end