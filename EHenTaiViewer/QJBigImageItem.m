//
//  QJBigImageItem.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/3.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJBigImageItem.h"

@interface QJBigImageItem ()

@property (nonatomic, strong) SuccessHandler block;

@end

@implementation QJBigImageItem

- (void)getReallyImageUrl:(SuccessHandler)successHandler {
    if (self.realImageUrl) {
        successHandler(self.realImageUrl);
    }
    self.block = successHandler;
}

#pragma mark -setter
- (void)setRealImageUrl:(NSString *)realImageUrl {
    _realImageUrl = realImageUrl;
    if (self.block) {
        self.block(_realImageUrl);
    }
}

@end
