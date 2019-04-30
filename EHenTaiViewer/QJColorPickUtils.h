//
//  QJColorPickUtils.h
//  QJColorPicker
//
//  Created by QinJ on 2019/4/28.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJColorPickUtils : NSObject

// UIColor --> Hex
+ (NSString *)hexStringWithColor:(UIColor *)color hasAlpha:(BOOL)hasAlpha;
// change alpha
+ (UIColor *)changeColorAlpha:(UIColor *)color alpha:(CGFloat)alpha;
// Point --> UIColor
+ (UIColor *)getColorWithPoint:(CGPoint)point layer:(CALayer *)layer;

@end

NS_ASSUME_NONNULL_END
