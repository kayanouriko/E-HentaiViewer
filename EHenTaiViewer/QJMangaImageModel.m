//
//  QJMangaImageModel.m
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/12.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "QJMangaImageModel.h"

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
    if (self.mangaName && self.imagePath.length == 0) {
        self.imagePath = [self checkLocalImagePath];
    }
}

// 查找本地是否存在缓存,存在则直接取出来
- (NSString *)checkLocalImagePath {
    NSString *fileFolderPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], [self.mangaName stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
    // 先判断文件夹是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL existed = [fileManager fileExistsAtPath:fileFolderPath isDirectory:&isDir];
    // 文件夹不存在的时候返回空字符串
    if (!existed) {
        return @"";
    }
    // 遍历文件夹内容
    // 如果存在
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:fileFolderPath error:nil];
    if (files && files.count) {
        for (NSString *fileName in files) {
            NSString *page = [fileName stringByDeletingPathExtension];
            if ([page isEqualToString:[NSString stringWithFormat:@"%ld", self.page]]) {
                return [NSString stringWithFormat:@"%@/%@", fileFolderPath, fileName];
            }
        }
    }
    return @"";
}

#pragma mark - Getter
- (CGSize)size {
    if (_imagePath.length) {
        UIImage *image = [UIImage imageWithContentsOfFile:_imagePath];
        CGSize imageSize = image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        CGFloat ratio = UIScreenWidth() / imageFrame.size.width;
        imageFrame.size.height = imageFrame.size.height * ratio;
        imageFrame.size.width = UIScreenWidth();
        return imageFrame.size;
    }
    else {
        return CGSizeMake(UIScreenWidth(), UIScreenHeight());
    }
}

@end
