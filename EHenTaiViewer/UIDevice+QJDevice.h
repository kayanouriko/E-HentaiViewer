//
//  UIDevice+QJDevice.h
//  EHenTaiViewer
//
//  Created by zedmacbook on 2018/6/26.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

// https://www.jianshu.com/p/d6cb54d2eaa1

#import <UIKit/UIKit.h>

@interface UIDevice (QJDevice)

/**
 * @interfaceOrientation 输入要强制转屏的方向
 */
+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
