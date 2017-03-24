//
//  MMButtonMenuItem.m
//  milemapper
//
//  Created by Stephen Laide on 24/03/2015.
//  Copyright (c) 2015 Stephen Laide. All rights reserved.
//

#import "MMButtonMenuItem.h"
#import "MMButtonMenu.h"

CGFloat const kButtonShadowOpacity = 0.4f;
static CGFloat const kButtonDiameter = 44.0f;

@implementation MMButtonMenuItem

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

#pragma mark - Button Setup Methods

- (void)setup {
    self.frame = CGRectMake(0, 0, kButtonDiameter, kButtonDiameter);
    self.backgroundColor = APP_COLOR;
    self.tintColor = [UIColor whiteColor];
    self.adjustsImageWhenHighlighted = NO;
    self.clipsToBounds = YES;
    
    self.layer.cornerRadius = self.frame.size.width / 2;
    /*
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0, 3.0);
    self.layer.shadowOpacity = kButtonShadowOpacity;
    self.layer.shadowRadius = 0.0;
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.layer.bounds cornerRadius:self.layer.cornerRadius] CGPath];
     */
    self.layer.masksToBounds = NO;
}

- (void)setSubMenuItems:(NSArray *)subMenuItems {
    _subMenuItems = subMenuItems;
}

#pragma mark - Button Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.center = CGPointMake(self.center.x, self.center.y + 3.0);
    
    _lastPosition = self.center;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_parentMenu && !_isSubMenuExpanded && !_isSubMenuItem) {
        [_parentMenu collapseExpandedSubMenus];
    }
    
    self.center = CGPointMake(self.center.x, self.center.y - 3.0);
    [super touchesEnded:touches withEvent:event];
}

@end
