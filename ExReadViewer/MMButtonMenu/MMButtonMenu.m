//
//  MMButtonMenu.m
//  milemapper
//
//  Created by Stephen Laide on 24/03/2015.
//  Copyright (c) 2015 Stephen Laide. All rights reserved.
//

#import "MMButtonMenu.h"
static CGFloat const kMainMenuButtonRotationAngle = 1;
static CGFloat const kAnchorPointXOffset = 45.0f;
static CGFloat const kAnchorPointYOffset = 80.0f;
static CGFloat const kButtonAlphaOpaque = 1.0f;
static CGFloat const kButtonAlphaTranslucent = 0.4f;
static CGFloat const kButtonMovementAnimationDuration = 0.25f;
static CGFloat const kButtonOpacityAnimationDuration = 0.22f;
static CGFloat const kButtonReturnAnimationDuration = 0.2f;
static CGFloat const kMenuItemAnimationDelayIncrement = 0.1f;
static CGFloat const kShiftXOffset = kAnchorPointXOffset * 2;
static CGFloat const kSubMenuButtonMovementAnimationDuration = 0.2f;
static NSInteger const kButtonSpacingUnit = 60;

typedef void (^AnimationBlock)(BOOL);

@implementation MMButtonMenu {
    BOOL _didSetup;
    NSMutableArray *_animationQueue;
    AnimationBlock (^_getNextAnimationBlock)();
    CGPoint _anchorPoint;
}

- (instancetype)initWithFrame:(CGRect)frame menuItems:(NSArray *)menuItems {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _menuItems = menuItems;
        _didSetup = NO;
    }
    
    return self;
}

- (void)layoutSubviews {
    if (!_didSetup) {
        _anchorPoint = [self rightAnchorPointForFrame:self.frame];
        [self setup];
        _didSetup = YES;
    }
}

