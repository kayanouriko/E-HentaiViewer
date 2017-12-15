//
//  QJFavoritesSelectController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/12.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

@protocol QJFavoritesSelectControllerDelegate <NSObject>

@optional
- (void)didSelectFavFolderNameWithArr:(NSArray<NSString *> *)array index:(NSInteger)index;

@end

@interface QJFavoritesSelectController : QJViewController

@property (weak, nonatomic) id<QJFavoritesSelectControllerDelegate>delegate;
//判断是不是从收藏界面来的
//如果是收藏界面来的,则显示'全部收藏'这个选项,否则是隐藏该选项
@property (nonatomic, assign, getter=isLikeVCJump) BOOL likeVCJump;

@end
