//
//  MMButtonMenu.h
//  milemapper
//
//  Created by Stephen Laide on 24/03/2015.
//  Copyright (c) 2015 Stephen Laide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMButtonMenuItem.h"

@protocol MMButtonMenuDelegate;

@interface MMButtonMenu : UIView

@property (nonatomic, weak) id <MMButtonMenuDelegate> delegate;

@property (nonatomic) MMButtonMenuItem *mainMenuItem;
@property (nonatomic) NSMutableArray *menuElements;
@property (nonatomic, copy) NSArray *menuItems;

@property (nonatomic) BOOL isTranslucent;
@property (nonatomic) BOOL isExpanded;
@property (nonatomic) BOOL isAnimating;

- (instancetype)initWithFrame:(CGRect)frame menuItems:(NSArray *)menuItems;
- (void)addSubmenu:(NSArray *)subMenuItems toMenuItem:(MMButtonMenuItem *)menuItem;
- (void)alignRight;
- (void)alignLeft;
- (void)toggleMenu;
- (void)toggleShift;
- (void)setTranslucent:(BOOL)translucent;
- (void)collapseExpandedSubMenus;
- (MMButtonMenuItem *)menuItemWithExpandedSubMenu;

@end

@protocol MMButtonMenuDelegate <NSObject>

@optional

- (void)buttonMenuDidFinishAnimating;
- (void)buttonMenuWillExpand:(MMButtonMenu *)buttonMenu;
- (void)buttonMenuDidExpand:(MMButtonMenu *)buttonMenu;
- (void)buttonMenuWillCollapse:(MMButtonMenu *)buttonMenu;
- (void)buttonMenuDidCollapse:(MMButtonMenu *)buttonMenu;
- (void)buttonMenuWillExpandSubMenuFromMenuItem:(MMButtonMenuItem *)menuItem;
- (void)buttonMenuDidExpandSubMenuFromMenuItem:(MMButtonMenuItem *)menuItem;
- (void)buttonMenuWillCollapseSubMenuFromMenuItem:(MMButtonMenuItem *)menuItem;
- (void)buttonMenuDidCollapseSubMenuFromMenuItem:(MMButtonMenuItem *)menuItem;

@end
