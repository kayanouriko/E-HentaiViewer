//
//  QJTipViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/11/30.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJTipViewController.h"

@interface QJTipViewController ()

@property (nonatomic, strong) NSString *tip;
@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *tiplabel;

@end

@implementation QJTipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
}

- (void)setContent {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bgView];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bgView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bgView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

- (void)startAnimateWithTip:(NSString *)tip {
    if (tip && tip.length) {
        self.tiplabel.text = tip;
    }
    else {
        self.tiplabel.text = @"正在载入";
    }
    [self.activity startAnimating];
}

- (void)stopAnimateWithTip:(NSString *)tip {
    if (tip && tip.length) {
        self.tiplabel.text = tip;
    }
    else {
        self.tiplabel.text = @"载入出错";
    }
    [self.activity stopAnimating];
}

#pragma mark -getter
- (UIView *)bgView {
    if (nil == _bgView) {
        _bgView = [UIView new];
        _bgView.translatesAutoresizingMaskIntoConstraints = NO;
        _bgView.backgroundColor = [UIColor clearColor];
        [_bgView addSubview:self.activity];
        [_bgView addSubview:self.tiplabel];
        [_bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_activity]-5-[_tiplabel]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_activity, _tiplabel)]];
        [_bgView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tiplabel]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tiplabel)]];
        [_bgView addConstraint:[NSLayoutConstraint constraintWithItem:_activity attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bgView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    }
    return _bgView;
}

- (UIActivityIndicatorView *)activity {
    if (nil == _activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _activity;
}

- (UILabel *)tiplabel {
    if (nil == _tiplabel) {
        _tiplabel = [UILabel new];
        _tiplabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tiplabel.textColor = [UIColor lightGrayColor];
        _tiplabel.font = [UIFont systemFontOfSize:12.f];
        _tiplabel.text = @"正在载入";
    }
    return _tiplabel;
}

@end