#pragma mark - Menu Setup Methods

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    _isTranslucent = NO;
    _isExpanded = NO;
    _isAnimating = NO;
    
    NSInteger menuIndex = [_menuItems count];
    
    for (MMButtonMenuItem *menuItem in [_menuItems reverseObjectEnumerator]) {
        menuItem.parentMenu = self;
        menuItem.menuIndex = menuIndex;
        menuIndex--;
        menuItem.center = _anchorPoint;
        menuItem.alpha = 0.0;
        menuItem.hidden = YES;
        
        if (menuItem.subMenuItems) {
            [self addSubmenu:menuItem.subMenuItems toMenuItem:menuItem];
        }
        
        [self addSubview:menuItem];
    }
    
    _mainMenuItem = [[MMButtonMenuItem alloc] init];
    _mainMenuItem.center = _anchorPoint;
    _mainMenuItem.tintColor = [UIColor whiteColor];
    _mainMenuItem.menuIndex = 0;
    [_mainMenuItem addTarget:self
                      action:@selector(toggleMenu)
            forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *menuImage = [[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_mainMenuItem setImage:menuImage forState:UIControlStateNormal];
    
    [self addSubview:_mainMenuItem];
    
    _menuElements = [[NSMutableArray alloc] initWithObjects:_mainMenuItem, nil];
    
    for (MMButtonMenuItem *menuItem in _menuItems) {
        [_menuElements addObject:menuItem];
    }
    
    [self setupAnimationQueue];
    [self.superview bringSubviewToFront:self];
}

- (void)addSubmenu:(NSArray *)subMenuItems toMenuItem:(MMButtonMenuItem *)menuItem {
    if (!menuItem.isSubMenuItem) {
        NSInteger buttonIndex = 1;
        
        for (MMButtonMenuItem *subMenuItem in [subMenuItems reverseObjectEnumerator]) {
            subMenuItem.parentMenu = self;
            subMenuItem.isSubMenuItem = YES;
            subMenuItem.center = menuItem.center;
            subMenuItem.alpha = 0.0;
            subMenuItem.hidden = YES;
            subMenuItem.menuIndex = buttonIndex;
            [self insertSubview:subMenuItem belowSubview:menuItem];
            buttonIndex++;
        }
        
        menuItem.subMenuItems = subMenuItems;
        menuItem.isSubMenuExpanded = NO;
        [menuItem removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [menuItem addTarget:self action:@selector(toggleSubMenu:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (CGPoint)rightAnchorPointForFrame:(CGRect)frame {
    return CGPointMake(frame.size.width - kAnchorPointXOffset, frame.size.height - kAnchorPointYOffset);
}

- (CGPoint)leftAnchorPointForFrame:(CGRect)frame {
    return CGPointMake(kAnchorPointXOffset, frame.size.height - kAnchorPointYOffset);
}

- (void)alignRight {
    _anchorPoint = [self rightAnchorPointForFrame:self.frame];
    _mainMenuItem.center = _anchorPoint;
    
    for (MMButtonMenuItem *menuItem in _menuItems) {
        menuItem.center = CGPointMake(_anchorPoint.x, menuItem.bounds.origin.y);
    }
}

- (void)alignLeft {
    _anchorPoint = [self leftAnchorPointForFrame:self.frame];
    _mainMenuItem.center = _anchorPoint;
    
    for (MMButtonMenuItem *menuItem in _menuItems) {
        menuItem.center = CGPointMake(_anchorPoint.x, menuItem.bounds.origin.y);
    }
}

- (BOOL)isRightAligned {
    if (_anchorPoint.x == (self.frame.size.width - kAnchorPointXOffset)) {
        return YES;
    }
    return NO;
}

- (BOOL)isLeftAligned {
    if (_anchorPoint.x == kAnchorPointXOffset) {
        return YES;
    }
    return NO;
}

#pragma mark - Menu Visibility Methods

- (void)setMenuItemsHidden:(BOOL)hidden {
    for (MMButtonMenuItem *menuItem in _menuItems) {
        menuItem.hidden = hidden;
    }
}

- (void)setSubMenuItems:(NSArray *)subMenuItems hidden:(BOOL)hidden {
    for (MMButtonMenuItem *subMenuItem in subMenuItems) {
        subMenuItem.hidden = hidden;
    }
}

- (void)setTranslucent:(BOOL)translucent {
    CGFloat menuOpacity = translucent ? kButtonAlphaTranslucent : kButtonAlphaOpaque;
    
    [UIView animateWithDuration:kButtonOpacityAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void){
                         _mainMenuItem.alpha = menuOpacity;
                         
                         for (MMButtonMenuItem *menuItem in _menuItems) {
                             menuItem.alpha = menuOpacity;
                             
                             if (menuItem.subMenuItems) {
                                 [self menuItem:menuItem setSubMenuItemsTranslucent:translucent];
                             }
                         }
                     }
                     completion:^(BOOL finished){
                         _isTranslucent = translucent;
                     }];
}

- (void)menuItem:(MMButtonMenuItem *)menuItem setSubMenuItemsTranslucent:(BOOL)translucent {
    CGFloat menuOpacity = translucent ? kButtonAlphaTranslucent : kButtonAlphaOpaque;
    
    for (MMButtonMenuItem *subMenuItem in menuItem.subMenuItems) {
        subMenuItem.alpha = menuOpacity;
    }
}

#pragma mark - Button Return Method

- (void)queueButtonReturnAnimation:(MMButtonMenuItem *)button {
    __weak typeof(self) weakSelf = self;
    
    [_animationQueue addObject:^(BOOL finished){
        __strong typeof(self) strongSelf = weakSelf;
        
        [weakSelf setUserInteractionEnabled:NO];
        
        [UIView animateWithDuration:kButtonReturnAnimationDuration
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             button.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             button.transform = CGAffineTransformMakeScale(1, 1);
                             button.center = button.lastPosition;
                             [UIView animateWithDuration:kButtonReturnAnimationDuration
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  button.alpha = 1.0;
                                              }
                                              completion:^(BOOL finished){
                                                  [weakSelf setUserInteractionEnabled:YES];
                                                  strongSelf->_getNextAnimationBlock()(YES);
                                              }];
                         }];
    }];
}

#pragma mark - Menu Item Touch Event Methods

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.alpha > 0 && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    return NO;
}

#pragma mark - Animation Queue Methods

- (void)setupAnimationQueue {
    _animationQueue = [NSMutableArray new];
    
    __weak typeof(self) weakSelf = self;
    
    _getNextAnimationBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        
        AnimationBlock block = strongSelf->_animationQueue.count ? (AnimationBlock)[strongSelf->_animationQueue objectAtIndex:0] : nil;
        
        if (block){
            strongSelf->_isAnimating = YES;
            [strongSelf->_animationQueue removeObjectAtIndex:0];
            return block;
        } else {
            return ^(BOOL finished){
                strongSelf->_isAnimating = NO;
                
                if ([strongSelf->_delegate respondsToSelector:@selector(buttonMenuDidFinishAnimating)]) {
                    [strongSelf->_delegate buttonMenuDidFinishAnimating];
                }
            };
        }
    };
}

- (void)triggerAnimationQueue {
    if (!_isAnimating) {
        _getNextAnimationBlock()(YES);
    }
}

#pragma mark - Menu Animation Methods

- (void)toggleMenu {
    if (_isExpanded) {
        MMButtonMenuItem *menuItemWithExpandedSubMenu = [self menuItemWithExpandedSubMenu];
        
        if (menuItemWithExpandedSubMenu) {
            [self queueCollapseSubMenuAnimationForMenuItem:menuItemWithExpandedSubMenu];
        }
        
        [self queueCollapseAnimation];
    } else {
        [self queueExpandAnimation];
    }
    
    [self triggerAnimationQueue];
}

- (void)queueExpandAnimation {
    __weak typeof(self) weakSelf = self;
    
    [_animationQueue addObject:^(BOOL finished){
        __strong typeof(self) strongSelf = weakSelf;
        
        if ([strongSelf->_delegate respondsToSelector:@selector(buttonMenuWillExpand:)]) {
            [strongSelf->_delegate buttonMenuWillExpand:strongSelf];
        }
        
        [weakSelf setMenuItemsHidden:NO];
        [weakSelf setUserInteractionEnabled:NO];
        
        CGFloat delay = 0.0;
        CGFloat itemOffset = kButtonSpacingUnit * [_menuItems count];
        
        strongSelf->_mainMenuItem.imageView.clipsToBounds = NO;
        strongSelf->_mainMenuItem.imageView.contentMode = UIViewContentModeCenter;
        
        CGFloat degrees = kMainMenuButtonRotationAngle;
        CGFloat radians = (degrees/180.0) * M_PI;
        
        CGFloat duration = kButtonMovementAnimationDuration + (kMenuItemAnimationDelayIncrement * ([_menuItems count] - 1));
        
        [UIView animateWithDuration:duration
                         animations:^{
                             strongSelf->_mainMenuItem.imageView.transform = CGAffineTransformMakeRotation(radians);
                         }];
        
        
        for (MMButtonMenuItem *menuItem in [strongSelf->_menuItems reverseObjectEnumerator]) {
            [UIView animateWithDuration:kButtonMovementAnimationDuration
                                  delay:delay
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 menuItem.center = CGPointMake(menuItem.center.x, menuItem.center.y - itemOffset);
                                 menuItem.alpha = 1.0;
                                 
                                 if (menuItem.subMenuItems) {
                                     for (MMButtonMenuItem *subMenuItem in menuItem.subMenuItems) {
                                         subMenuItem.center = menuItem.center;
                                     }
                                 }
                             }
                             completion:^(BOOL finished){
                                 if ([menuItem isEqual:[strongSelf->_menuItems firstObject]]) {
                                     _isExpanded = YES;
                                     [weakSelf setUserInteractionEnabled:YES];
                                     
                                     if ([strongSelf->_delegate respondsToSelector:@selector(buttonMenuDidExpand:)]) {
                                         [strongSelf->_delegate buttonMenuDidExpand:strongSelf];
                                     }
                                     
                                     strongSelf->_getNextAnimationBlock()(YES);
                                 }
                             }];
            
            delay += kMenuItemAnimationDelayIncrement;
            itemOffset -= kButtonSpacingUnit;
        }
    }];
}

