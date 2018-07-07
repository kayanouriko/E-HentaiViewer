/**
 * Copyright (c) 2016-present, K.
 * All rights reserved.
 *
 * e-mail:xorshine@icloud.com
 * github:https://github.com/xorshine
 *
 * This source code is licensed under the MIT license.
 */

#ifndef SomoSkeletonLayoutProtocol_h
#define SomoSkeletonLayoutProtocol_h

@class SomoView;
/**
 *	SomoSkeletonLayoutProtocol
 *
 *	When you need a view that has a Skeleton effect
 *  set the view to follow the protocol
**/
@protocol SomoSkeletonLayoutProtocol<NSObject>
#pragma mark -
@required
/**
 *  like this:
		 SomoView * s0 = [[SomoView alloc] initWithFrame:CGRectMake(10, 20, 70, 70)];
		 SomoView * s1 = [[SomoView alloc] initWithFrame:CGRectMake(100, 30, 200, 15)];
		 SomoView * s2 = [[SomoView alloc] initWithFrame:CGRectMake(100, 70, 100, 15)];
 
		return @[s0,s1,s2];
 *
 *
 @return array of SomoViews
 */
- (NSArray<SomoView *> *)somoSkeletonLayout;

@optional
#pragma mark - 
/**
 *	Set the view's background color when the Skeleton effect appears
 
 	 ————————————————————————
	 |	****	*********	|
	 |	****			  ——+——>backgroundColor
	 |	****	*********	|
	 ————————————————————————
 *
 @return UIColor *
 **/
- (UIColor *)somoSkeletonBackgroundColor;

@end

#endif /* SomoSkeletonLayoutProtocol_h */
