//
//  QJToast.m
//  Nimingban
//
//  Created by QinJ on 2017/6/30.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJToast.h"
#import "NSString+StringHeight.h"

@implementation QJToast

+ (void)showWithTip:(NSString *)tip {
    UIFont *font = [UIFont systemFontOfSize:14.f];
    CGFloat width = [tip StringWidthWithFontSize:font];
    CGFloat height = [tip StringHeightWithFontSize:font maxWidth:width] + 20;
    width += 30;
    QJToast *toast = [[QJToast alloc] initWithFrame:CGRectMake((UIScreenWidth() - width) / 2, UIScreenHeight() - 55 - height -UITabBarSafeBottomMargin(), width, height)];
    toast.font = font;
    toast.text = tip;
    [toast show];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.textColor = [UIColor whiteColor];
        self.layer.cornerRadius = self.frame.size.height / 2;
        self.clipsToBounds = YES;
        self.alpha = 0;
    }
    return self;
}

- (void)show {
    UIWindow *windows = [UIApplication sharedApplication].keyWindow;
    [windows addSubview:self];
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [windows bringSubviewToFront:self];
        CGFloat time = MIN((float)self.text.length * 0.06 + 0.3, 5.0);
        //这方法在滚动的时候不会执行
        //[self performSelector:@selector(close) withObject:nil afterDelay:time];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self close];
        });
    }];
}

- (void)close {
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
