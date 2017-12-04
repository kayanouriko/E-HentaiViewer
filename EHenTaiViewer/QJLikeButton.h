//
//  QJLikeButton.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/1.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QJLikeButtonState) {
    QJLikeButtonStateUnLike,
    QJLikeButtonStateLike,
    QJLikeButtonStateLoading,
};

@interface QJLikeButton : UIButton

@property (nonatomic, assign) QJLikeButtonState likeState;

@end
