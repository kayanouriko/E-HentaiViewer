//
//  QJBrowerSettingPopView.h
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/27.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QJBrowerSettingPopViewDelegate <NSObject>

/** 返回当前屏幕方向设置
 @return 0.竖屏 1.横屏 2.跟随系统
 */
- (NSInteger)currentOrientationSegSelectedIndex;

/** 返回当前滚动方向设置
 @return 0.水平滚动 1.上下滚动
 */
- (NSInteger)currentDirectionSegSelectedIndex;

/** 返回当前系统亮度
 @return brightness 系统亮度
 */
- (CGFloat)currentBrightness;

@optional
/** 旋转方式响应事件
 @param selectedIndex 选中的Seg下标
 */
- (void)orientationSegDidClickBtnWithSelectedIndex:(NSInteger)selectedIndex;

/** 滚动方向响应事件
 @param selectedIndex 选中的Seg下标
 */
- (void)directionSegDidClickBtnWithSelectedIndex:(NSInteger)selectedIndex;

/** 亮度调节响应事件
 @param value 改变的亮度值
 */
- (void)brightnessSliderDidChangeValue:(CGFloat)value;

@end

@interface QJBrowerSettingPopView : UIView

@property (nonatomic, weak) id<QJBrowerSettingPopViewDelegate> delegate;
@property (nonatomic, assign, getter=isShowed) BOOL showed;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (QJBrowerSettingPopView *)initWithDelegate:(id<QJBrowerSettingPopViewDelegate>)theDelegate;

/** 呈现弹出框 */
- (void)show;
/** 刷新布局,这里采用了比较笨的方法,直接重新布局 */
- (void)changeFrameIfNeed;

@end
