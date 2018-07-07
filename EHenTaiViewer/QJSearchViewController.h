//
//  QJSearchViewController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

@class QJGalleryTagItem;

@interface QJSearchViewController : QJViewController

@property (nonatomic, strong) QJGalleryTagItem *model;

- (void)scrollToTop;

@end
