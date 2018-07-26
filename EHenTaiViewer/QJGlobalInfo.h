//
//  QJGlobalInfo.h
//  wikiForMHXX
//
//  Created by QinJ on 2017/4/18.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

/**
 这个类主要管理一个全局字典，用于存储一些临时变量
 还有管理应用的持久化配置数据
 */

#import <Foundation/Foundation.h>

@interface QJGlobalInfo : NSObject

/** 一个全局字典 */
+ (instancetype)sharedInstance;
- (void)putAttribute:(NSString*)key value:(id)value;
- (id)getAttribute:(NSString*)key;

// 一些配置文件的存储和读取
+ (NSArray<NSString *> *)customTabbarItems;
+ (void)setCustomTabbarItems:(NSArray<NSString *> *)customTabbarItems;

/** 设置全局的旋转方向 */
+ (UIInterfaceOrientationMask)customOrientation;
+ (void)setCustomOrientation:(UIInterfaceOrientationMask)customOrientation;

/** 设置全局的滚动方式 */
+ (UICollectionViewScrollDirection)customScrollDiretion;
+ (void)setCustomScrollDiretion:(UICollectionViewScrollDirection)customScrollDiretion;

/** 设置全局的站点浏览 */
+ (BOOL)isExHentaiStatus;
+ (void)setExHentaiStatus:(BOOL)isExHentaiStatus;

/** 设置全局的大图浏览 */
+ (BOOL)isExHentaiWatchMode;
+ (void)setExHentaiWatchMode:(BOOL)isExHentaiWatchMode;

/** 设置全局的指纹面容验证 */
+ (BOOL)isExHentaiProtectMode;
+ (void)setExHentaiProtectMode:(BOOL)isExHentaiProtectMode;

/** 设置全局汉化标签 */
+ (BOOL)isExHentaiTagCnMode;
+ (void)setExHentaiTagCnMode:(BOOL)isExHentaiTagCnMode;

/** 设置日文标题 */
+ (BOOL)isExHentaiTitleJnMode;
+ (void)setExHentaiTitleJnMode:(BOOL)isExHentaiTitleJnMode;

@end
