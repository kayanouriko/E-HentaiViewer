//
//  UITextView+Addition.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/11/26.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "UITextView+Addition.h"
#import "NSString+StringHeight.h"

@implementation UITextView (Addition)

- (BOOL)checkContentLength {
    CGFloat contentHeight = [self.text StringHeightWithFontSize:self.font maxWidth:self.contentSize.width];
    return contentHeight > self.contentSize.height;
}

@end
