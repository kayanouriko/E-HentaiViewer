//
//  QJBrowerSettingViewController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2019/5/11.
//  Copyright © 2019 kayanouriko. All rights reserved.
//
//  懒得写自定义专场动画了,这里用了比较傻逼的方法模拟一个弹窗设置控制器

#import "QJViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class QJBrowerSettingViewController;

@protocol QJBrowerSettingViewControllerDelegate <NSObject>

/** 返回当前屏幕方向设置
 @return 0.竖屏 1.横屏 2.跟随系统
 */
- (NSInteger)currentOrientationSegSelectedIndexWithController:(QJBrowerSettingViewController *)controller;

/** 返回当前滚动方向设置
 @return 0.水平滚动 1.上下滚动
 */
- (NSInteger)currentDirectionSegSelectedIndexWithController:(QJBrowerSettingViewController *)controller;

/** 返回当前系统亮度
 @return brightness 系统亮度
 */
- (CGFloat)currentBrightnessWithController:(QJBrowerSettingViewController *)controller;

/** 返回当前是否需要屏幕常亮 */
- (BOOL)currentKeepLightWithController:(QJBrowerSettingViewController *)controller;

@optional
/** 旋转方式响应事件
 @param selectedIndex 选中的Seg下标
 */
- (void)controller:(QJBrowerSettingViewController *)controller orientationSegDidClickBtnWithSelectedIndex:(NSInteger)selectedIndex;

/** 滚动方向响应事件
 @param selectedIndex 选中的Seg下标
 */
- (void)controller:(QJBrowerSettingViewController *)controller directionSegDidClickBtnWithSelectedIndex:(NSInteger)selectedIndex;

/** 亮度调节响应事件
 @param value 改变的亮度值
 */
- (void)controller:(QJBrowerSettingViewController *)controller brightnessSliderDidChangeValue:(CGFloat)value;

/** 保持屏幕高亮响应事件 */
- (void)controller:(QJBrowerSettingViewController *)controller keepLight:(BOOL)keepLight;

/** 已经点击完成操作 */
- (void)dismissController:(QJBrowerSettingViewController *)controller;

@end

@interface QJBrowerSettingViewController : QJViewController

@property (weak, nonatomic) id<QJBrowerSettingViewControllerDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
