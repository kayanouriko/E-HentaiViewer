//
//  QJBrowserBookMarkPopView.h
//  AnimatedTransitioningDemo
//
//  Created by zedmacbook on 2018/7/24.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJMangaManager;

@protocol QJBrowserBookMarkPopViewDelegate <NSObject>

@optional
- (void)didSelectImageWithIndex:(NSInteger)index;

@end

@interface QJBrowserBookMarkPopView : UIView

@property (nonatomic, weak) id<QJBrowserBookMarkPopViewDelegate> delegate;
@property (nonatomic, assign, getter=isShowed) BOOL showed;

+ (QJBrowserBookMarkPopView *)creatPopViewWithDelegate:(id<QJBrowserBookMarkPopViewDelegate>)theDelagate manager:(QJMangaManager *)manager gid:(NSString *)gid;

- (void)showWithIndexPath:(NSIndexPath *)indexPath;
- (void)changeFrameIfNeedWithIndexPath:(NSIndexPath *)indexPath;

@end
