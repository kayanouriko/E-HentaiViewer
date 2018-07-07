//
//  QJSecretBgTool.m
//  EHenTaiViewer
//
//  Created by zedmacbook on 2018/7/3.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "QJSecretBgTool.h"

@interface QJSecretBgTool()

@property (nonatomic, strong) UIView *bgView;

@end

@implementation QJSecretBgTool

+ (instancetype)sharedInstance {
    static QJSecretBgTool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [QJSecretBgTool new];
    });
    return sharedInstance;
}

- (void)showSecretBackground {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.bgView];
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_bgView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bgView)]];
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_bgView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bgView)]];
}

- (void)hiddenSecretBackground {
    [self.bgView removeFromSuperview];
}

#pragma mark - Setter
- (UIView *)bgView {
    if (nil == _bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LOGO"]];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_bgView addSubview:imageView];
        [_bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(230)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
        [_bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(230)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
        [_bgView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bgView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [_bgView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_bgView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        _bgView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _bgView;
}

@end
