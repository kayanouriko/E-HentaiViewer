//
//  QJColorPickProtocol.h
//  QJColorPicker
//
//  Created by QinJ on 2019/4/28.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJColorPickBoard, QJColorPickSlider;

@protocol QJColorPickBoardDelegate <NSObject>

@optional
- (void)colorPickBoard:(QJColorPickBoard *)colorPickBoard didChangeColor:(UIColor *)color;

@end

@protocol QJColorPickSliderDelegate <NSObject>

@optional
- (void)colorPickSlider:(QJColorPickSlider *)colorPickSlider didChangeColor:(UIColor *)color;

@end
