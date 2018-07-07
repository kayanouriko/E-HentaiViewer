//
//  QJLabel.h
//  EHenTaiViewer
//
//  Created by zedmacbook on 2018/6/28.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface QJLabel : UILabel

/** 设置内边距自适应高度 */
@property (nonatomic, assign, getter=isCusRadiusInsets) IBInspectable BOOL cusRadiusInsets;


@end
