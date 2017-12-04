//
//  QJViewController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/18.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QJViewController : UIViewController

//是否为刷新状态
- (BOOL)isShowFreshingStatus;
//显示菊花
- (void)showFreshingViewWithTip:(NSString *)tip;
//关闭菊花
- (void)hiddenFreshingView;
//显示错误
- (void)showErrorViewWithTip:(NSString *)tip;

@end
