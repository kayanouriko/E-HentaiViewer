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
    self.bgView.alpha = 0;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(window);
    }];
    
    [UIView animateWithDuration:0.26f animations:^{
        self.bgView.alpha = 1;
    }];
}

- (void)hiddenSecretBackground {
    [UIView animateWithDuration:0.26f animations:^{
        self.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
    }];
}

#pragma mark - Setter
- (UIView *)bgView {
    if (nil == _bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch"]];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_bgView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(imageView.mas_width).multipliedBy(111.f / 71.f);
            make.width.equalTo(@200);
            make.center.equalTo(self -> _bgView);
        }];
    }
    return _bgView;
}

@end
