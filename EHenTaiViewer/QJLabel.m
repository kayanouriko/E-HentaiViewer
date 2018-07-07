//
//  QJLabel.m
//  EHenTaiViewer
//
//  Created by zedmacbook on 2018/6/28.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "QJLabel.h"

@interface QJLabel()

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end

@implementation QJLabel

- (void)setCusRadiusInsets:(BOOL)cusRadiusInsets {
    _cusRadiusInsets = cusRadiusInsets;
    
    self.edgeInsets = UIEdgeInsetsMake(2, 8 + 2, 2, 8 + 2);
    [self sizeToFit];
    
    // CGRect rect = self.frame;
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    UIEdgeInsets insets = self.edgeInsets;
    CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, insets) limitedToNumberOfLines:numberOfLines];
    rect.origin.x -= insets.left;
    rect.origin.y -= insets.top;
    rect.size.width += (insets.left + insets.right);
    rect.size.height += (insets.top + insets.bottom);
    return rect;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}


@end
