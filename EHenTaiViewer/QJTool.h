//
//  QJTool.h
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/17.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

// 存放一些工具方法

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJTool : NSObject

// 是否为异形屏
+ (BOOL)isiPhoneXAfter;

// 颜色获取
+ (UIColor *)colorWithHexString:(NSString *)color;

// 获取当前控制器
+ (UIViewController *)visibleViewController;
+ (UINavigationController *)visibleNavigationController;

@end

NS_ASSUME_NONNULL_END