- (void)queueCollapseAnimation {
    __weak typeof(self) weakSelf = self;
    
    [_animationQueue addObject:^(BOOL finished){
        __strong typeof(self) strongSelf = weakSelf;
        
        if ([strongSelf->_delegate respondsToSelector:@selector(buttonMenuWillCollapse:)]) {
            [strongSelf->_delegate buttonMenuWillCollapse:strongSelf];
        }
        
        [weakSelf setUserInteractionEnabled:NO];
        
        CGFloat delay = 0.0;
        CGFloat duration = kButtonMovementAnimationDuration + (kMenuItemAnimationDelayIncrement * ([_menuItems count] - 1));
        
        [UIView animateWithDuration:duration
                         animations:^{
                             strongSelf->_mainMenuItem.imageView.transform = CGAffineTransformIdentity;
                         }];
        
        for (MMButtonMenuItem *menuItem in strongSelf->_menuItems) {
            [UIView animateWithDuration:kButtonMovementAnimationDuration
                                  delay:delay
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 menuItem.center = strongSelf->_mainMenuItem.center;
                                 menuItem.alpha = 0.0;
                                 
                                 if (menuItem.subMenuItems) {
                                     for (MMButtonMenuItem *subMenuItem in menuItem.subMenuItems) {
                                         subMenuItem.center = menuItem.center;
                                     }
                                 }
                             }
                             completion:^(BOOL finished){
                                 if ([menuItem isEqual:[strongSelf->_menuItems lastObject]]) {
                                     _isExpanded = NO;
                                     [weakSelf setUserInteractionEnabled:YES];
                                     [weakSelf setMenuItemsHidden:YES];
                                     
                                     if ([strongSelf->_delegate respondsToSelector:@selector(buttonMenuDidCollapse:)]) {
                                         [strongSelf->_delegate buttonMenuDidCollapse:strongSelf];
                                     }
                                     
                                     strongSelf->_getNextAnimationBlock()(YES);
                                 }
                             }];
            
            delay += kMenuItemAnimationDelayIncrement;
        }
    }];
}

