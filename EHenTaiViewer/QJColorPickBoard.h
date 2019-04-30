//
//  QJColorPickBoard.h
//  QJColorPicker
//
//  Created by QinJ on 2019/4/28.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QJColorPickProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface QJColorPickBoard : UIView

@property (weak, nonatomic) id<QJColorPickBoardDelegate>delegate;
@property (strong, nonatomic) UIColor *currentColor;

@end

NS_ASSUME_NONNULL_END
