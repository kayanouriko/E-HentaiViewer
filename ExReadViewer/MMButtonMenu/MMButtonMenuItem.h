//
//  MMButtonMenuItem.h
//  milemapper
//
//  Created by Stephen Laide on 24/03/2015.
//  Copyright (c) 2015 Stephen Laide. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMButtonMenu;

@interface MMButtonMenuItem : UIButton

extern const CGFloat kButtonShadowOpacity;

@property (nonatomic, weak) MMButtonMenu *parentMenu;
@property (nonatomic, copy) NSArray *subMenuItems;
@property (nonatomic) NSInteger menuIndex;
@property (assign) CGPoint lastPosition;

@property (nonatomic) BOOL isSubMenuExpanded;
@property (nonatomic) BOOL isSubMenuItem;

@end
