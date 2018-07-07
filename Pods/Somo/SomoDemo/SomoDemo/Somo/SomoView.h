/**
 * Copyright (c) 2016-present, K.
 * All rights reserved.
 *
 * e-mail:xorshine@icloud.com
 * github:https://github.com/xorshine
 *
 * This source code is licensed under the MIT license.
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SomoAnimationStyle) { 
	SomoAnimationStyleSolid,
	SomoAnimationStyleGradientHorizontal,
	SomoAnimationStyleGradientVertical,
	SomoAnimationStyleOblique
};

/**
 *	The essence of the Skeleton effect is the view of the placeholders.
 *	For example, a Cell, when cells show the Skeleton effect,
 *	you want to display two dark rectangular bars on the cell,
 *	each rectangle is a SomoView
 */
@interface SomoView : UIView

@property (strong, nonatomic) UIColor *somoColor;
@property (assign, nonatomic) SomoAnimationStyle animationStyle;

/**
 * constructor
 *
 @return SomoView
 */
- (instancetype)initWithFrame:(CGRect)rect
					somoColor:(UIColor *)color;

/**
 * @style  default  SomoAnimationStyleSolid
 *
 @return SomoView
 */
- (instancetype)initWithFrame:(CGRect)rect
					somoColor:(UIColor *)color
			   animationStyle:(SomoAnimationStyle)style;

@end
