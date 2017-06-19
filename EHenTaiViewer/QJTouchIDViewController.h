//
//  QJTouchIDViewController.h
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/9.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TouchidBlock)(BOOL isSuccess);

@interface QJTouchIDViewController : UIViewController

@property (nonatomic, strong) TouchidBlock block;

@end
