//
//  QJBigImageItem.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/3.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessHandler)(NSString *url);

@interface QJBigImageItem : NSObject

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSString *realImageUrl;
@property (nonatomic, strong) NSString *x;
@property (nonatomic, strong) NSString *y;

- (void)getReallyImageUrl:(SuccessHandler)successHandler;

@end
