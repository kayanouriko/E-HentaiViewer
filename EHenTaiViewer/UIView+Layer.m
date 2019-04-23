//
//  UIView+Layer.m
//  EHenTaiViewer
//
//  Created by QinJ on 2018/8/26.
//  Copyright © 2018 kayanouriko. All rights reserved.
//

#import "UIView+Layer.h"
#import <objc/runtime.h>

static char *CornerRadiusKey = "CornerRadiusKey";

@implementation UIView (Layer)

#pragma mark - Setter
- (void)setCornerRadius:(CGFloat)cornerRadius {
    objc_setAssociatedObject(self, CornerRadiusKey, @(cornerRadius), OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

#pragma mark - Getter
- (CGFloat)cornerRadius {
    return [objc_getAssociatedObject(self, CornerRadiusKey) floatValue];
}

@end
