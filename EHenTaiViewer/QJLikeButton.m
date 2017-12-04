//
//  QJLikeButton.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/1.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJLikeButton.h"

@interface QJLikeButton ()

@property (nonatomic, strong) UIImageView *likeImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activity;

@end

@implementation QJLikeButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.likeState = QJLikeButtonStateUnLike;
}

- (void)customView {
    self.backgroundColor = [UIColor clearColor];
    [self setTitle:@"" forState:UIControlStateNormal];
    [self addSubview:self.likeImageView];
    [self addSubview:self.activity];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_likeImageView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_likeImageView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_likeImageView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_likeImageView)]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

#pragma mark -setter
- (void)setLikeState:(QJLikeButtonState)likeState {
    _likeState = likeState;
    switch (likeState) {
        case QJLikeButtonStateLike:
        {
            self.likeImageView.hidden = NO;
            self.likeImageView.image = [[UIImage imageNamed:@"like"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.activity stopAnimating];
        }
            break;
        case QJLikeButtonStateUnLike:
        {
            self.likeImageView.hidden = NO;
            self.likeImageView.image = [[UIImage imageNamed:@"unlike"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.activity stopAnimating];
        }
            break;
        case QJLikeButtonStateLoading:
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
- (UIImageView *)likeImageView {
    if (!_likeImageView) {
        _likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _likeImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _likeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _likeImageView.image = [[UIImage imageNamed:@"unlike"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _likeImageView;
}

- (UIActivityIndicatorView *)activity {
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _activity;
}

@end
