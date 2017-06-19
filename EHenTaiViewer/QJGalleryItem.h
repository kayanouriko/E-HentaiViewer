//
//  QJGalleryItem.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"

@interface QJGalleryTagItem : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) CGFloat buttonWidth;
@property (nonatomic, assign) CGFloat buttonX;
@property (nonatomic, assign) CGFloat buttonY;

@end

@interface QJGalleryItem : NSObject

@property (nonatomic, strong) NSDictionary *baseInfoDic;//基础信息
@property (nonatomic, strong) NSArray *smallImages;//缩略图合集
@property (nonatomic, strong) NSArray *comments;//评论
@property (nonatomic, strong) NSArray *tagArr;//tag
@property (nonatomic, assign) BOOL isFavorite;//是否收藏
@property (nonatomic, strong) NSString *testUrl;//获取showkey的链接
@property (nonatomic, strong) NSString *showkey;//24小时变换的token
@property (nonatomic, strong) NSString *apiuid;
@property (nonatomic, strong) NSString *apikey;

- (instancetype)initWithHpple:(TFHpple *)xpathParser;

@end
