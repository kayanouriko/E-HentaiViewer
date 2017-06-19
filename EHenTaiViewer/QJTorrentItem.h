//
//  QJTorrentItem.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/9.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QJTorrentItem : NSObject

@property (nonatomic, strong) NSString *posted;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSString *seeds;
@property (nonatomic, strong) NSString *peers;
@property (nonatomic, strong) NSString *downloads;
@property (nonatomic, strong) NSString *uploader;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *magnet;

@end
