//
//  QJFavouriteViewController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/16.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

@protocol QJFavouriteViewControllerDelagate <NSObject>

@optional
- (void)didSelectFolder:(NSInteger)index content:(NSString *)content;

@end

@interface QJFavouriteViewController : QJViewController

@property (weak, nonatomic) id<QJFavouriteViewControllerDelagate>delegate;

@end
