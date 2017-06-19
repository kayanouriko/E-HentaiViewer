//
//  QJHeadFreshingView.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/12.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QJHeadFreshingViewDelagate <NSObject>

- (void)beginRefreshing;

@end

@interface QJHeadFreshingView : UIView

@property (weak, nonatomic) id<QJHeadFreshingViewDelagate>delegate;

- (void)beginReFreshing;
- (void)endRefreshing;

@end
