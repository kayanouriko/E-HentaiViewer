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
@property (nonatomic, strong) YYAnimatedImageView *loadingImageView;
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
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)startAnimateWithTip:(NSString *)tip {
    if (tip && tip.length) {
        self.tiplabel.text = tip;
    }
    else {
        self.tiplabel.text = @"正在载入";
    }
    self.loadingImageView.hidden = NO;
}

- (void)stopAnimateWithTip:(NSString *)tip {
    if (tip && tip.length) {
        self.tiplabel.text = tip;
    }
    else {
        self.tiplabel.text = @"载入出错";
    }
    self.loadingImageView.hidden = YES;
}

#pragma mark -getter
- (UIView *)bgView {
    if (nil == _bgView) {
        _bgView = [UIView new];
        _bgView.backgroundColor = [UIColor clearColor];
        [_bgView addSubview:self.loadingImageView];
        [_bgView addSubview:self.tiplabel];
        [self.loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.loadingImageView.mas_width).multipliedBy(97.f / 71.f);
            make.width.equalTo(@90);
            make.top.equalTo(self -> _bgView);
            make.centerX.equalTo(self -> _bgView);
        }];
        
        [self.tiplabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loadingImageView.mas_bottom).offset(5);
            make.left.right.bottom.equalTo(self -> _bgView);
        }];
    }
    return _bgView;
}

- (UILabel *)tiplabel {
    if (nil == _tiplabel) {
        _tiplabel = [UILabel new];
        _tiplabel.textColor = [UIColor lightGrayColor];
        _tiplabel.font = [UIFont systemFontOfSize:12.f];
        _tiplabel.text = @"正在载入";
    }
    return _tiplabel;
}

- (YYAnimatedImageView *)loadingImageView {
    if (!_loadingImageView) {
        _loadingImageView = [[YYAnimatedImageView alloc] initWithImage:[YYImage imageNamed:@"loading.gif"]];
    }
    return _loadingImageView;
}

@end
