//
//  UIView+AutoresizingMasks.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

/**
 */
const static NSUInteger UIViewAutoresizingFlexibleAll =  
  UIViewAutoresizingFlexibleWidth | 
  UIViewAutoresizingFlexibleHeight | 
  UIViewAutoresizingFlexibleTopMargin | 
  UIViewAutoresizingFlexibleBottomMargin | 
  UIViewAutoresizingFlexibleLeftMargin | 
  UIViewAutoresizingFlexibleRightMargin;

const static NSUInteger UIViewAutoresizingFlexibleSize =  
  UIViewAutoresizingFlexibleWidth | 
  UIViewAutoresizingFlexibleHeight;

const static NSUInteger UIViewAutoresizingFlexibleAllMargins =  
  UIViewAutoresizingFlexibleTopMargin | 
  UIViewAutoresizingFlexibleBottomMargin | 
  UIViewAutoresizingFlexibleLeftMargin | 
  UIViewAutoresizingFlexibleRightMargin;

const static NSUInteger UIViewAutoresizingFlexibleHorizontalMargins =  
  UIViewAutoresizingFlexibleLeftMargin | 
  UIViewAutoresizingFlexibleRightMargin;

const static NSUInteger UIViewAutoresizingFlexibleVerticalMargins =  
  UIViewAutoresizingFlexibleTopMargin | 
  UIViewAutoresizingFlexibleBottomMargin;