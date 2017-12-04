//
//  QJButton.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/11/9.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface QJButton : UIButton

//本身具备一个存储值
@property (nonatomic, strong) IBInspectable NSString *value;

@end
