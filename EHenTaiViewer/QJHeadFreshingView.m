//
//  QJHeadFreshingView.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/12.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJHeadFreshingView.h"
#import <AudioToolbox/AudioToolbox.h>

typedef NS_ENUM(NSInteger, QJHeadFreshingViewState) {
    QJHeadFreshingViewStateNormal,//未下拉状态,未刷新
    QJHeadFreshingViewStatePull,//下拉状态,未刷新
    QJHeadFreshingViewStateRefreshing//正在刷新状态
};

@interface QJHeadFreshingView ()

@property (nonatomic, strong) UIScrollView *superScrollView;
@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, assign) QJHeadFreshingViewState currState;

@end

@implementation QJHeadFreshingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        CGRect frame = CGRectMake(0, -kRefreshingViewHeight, UIScreenWidth(), kRefreshingViewHeight);
        [self commonInitWithFrame:frame];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitWithFrame:frame];
    }
    return self;
}

- (void)commonInitWithFrame:(CGRect)frame {
    self.frame = frame;
    [self addSubview:self.activity];
    self.currState = QJHeadFreshingViewStateNormal;
}

#pragma mark -监听父控件的滚动
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.superScrollView = (UIScrollView *)newSuperview;
        [self.superScrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (self.superScrollView.isDragging) {
        //根据下拉的距离判断这时候控件是否超过范围而需要刷新
        CGFloat normolPulingOffset = -kRefreshingViewHeight - UINavigationBarHeight();
        if (self.currState == QJHeadFreshingViewStatePull && self.superScrollView.contentOffset.y > normolPulingOffset) {
            //下拉未超过一定范围
            self.currState = QJHeadFreshingViewStateNormal;
        }else if (self.currState == QJHeadFreshingViewStateNormal && self.superScrollView.contentOffset.y <= normolPulingOffset){
            //下拉超过范围
            self.currState = QJHeadFreshingViewStatePull;
        }
    }else{
        //手松开puling->refreshing
        if (self.currState == QJHeadFreshingViewStatePull) {
            //            NSLog(@"切换到Refreshing");
            AudioServicesPlaySystemSound(1520);

            self.currState = QJHeadFreshingViewStateRefreshing;
        }
        
    }
}

- (void)beginReFreshing {
    self.refreshing = YES;
    if (self.currState != QJHeadFreshingViewStateRefreshing) {
        self.currState = QJHeadFreshingViewStateRefreshing;
    }
}

- (void)endRefreshing {
    if (self.currState == QJHeadFreshingViewStateRefreshing) {
        self.currState = QJHeadFreshingViewStateNormal;
        //tableView要回去
        [UIView animateWithDuration:0.25 animations:^{
            self.superScrollView.contentInset = UIEdgeInsetsMake(self.superScrollView.contentInset.top - kRefreshingViewHeight, self.superScrollView.contentInset.left, self.superScrollView.contentInset.bottom, self.superScrollView.contentInset.right);
        } completion:^(BOOL finished) {
            [self.activity stopAnimating];
        }];
    }
}

#pragma mark -setter
- (void)setCurrState:(QJHeadFreshingViewState)currState {
    _currState = currState;
    switch (currState) {
        case QJHeadFreshingViewStateNormal:
        {
            //不作为
            self.refreshing = NO;
        }
            break;
        case QJHeadFreshingViewStateRefreshing:
        {
            self.refreshing = YES;
            //开始转动
            [self.activity startAnimating];
            //将scrollView下拉一定距离
            [UIView animateWithDuration:0.25 animations:^{
                self.superScrollView.contentInset = UIEdgeInsetsMake(self.superScrollView.contentInset.top + kRefreshingViewHeight, self.superScrollView.contentInset.left, self.superScrollView.contentInset.bottom, self.superScrollView.contentInset.right);
            }];
            //代理
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didBeginReFreshingWithFreshingView:)]) {
                [self.delegate didBeginReFreshingWithFreshingView:self];
            }
        }
            break;
        case QJHeadFreshingViewStatePull:
        {
            //不作为
            self.refreshing = NO;
        }
            break;
        default:
            break;
    }
}

#pragma mark -getter
- (UIActivityIndicatorView *)activity {
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.frame = CGRectMake(self.frame.size.width / 2 - 10, 10, 20, 20);
        _activity.hidesWhenStopped = NO;
        //_activity.center = self.center;
    }
    return _activity;
}

#pragma mark -dealloc
- (void)dealloc {
    [self.superScrollView removeObserver:self forKeyPath:@"contentOffset" context:nil];
}

@end
