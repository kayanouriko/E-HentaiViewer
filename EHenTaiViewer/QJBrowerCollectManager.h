//
//  QJBrowerCollectManager.h
//  EHenTaiViewer
//
//  Created by QinJ on 2018/8/13.
//  Copyright © 2018 kayanouriko. All rights reserved.
//

// 管理书签相关

#import <Foundation/Foundation.h>

@class GalleryPage;

@interface QJBrowerCollectManager : NSObject

/** 获取全部书签
 @param gid 画廊的唯一标识符
 */
+ (NSArray<GalleryPage *> *)getAllCollectPagesWithGid:(NSString *)gid;

/** 添加一个书签
 @param gid 画廊的唯一标识符
 @param pageIndex 书签信息,页码
 @param smallImageUrl 书签信息,缩略图url
 */
+ (void)saveOnePageWithGid:(NSString *)gid pageIndex:(NSInteger)pageIndex smallImageUrl:(NSString *)smallImageUrl;

/** 删除一个书签
 @param gid 画廊的唯一标识符
 @param pageIndex 书签信息,页码
 @param smallImageUrl 书签信息,缩略图url
 */
+ (void)deleteOnePageWithGid:(NSString *)gid pageIndex:(NSInteger)pageIndex smallImageUrl:(NSString *)smallImageUrl;

@end
