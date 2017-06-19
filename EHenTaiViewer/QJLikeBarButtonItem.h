//
//  QJLikeBarButtonItem.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QJLikeBarButtonItemState) {
    QJLikeBarButtonItemStateUnlike,//未收藏
    QJLikeBarButtonItemStateLike,//收藏
    QJLikeBarButtonItemStateLoading//加载状态
};

@protocol QJLikeBarButtonItemDelagate <NSObject>

- (void)didClickItem;

@end

@interface QJLikeBarButtonItem : UIBarButtonItem

@property (nonatomic, assign) QJLikeBarButtonItemState state;
@property (weak, nonatomic) id<QJLikeBarButtonItemDelagate>delegate;

@end
