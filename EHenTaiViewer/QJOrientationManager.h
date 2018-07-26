//
//  QJOrientationManager.h
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/26.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

/**
 该类主要控制一些杂项设置
 */

#import <UIKit/UIKit.h>

@interface QJOrientationManager : NSObject

/** 通过配置文件改变目前的屏幕方向 */
+ (void)changeOrientationFromSetting;

/** 通过配置文件获取屏幕方向并转换为seg对应的index
 @return seg对应的index, 0. 竖屏 1. 横屏 2. 跟随系统
 */
+ (NSInteger)getOrientationSegSelected;

/** 恢复竖屏方向 */
+ (void)recoverPortraitOrienttation;

/** 根据seg的selectedIndex修改配置文件并修改屏幕方向
 @param selectedIndex seg的选中index
 */
+ (void)setOrientationWithSelected:(NSInteger)selectedIndex;

/** 通过配置文件获取滚动方向并转换为seg对应的index
 @return seg对应的index, 0. 水平滚动 1. 上下滚动
 */
+ (NSInteger)getDiretionSegSelected;

/** 根据seg的selectedIndex修改配置文件并修改滚动方向
 @param selectedIndex seg的选中index
 */
+ (void)setDiretionWithSelected:(NSInteger)selectedIndex;

/** 保存目标图片到系统相册
 @param imagePath 沙盒图片路径
 */
+ (void)saveImageToSystemThumbWithImagePath:(NSString *)imagePath;

@end
