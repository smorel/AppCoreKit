//
//  CKUITableView+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUITableView+Style.h"


@implementation UITableView (CKStyle)

+ (BOOL)applyStyle:(NSDictionary*)style toView:(UIView*)view propertyName:(NSString*)propertyName appliedStack:(NSMutableSet*)appliedStack{
	UITableView* tableView = (UITableView*)view;
	
	NSDictionary* myViewStyle = [style styleForObject:tableView propertyName:propertyName];
	tableView.backgroundView = [[[UIView alloc]initWithFrame:view.bounds]autorelease];
	tableView.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[UIView applyStyle:myViewStyle toView:tableView.backgroundView propertyName:@"backgroundView" appliedStack:appliedStack];
	if([UIView applyStyle:style toView:view propertyName:propertyName appliedStack:appliedStack]){
		return YES;
	}
	return NO;
}

@end