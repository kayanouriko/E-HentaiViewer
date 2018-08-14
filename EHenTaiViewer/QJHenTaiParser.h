//
//  QJHenTaiParser.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QJListItem, QJGalleryItem, QJBigImageItem, QJTorrentItem, QJToplistUploaderItem, QJSettingItem;

typedef NS_ENUM(NSInteger, QJHenTaiParserStatus) {
    QJHenTaiParserStatusNetworkFail,//网络失败
    QJHenTaiParserStatusParseFail,//解析失败
    QJHenTaiParserStatusSuccess,//解析成功
    QJHenTaiParserStatusParseNoMore//解析成功,但是没有数据
};

typedef void (^LoginHandler)(QJHenTaiParserStatus status);
typedef void (^TotalHandler)(NSInteger total);
typedef void (^ListHandler)(QJHenTaiParserStatus status ,NSArray<QJListItem *> *listArray);
typedef void (^GalleryHandler)(QJHenTaiParserStatus status,QJGalleryItem *item);
typedef void (^ShowkeyHandler)(QJHenTaiParserStatus status,NSString *showkey);
typedef void (^BigImageHandler)(QJHenTaiParserStatus status,NSString *url,NSString *x,NSString *y);
typedef void (^BigImageListHandler)(NSArray<QJBigImageItem *> *bigImages);
typedef void (^TorrentListHandler)(QJHenTaiParserStatus status ,NSArray<QJTorrentItem *> *torrents);
typedef void (^ToplistHandler)(QJHenTaiParserStatus status ,NSArray<QJListItem *> *listArray, NSArray<QJToplistUploaderItem *> *uploaderArrary);
typedef void (^SettingHandler)(QJHenTaiParserStatus status ,NSDictionary<NSString *,QJSettingItem *> *settingDict);

@interface QJHenTaiParser : NSObject

+ (instancetype)parser;

/*
 *  url:请求的网络连接
 *  completion:请求的回调
 */
//登陆相关
- (void)loginWithUserName:(NSString *)username password:(NSString *)password complete:(LoginHandler)completion;
- (BOOL)saveUserNameWithString:(NSString *)html;
- (BOOL)checkCookie;
- (BOOL)deleteCokie;
//读取设置
- (void)readSettingAllInfoCompletion:(SettingHandler)completion;
- (void)postMySettingInfoWithParams:(NSDictionary *)params Completion:(LoginHandler)completion;
//解析相关
//列表
- (void)updateListInfoWithUrl:(NSString *)url complete:(ListHandler)completion total:(TotalHandler)total;
- (void)updateHotListInfoComplete:(ListHandler)completion;
- (void)updateLikeListInfoWithUrl:(NSString *)url complete:(ListHandler)completion;
- (void)updateOtherListInfoWithUrl:(NSString *)url complete:(ListHandler)completion;
//获取单个链接的画廊信息
- (void)updateOneUrlInfoWithUrl:(NSString *)url complete:(ListHandler)completion;
//详情
- (void)updateGalleryInfoWithUrl:(NSString *)url complete:(GalleryHandler)completion;
//大图
//解析图片列表
- (void)updateBigImageUrlWithShowKey:(NSString *)showkey gid:(NSString *)gid url:(NSString *)url count:(NSInteger)count complete:(BigImageListHandler)completion;
//种子列表
- (void)updateTorrentInfoWithGid:(NSString *)gid token:(NSString *)token complete:(TorrentListHandler)completion;
//toplist
- (void)updateToplistInfoComplete:(ToplistHandler)completion;

//操作相关
//收藏
- (void)updateFavoriteStatus:(BOOL)isFavorite model:(QJListItem *)item index:(NSInteger)index content:(NSString *)content complete:(LoginHandler)completion;
- (void)updateMutlitFavoriteWithUrl:(NSString *)url status:(NSString *)ddact modifygids:(NSArray *)modifygids complete:(LoginHandler)completion;
//评论
- (void)updateCommentWithContent:(NSString *)content url:(NSString *)url complete:(LoginHandler)completion;
//评星
- (void)updateStarWithGid:(NSString *)gid token:(NSString *)token apikey:(NSString *)apikey apiuid:(NSString *)apiuid rating:(NSInteger)rating complete:(LoginHandler)completion;

@end
