//
//  QJColorPickSlider.h
//  QJColorPicker
//
//  Created by QinJ on 2019/4/28.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QJColorPickProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface QJColorPickSlider : UIView

@property (weak, nonatomic) id<QJColorPickSliderDelegate>delegate;
@property (strong, nonatomic) UIColor *showColor; // 从board获取的颜色
@property (strong, nonatomic) UIColor *currentColor; // 修改后的颜色

@end

NS_ASSUME_NONNULL_END
