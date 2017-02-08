//
//  UIImage-Handling.h
//  WinAdDemo
//
//  Created by frank on 11-5-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface WUIImage:UIView

+(NSMutableArray*)SeparateImage:(UIImage*)image andX:(int)x andY:(int)y;
+ (UIImage *)SeparateImage:(UIImage*)image withRect:(CGRect)rect;

@end
