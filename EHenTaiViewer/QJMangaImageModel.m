//
//  QJMangaImageModel.m
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/12.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "QJMangaImageModel.h"
#import "NSString+StringHeight.h"

@interface QJMangaImageModel()

@property (nonatomic, strong) smallImageUrlBlock block;

@end

@implementation QJMangaImageModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.page = 0;
        self.url = @"";
        self.parser = self.hasImage;
        self.failed = NO;
        self.imagePath = @"";
    }
    return self;
}

- (BOOL)hasImage {
    return self.imagePath != nil && self.imagePath.length;
}

#pragma mark - Setter
- (void)setFailed:(BOOL)failed {
    _failed = failed;
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageDidDownloadFailWithModel:)]) {
        [self.delegate imageDidDownloadFailWithModel:self];
    }
}

- (void)setImagePath:(NSString *)imagePath {
    _imagePath = imagePath;
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageDidDownloadFinshWithModel:)]) {
        [self.delegate imageDidDownloadFinshWithModel:self];
    }
}

- (void)setRate:(CGFloat)rate {
    _rate = rate;
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageDidChangeRateWithModel:)]) {
        [self.delegate imageDidChangeRateWithModel:self];
    }
}

- (void)setPage:(NSInteger)page {
    _page = page;
}

- (void)setUrl:(NSString *)url {
    _url = url;
    if (_url.length) {
        self.parser = YES;
    }
    if (self.imagePath.length == 0) {
        self.imagePath = [self checkLocalImagePath];
    }
}

// 查找本地是否存在缓存,存在则直接取出来
- (NSString *)checkLocalImagePath {
    // 缓存文件夹
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *imagePath = [cachePath stringByAppendingPathComponent:[_url MD5]];
    // 先判断文件夹是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:imagePath isDirectory:&isDir];
    // 文件夹不存在的时候返回空字符串
    if (!existed) {
        return @"";
    }
    return imagePath;
}

- (void)setSmallImageUrl:(NSString *)smallImageUrl {
    _smallImageUrl = smallImageUrl;
    if (self.block) {
        self.block();
    }
}

#pragma mark - Model Action
- (void)getSmallUrlWithBlock:(smallImageUrlBlock)block {
    if (self.smallImageUrl && self.smallImageUrl.length) {
        block();
    } else {
        self.block = block;
    }
}

#pragma mark - Getter
- (CGSize)size {
    if (_imagePath.length) {
        UIImage *image = [UIImage imageWithContentsOfFile:_imagePath];
        CGSize imageSize = image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        
        CGFloat screenRatio = UIScreenWidth() / UIScreenHeight();
        CGFloat imageRatio = imageFrame.size.width / imageFrame.size.height;
        // TODO:这里有待整理,暂时用0.3的变量吧
        if (screenRatio - imageRatio <= 0.3 && screenRatio - imageRatio > 0) {
            CGFloat ratio = UIScreenHeight() / imageFrame.size.height;
            imageFrame.size.width = imageFrame.size.width * ratio;
            imageFrame.size.height = UIScreenHeight();
        } else {
            CGFloat ratio = UIScreenWidth() / imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height * ratio;
            imageFrame.size.width = UIScreenWidth();
        }
        
        
        return imageFrame.size;
    }
    else {
        return CGSizeMake(UIScreenWidth(), UIScreenHeight());
    }
}

@end
