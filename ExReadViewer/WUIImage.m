//
//  UIImage-Handling.m
//  WinAdDemo
//
//  Created by frank on 11-5-13.
//  Copyright 2011 wongf70@gmail.com All rights reserved.
//

#import "WUIImage.h"


@implementation WUIImage

+(NSMutableArray*)SeparateImage:(UIImage*)image andX:(int)x andY:(int)y {
	if (x<1) {
		NSLog(@"illegal x!");
		return nil;
	}else if (y<1) {
		NSLog(@"illegal y!");
		return nil;
	}
	if (![image isKindOfClass:[UIImage class]]) {
		NSLog(@"illegal image format!");
		return nil;
	}
	float _xstep=image.size.width*1.0/(y+1);
	float _ystep=image.size.height*1.0/(x+1);
    NSMutableArray *imageArr = [NSMutableArray new];
	
	for (int i=0; i<x; i++) 
	{
		for (int j=0; j<y; j++) 
		{
			CGRect rect=CGRectMake(_xstep*j, _ystep*i, _xstep, _ystep);
			CGImageRef imageRef=CGImageCreateWithImageInRect([image CGImage],rect);
			UIImage* elementImage=[UIImage imageWithCGImage:imageRef];
            [imageArr addObject:elementImage];
		}
	}
	return imageArr;
}

+ (UIImage *)SeparateImage:(UIImage*)image withRect:(CGRect)rect {
    CGImageRef imageRef=CGImageCreateWithImageInRect([image CGImage],rect);
    UIImage* elementImage=[UIImage imageWithCGImage:imageRef];
    return elementImage;
}

@end
