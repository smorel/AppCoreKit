//
//  CKImageView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-23.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKImageView.h"
#import "NSObject+Singleton.h"
#import "CKPropertyExtendedAttributes.h"
#import "UIView+Positioning.h"
#import "UIView+Snapshot.h"

@interface CKImageView()<CKImageCacheDelegate>
@property(nonatomic,retain) UIImageView* defaultImageView;
@property(nonatomic,retain) UIImageView* imageView;
@property(nonatomic,retain) UIActivityIndicatorView* activityIndicatorView;
@end


@implementation CKImageView

- (void)dealloc{
    if(self.imageURL){
        [[CKImageCache sharedInstance]unregisterDelegate:self withImageURL:self.imageURL];
    }
    
    [_defaultImage release];
    [_image release];
    [_imageURL release];
    [_postProcess release];
    [_defaultImageView release];
    [_imageView release];
    [_activityIndicatorView release];
    [super dealloc];
}

- (instancetype)init{
    self = [super init];
    self.spinnerStyle = CKImageViewSpinnerStyleWhite;
    self.fadeInDuration = 0.25;
    self.userInteractionEnabled = NO;
    self.animateLoadingOfImagesLoadedFromCache = NO;
    return self;
}

- (void)spinnerStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKImageViewSpinnerStyle",
                                                 CKImageViewSpinnerStyleWhiteLarge,
                                                 CKImageViewSpinnerStyleWhite,
                                                 CKImageViewSpinnerStyleGray,
                                                 CKImageViewSpinnerStyleNone,
                                                 UIActivityIndicatorViewStyleWhiteLarge,
                                                 UIActivityIndicatorViewStyleWhite,
                                                 UIActivityIndicatorViewStyleGray);
}

- (void)setDefaultImage:(UIImage *)defaultImage{
    if(_defaultImage && _defaultImage == defaultImage)
        return;
    
    [_defaultImage release];
    _defaultImage = [defaultImage retain];
    [self updateAnimated:NO];
}

- (void)setImage:(UIImage *)image{
    [self setImage:image animated:NO];
}

- (void)setImage:(UIImage*)image animated:(BOOL)animated{
    if(self.imageURL){
        [[CKImageCache sharedInstance]unregisterDelegate:self withImageURL:self.imageURL];
        self.imageURL = nil;
    }
    
    if(_image && _image == image)
        return;
    
    [self _setImage:image animated:animated];
}

- (void)_setImage:(UIImage *)image animated:(BOOL)animated{
    if(image && self.postProcess){
        image = self.postProcess(image);
    }
    
    [_image release];
    _image = [image retain];
    [self updateAnimated:animated];
}

- (void)setImageURL:(NSURL *)imageURL{
    if(_imageURL && [_imageURL isEqual:imageURL])
        return;
    
    if(_imageURL){
        [[CKImageCache sharedInstance]unregisterDelegate:self withImageURL:_imageURL];
    }
    
    [_imageURL release];
    _imageURL = [imageURL retain];
    
    [self updateAnimated:NO];//activate spinner
    
    if(_imageURL){
        [[CKImageCache sharedInstance]registerDelegate:self withImageURL:_imageURL];
    }
}

- (void)imageWasAlreadyFetched:(UIImage*)image{
    [self _setImage:image animated:self.animateLoadingOfImagesLoadedFromCache];
}

- (void)didFetchImage:(UIImage*)image{
    [self _setImage:image animated:YES];
}

- (void)didFailFetchingImage:(NSError*)error{
    //???
}

- (void)setContentMode:(UIViewContentMode)contentMode{
    [super setContentMode:contentMode];
    
    self.defaultImageView.contentMode = contentMode;
    self.imageView.contentMode = contentMode;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.defaultImageView.frame = self.bounds;
    self.imageView.frame = self.bounds;
    [self.activityIndicatorView sizeToFit];
    self.activityIndicatorView.center = CGPointMake(self.width/2,self.height/2);
}

- (void)updateAnimated:(BOOL)animated{
    [self.activityIndicatorView  stopAnimating];
    
    if(self.image && (!self.imageView || self.imageView.image != self.image)){
        UIImageView* previousImageView = self.imageView;
        
        UIImageView* imageView = [[UIImageView alloc]initWithImage:self.image];
        imageView.frame = self.bounds;
        imageView.contentMode = self.contentMode;
        imageView.backgroundColor = self.backgroundColor;
        
        imageView.alpha = 0;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        [UIView animateWithDuration:(self.window && animated) ? self.fadeInDuration : 0 animations:^{
            self.activityIndicatorView.alpha = 0;
            self.defaultImageView.alpha = 0;
            previousImageView.alpha = 0;
            self.imageView.alpha = 1;
        } completion:^(BOOL finished) {
            [self.activityIndicatorView removeFromSuperview];
            [self.defaultImageView removeFromSuperview];
            [previousImageView removeFromSuperview];
        }];
    }else{
        if(!self.defaultImageView){
            self.defaultImageView = [[UIImageView alloc]init];
            self.defaultImageView.frame = self.bounds;
            self.defaultImageView.contentMode = self.contentMode;
            [self addSubview:self.defaultImageView];
        }
        
        self.defaultImageView.backgroundColor = self.backgroundColor;
        self.defaultImageView.image = self.defaultImage;
        
        if(self.imageURL && !self.image){
            if(self.spinnerStyle != CKImageViewSpinnerStyleNone){
                if(!self.activityIndicatorView){
                    self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)self.spinnerStyle];
                }
                
                self.activityIndicatorView.backgroundColor = self.backgroundColor;
                
                [self addSubview:self.activityIndicatorView];
                self.activityIndicatorView.activityIndicatorViewStyle = (UIActivityIndicatorViewStyle)self.spinnerStyle;
                
                [self.activityIndicatorView sizeToFit];
                self.activityIndicatorView.center = CGPointMake(self.width/2,self.height/2);
                [self.activityIndicatorView  startAnimating];
                
            }else{
                [self.activityIndicatorView removeFromSuperview];
            }
        }
    }
    
}

@end




@implementation CKImageView(Deprecated)

- (void)loadImageWithContentOfURL:(NSURL *)url{
    self.imageURL = url;
}

- (void)setImageViewContentMode:(UIViewContentMode)imageViewContentMode{
    self.contentMode = imageViewContentMode;
}

- (UIViewContentMode)imageViewContentMode{
    return self.contentMode;
}

- (void)setInteractive:(BOOL)interactive{
    self.userInteractionEnabled = interactive;
}

- (BOOL)interactive{
    return self.userInteractionEnabled;
}

@end