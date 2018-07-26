//
//  QJMangaImageParser.h
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/13.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QJMangaImageParser;

@protocol QJMangaImageParserDelegate <NSObject>

@optional
/**
 解析出来的图片url
 urls:链接数组
 beginIndex:图片起始下标
 */
- (void)imageUrlDidParserWithArray:(NSArray<NSString *> *)urls smallUrls:(NSArray<NSString *> *)smallUrls page:(NSInteger)page parser:(QJMangaImageParser *)parser;

@end

@interface QJMangaImageParser : NSOperation

// 这里需要主要，operation的代理在main函数里面就被释放了，所以要强引用，这里还没有理解原理，待处理
// 临时处理，将dalegate设置为强引用，在线程完成时，在外部把delegate置nil
@property (nonatomic, strong) id<QJMangaImageParserDelegate> delegate;

- (instancetype)initWithGalleryUrl:(NSString *)url pageCount:(NSInteger)count theDelegate:(id<QJMangaImageParserDelegate>)delegate;

@end
