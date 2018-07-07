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

@interface UIView (SomoSkeleton)

@property (strong, nonatomic, readonly) UIView * somoContainer;

/**
 *	When this method is called, the view will have a Skeleton effect,
 *	and the view's subview will be completely obscured.
 */
- (void)beginSomo;

/**
 *	When this method is called and the view is restored to the state you set,
 *	the Skeleton effect disappears.
 */
- (void)endSomo;

@end
