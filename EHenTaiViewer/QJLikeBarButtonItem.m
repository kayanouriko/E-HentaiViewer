//
//  QJLikeBarButtonItem.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJLikeBarButtonItem.h"

@interface QJLikeBarButtonItem ()

@property (nonatomic, strong) UIView *cusView;
@property (nonatomic, strong) UIImageView *likeImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activity;

@end

@implementation QJLikeBarButtonItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.customView = self.cusView;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
        [self.cusView addGestureRecognizer:tap];
        self.state = QJLikeBarButtonItemStateLoading;
    }
    return self;
}

- (void)click {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickItem)]) {
        [self.delegate didClickItem];
    }
}

#pragma mark -setter
//根据状态修改显示的东西
- (void)setState:(QJLikeBarButtonItemState)state {
    _state = state;
    switch (state) {
        case QJLikeBarButtonItemStateLike:
        {
            self.likeImageView.hidden = NO;
            self.likeImageView.image = [[UIImage imageNamed:@"like"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.activity stopAnimating];
        }
            break;
        case QJLikeBarButtonItemStateUnlike:
        {
            self.likeImageView.hidden = NO;
            self.likeImageView.image = [[UIImage imageNamed:@"unlike"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.activity stopAnimating];
        }
            break;
        case QJLikeBarButtonItemStateLoading:
        {
            self.likeImageView.hidden = YES;
            [self.activity startAnimating];
        }
            break;
        default:
            break;
    }
}

#pragma mark -getter
- (UIView *)cusView {
    if (!_cusView) {
        _cusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_cusView addSubview:self.likeImageView];
        [_cusView addSubview:self.activity];
    }
    return _cusView;
}

- (UIImageView *)likeImageView {
    if (!_likeImageView) {
        _likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _likeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _likeImageView.image = [[UIImage imageNamed:@"unlike"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _likeImageView;
}

- (UIActivityIndicatorView *)activity {
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _activity.hidesWhenStopped = YES;
        [_activity stopAnimating];
    }
    return _activity;
}

@end
