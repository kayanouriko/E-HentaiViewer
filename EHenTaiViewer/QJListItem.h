//
//  QJListItem.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QJListItem : NSObject

@property (nonatomic, strong) NSString *url;//链接
@property (nonatomic, strong) NSString *thumb;//封面
@property (nonatomic, strong) NSString *title;//标题
@property (nonatomic, strong) NSString *title_jpn;//日语标题
@property (nonatomic, strong) NSString *similarKey;//类似画廊关键字
@property (nonatomic, strong) NSString *category;//分类
@property (nonatomic, strong) UIColor *categoryColor;//分类颜色
@property (nonatomic, strong) NSString *language;//语言
@property (nonatomic, strong) NSString *uploader;//上传人
@property (nonatomic, assign) NSInteger filecount;//文件数
@property (nonatomic, strong) NSString *filesize;//文件大小
@property (nonatomic, assign) CGFloat rating;//评分
@property (nonatomic, strong) NSString *posted;//上传时间
@property (nonatomic, assign) BOOL expunged;//是否被删除????
@property (nonatomic, assign) NSInteger torrentcount;//种子数
@property (nonatomic, strong) NSArray *tags;//tag数组
@property (nonatomic, assign) NSInteger page;//所在的页码
//下面两个为接口请求所需的参数
@property (nonatomic, strong) NSString *gid;
@property (nonatomic, strong) NSString *token;

- (instancetype)initWithDict:(NSDictionary *)dict classifyArr:(NSArray<NSString *> *)classifyArr colorArr:(NSArray<UIColor *> *)colorArr;

@end