#pragma mark - Sub Menu Animation Methods

- (void)toggleSubMenu:(id)sender {
    MMButtonMenuItem *menuItem = (MMButtonMenuItem *)sender;

    if (menuItem.isSubMenuExpanded) {
        [self queueCollapseSubMenuAnimationForMenuItem:menuItem];
    } else {
        MMButtonMenuItem *menuItemWithExpandedSubMenu = [self menuItemWithExpandedSubMenu];

        if (menuItemWithExpandedSubMenu) {
            [self queueCollapseSubMenuAnimationForMenuItem:menuItemWithExpandedSubMenu];
        }

        [self queueExpandSubMenuAnimationForMenuItem:menuItem];
    }
    
    [self triggerAnimationQueue];
}

- (void)queueExpandSubMenuAnimationForMenuItem:(MMButtonMenuItem *)menuItem {
    __weak typeof(self) weakSelf = self;
    
    [_animationQueue addObject:^(BOOL finished){
        __strong typeof(self) strongSelf = weakSelf;
        
        if ([strongSelf->_delegate respondsToSelector:@selector(buttonMenuWillExpandSubMenuFromMenuItem:)]) {
            [strongSelf->_delegate buttonMenuWillExpandSubMenuFromMenuItem:menuItem];
        }
        
        [weakSelf setSubMenuItems:menuItem.subMenuItems hidden:NO];
        [weakSelf setUserInteractionEnabled:NO];
        
        CGFloat delay = 0.0;
        CGFloat itemOffset = kButtonSpacingUnit * [menuItem.subMenuItems count];
        NSInteger scalingFactor = 1;
        
        if ([weakSelf isRightAligned]) {
            itemOffset = -(itemOffset);
        }
        
        for (MMButtonMenuItem *subMenuItem in [menuItem.subMenuItems reverseObjectEnumerator]) {
            [UIView animateWithDuration:kSubMenuButtonMovementAnimationDuration
                                  delay:delay
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 subMenuItem.center = CGPointMake(menuItem.center.x + itemOffset, menuItem.center.y);
                                 subMenuItem.alpha = 1.0;
                             }
                             completion:^(BOOL finished){
                                 if ([subMenuItem isEqual:[menuItem.subMenuItems firstObject]]) {
                                     menuItem.isSubMenuExpanded = YES;
                                     [weakSelf setUserInteractionEnabled:YES];
                                     
                                     if ([strongSelf->_delegate respondsToSelector:@selector(buttonMenuDidExpandSubMenuFromMenuItem:)]) {
                                         [strongSelf->_delegate buttonMenuDidExpandSubMenuFromMenuItem:menuItem];
                                     }
                                     
                                     strongSelf->_getNextAnimationBlock()(YES);
                                 }
                             }];
            
            delay += kMenuItemAnimationDelayIncrement;
            scalingFactor++;
            
            if (itemOffset > 0) {
                itemOffset -= kButtonSpacingUnit;
            } else {
                itemOffset += kButtonSpacingUnit;
            }
        }
    }];
}

