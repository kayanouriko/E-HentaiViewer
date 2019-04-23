//
//  UIView+Layer.h
//  EHenTaiViewer
//
//  Created by QinJ on 2018/8/26.
//  Copyright © 2018 kayanouriko. All rights reserved.
//

/// 添加圆角样式

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface UIView (Layer)

/// 圆角
@property (assign, nonatomic) IBInspectable CGFloat cornerRadius;

@end
