//
//  QJFavSelectViewController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/28.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

@protocol QJFavSelectViewControllerDelagate <NSObject>

@optional
- (void)didSelectFavFolder:(NSInteger)index;

@end

@interface QJFavSelectViewController : QJViewController

@property (weak, nonatomic) id<QJFavSelectViewControllerDelagate>delegate;

@end
