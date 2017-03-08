//
//  QJFavoritesChooseController.h
//  ExReadViewer
//
//  Created by QinJ on 2017/3/7.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QJFavoritesChooseControllerDelagate <NSObject>

- (void)didSelectFavoritesWithIndex:(NSInteger)index;

@end

@interface QJFavoritesChooseController : UIViewController

@property (weak, nonatomic) id<QJFavoritesChooseControllerDelagate>delegate;

@end
