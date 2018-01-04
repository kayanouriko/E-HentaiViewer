//
//  QJMangaModel.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QJMangaModelState) {
    QJMangaModelStateNotUrl, //尚未解析到url
    QJMangaModelStateWait,//等待下载(包括暂停)
    QJMangaModelStateDownloading,//下载中
    QJMangaModelStateSuccess,//下载成功
    QJMangaModelStateFail,//下载失败
};

@interface QJMangaModel : NSObject

//图片链接
@property (nonatomic, strong) NSString *url;
//状态
@property (nonatomic, assign) QJMangaModelState state;
//页码
@property (nonatomic, assign) NSInteger page;

@end
