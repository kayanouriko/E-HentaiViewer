//
//  QJPasswordViewController.h
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/10.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PasswordBlock)(BOOL isSuccess);

@interface QJPasswordViewController : UIViewController

@property (nonatomic, strong) PasswordBlock block;

@end