- (void)queueCollapseSubMenuAnimationForMenuItem:(MMButtonMenuItem *)menuItem {
    __weak typeof(self) weakSelf = self;
    
    [_animationQueue addObject:^(BOOL finished){
        __strong typeof(self) strongSelf = weakSelf;
        
        if ([strongSelf->_delegate respondsToSelector:@selector(buttonMenuWillCollapseSubMenuFromMenuItem:)]) {
            [strongSelf->_delegate buttonMenuWillCollapseSubMenuFromMenuItem:menuItem];
        }
        
        [weakSelf setUserInteractionEnabled:NO];
        CGFloat delay = 0.0;
        
        for (MMButtonMenuItem *subMenuItem in menuItem.subMenuItems) {
            [UIView animateWithDuration:kSubMenuButtonMovementAnimationDuration
                                  delay:delay
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 subMenuItem.center = CGPointMake(menuItem.center.x, menuItem.center.y);
                                 subMenuItem.alpha = 0.0;
                             }
                             completion:^(BOOL finished){
                                 if ([subMenuItem isEqual:[menuItem.subMenuItems lastObject]]) {
                                     menuItem.isSubMenuExpanded = NO;
                                     [weakSelf setUserInteractionEnabled:YES];
                                     [weakSelf setSubMenuItems:menuItem.subMenuItems hidden:YES];
                                     
                                     if ([strongSelf->_delegate respondsToSelector:@selector(buttonMenuDidCollapseSubMenuFromMenuItem:)]) {
                                         [strongSelf->_delegate buttonMenuDidCollapseSubMenuFromMenuItem:menuItem];
                                     }
                                     
                                     strongSelf->_getNextAnimationBlock()(YES);
                                 }
                             }];
            
            delay += kMenuItemAnimationDelayIncrement;
        }
    }];
}

- (void)collapseExpandedSubMenus {
    for (MMButtonMenuItem *menuItem in _menuItems) {
        
        if (menuItem.subMenuItems && menuItem.isSubMenuExpanded) {
            [self queueCollapseSubMenuAnimationForMenuItem:menuItem];
        }
    }
    
    [self triggerAnimationQueue];
}

- (MMButtonMenuItem *)menuItemWithExpandedSubMenu {
    for (MMButtonMenuItem *menuItem in _menuItems) {
        if (menuItem.subMenuItems && menuItem.isSubMenuExpanded) {
            return menuItem;
        }
    }
    return nil;
}

#pragma mark - Shift Animation Methods

- (void)toggleShift {
    MMButtonMenuItem *menuItemWithExpandedSubMenu = [self menuItemWithExpandedSubMenu];
    
    if (menuItemWithExpandedSubMenu) {
        [self queueCollapseSubMenuAnimationForMenuItem:menuItemWithExpandedSubMenu];
    }
    
    [self queueShiftAnimation];
    [self triggerAnimationQueue];
}

- (void)queueShiftAnimation {
    __weak typeof(self) weakSelf = self;
    
    [_animationQueue addObject:^(BOOL finished){
        __strong typeof(self) strongSelf = weakSelf;
        
        CGFloat shiftOffset = kShiftXOffset;
        
        if (([weakSelf isLeftAligned] && _mainMenuItem.center.x == _anchorPoint.x) || ([weakSelf isRightAligned] && strongSelf->_mainMenuItem.center.x != strongSelf->_anchorPoint.x)) {
            shiftOffset = -(shiftOffset);
        }
        
        [weakSelf setUserInteractionEnabled:NO];
        __block CGFloat delay = 0.0;
        
        if (strongSelf->_isExpanded) {
            for (MMButtonMenuItem *menuElement in strongSelf->_menuElements) {
                [UIView animateWithDuration:kButtonMovementAnimationDuration
                                      delay:delay
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     menuElement.center = CGPointMake(menuElement.center.x + shiftOffset, menuElement.center.y);
                                 }
                                 completion:^(BOOL finished){
                                     if ([menuElement isEqual:[strongSelf->_menuElements lastObject]]) {
                                         [weakSelf setUserInteractionEnabled:YES];
                                         strongSelf->_getNextAnimationBlock()(YES);
                                     }
                                 }];
                
                delay += kMenuItemAnimationDelayIncrement;
            }
        } else {
            [UIView animateWithDuration:kButtonMovementAnimationDuration
                                  delay:delay
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 for (MMButtonMenuItem *menuElement in strongSelf->_menuElements) {
                                     menuElement.center = CGPointMake(menuElement.center.x + shiftOffset, menuElement.center.y);
                                 }
                             }
                             completion:^(BOOL finished){
                                 [weakSelf setUserInteractionEnabled:YES];
                                 strongSelf->_getNextAnimationBlock()(YES);
                             }];
        }
    }];
}

@end
