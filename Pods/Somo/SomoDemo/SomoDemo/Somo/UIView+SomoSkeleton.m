/**
 * Copyright (c) 2016-present, K.
 * All rights reserved.
 *
 * e-mail:xorshine@icloud.com
 * github:https://github.com/xorshine
 *
 * This source code is licensed under the MIT license.
 */
#import <objc/runtime.h>
#import "UIView+SomoSkeleton.h"
#import "SomoSkeletonLayoutProtocol.h"
#import "SomoView.h"
#import "SomoDefines.h"
  
static void * kSomoContainerKey = &kSomoContainerKey;
 
@implementation UIView (SomoSkeleton)

- (void)setSomoContainer:(UIView *)somoContainer{
	somoContainer.frame = self.bounds;
	
	UIColor * color = SomoColorFromRGBV(248.);
	
	if ([self respondsToSelector:@selector(somoSkeletonBackgroundColor)]) {
		
		color = [(UIView<SomoSkeletonLayoutProtocol> *)self somoSkeletonBackgroundColor];
	}
	
	somoContainer.backgroundColor = color;
	
	[self addSubview:somoContainer];
	
	objc_setAssociatedObject(self, kSomoContainerKey, somoContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)somoContainer{
	return objc_getAssociatedObject(self, kSomoContainerKey);
}

- (void)beginSomo{
	if ([self conformsToProtocol:@protocol(SomoSkeletonLayoutProtocol)] == NO) {
		return;
	}
	
	if ([self respondsToSelector:@selector(somoSkeletonLayout)] == NO) {
		return;
	}
	
	self.userInteractionEnabled = NO;
	
	[self buildContainer];
	
	[self bringSubviewToFront:self.somoContainer];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
	NSArray<SomoView *> * somoViews = [(UIView<SomoSkeletonLayoutProtocol> *)self somoSkeletonLayout];
	
	[self buildSkeletonSubViews:somoViews];
}

- (void)buildContainer{
	[self clear];
	self.somoContainer = [UIView new];
}

- (void)buildSkeletonSubViews:(NSArray<SomoView *> *)views{
	for (SomoView * view in views) {
		[self.somoContainer addSubview:view];
	}
}

- (void)endSomo{
	if (!self.somoContainer) {
		return;
	}
	self.userInteractionEnabled = YES;
	[self clear];
}

- (void)clear{
	[self.somoContainer removeFromSuperview];
	self.somoContainer = nil;
}

@end
