//
//  QJHeadFreshingView.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/12.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJHeadFreshingView;

@protocol QJHeadFreshingViewDelagate <NSObject>

- (void)didBeginReFreshingWithFreshingView:(QJHeadFreshingView *)headFreshingView;

@end

@interface QJHeadFreshingView : UIView

@property (weak, nonatomic) id<QJHeadFreshingViewDelagate>delegate;

@property (nonatomic, assign, getter=isReFreshing) BOOL refreshing;

- (void)beginReFreshing;
- (void)endRefreshing;

@end
