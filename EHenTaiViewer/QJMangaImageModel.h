//
//  QJMangaImageModel.h
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/12.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QJMangaImageModel;

typedef void(^smallImageUrlBlock)();

@protocol QJMangaImageModelDelegate <NSObject>

@optional
- (void)imageDidDownloadFinshWithModel:(QJMangaImageModel *)model;
- (void)imageDidDownloadFailWithModel:(QJMangaImageModel *)model;
- (void)imageDidChangeRateWithModel:(QJMangaImageModel *)model;

@end

@interface QJMangaImageModel : NSObject

@property (nonatomic, weak) id<QJMangaImageModelDelegate> delegate;
// 页码
@property (nonatomic, assign) NSInteger page;
// 大图url
@property (nonatomic, strong) NSString *imageUrl;
// 小图url
@property (nonatomic, strong) NSString *smallImageUrl;
// url
@property (nonatomic, strong) NSString *url;
// 已经下载的data，用于恢复下载用
@property (nonatomic, strong) NSData *currentData;
// 进度
@property (nonatomic, assign) CGFloat rate;
// image本地存储路径
@property (nonatomic, strong) NSString *imagePath;
// image缩放度为1的size
@property (nonatomic, assign) CGSize size;
// 是否有图片url
@property (nonatomic, assign, readonly) BOOL hasImage;
// 是否已经解析出图片url
@property (nonatomic, assign, getter=isParser) BOOL parser;
// 是否失败
@property (nonatomic, assign, getter=isFailed) BOOL failed;
// 获取smallurl
- (void)getSmallUrlWithBlock:(smallImageUrlBlock)block;


@end
