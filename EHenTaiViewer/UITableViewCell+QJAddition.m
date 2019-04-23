//
//  UITableViewCell+QJAddition.m
//  bangumitv
//
//  Created by zedmacbook on 2018/11/5.
//  Copyright © 2018 kayanouriko. All rights reserved.
//

#import "UITableViewCell+QJAddition.h"

@implementation UITableViewCell (QJAddition)

- (void)addSectionCornerRadiusWithIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    CGFloat cornerRadius = 5.f;
    self.backgroundColor = UIColor.clearColor;
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGRect bounds = CGRectInset(self.bounds, 0, 0);
    
    if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
        CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
    }
    else if (indexPath.row == 0) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
    }
    else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    }
    else {
        CGPathAddRect(pathRef, nil, bounds);
    }
    layer.path = pathRef;
    CFRelease(pathRef);
    //颜色修改
    layer.fillColor = [UIColor colorWithWhite:1.f alpha:1.f].CGColor;
    /*
    layer.strokeColor=[UIColor blackColor].CGColor;
    if (addLine == YES) {
        CALayer *lineLayer = [[CALayer alloc] init];
        CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
        lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
        lineLayer.backgroundColor = tableView.separatorColor.CGColor;
        [layer addSublayer:lineLayer];
    }
     */
    UIView *testView = [[UIView alloc] initWithFrame:bounds];
    [testView.layer insertSublayer:layer atIndex:0];
    testView.backgroundColor = UIColor.clearColor;
    self.backgroundView = testView;
}

@end
