//
//  QJMangaTorrentActivity.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/8.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJMangaTorrentActivity.h"

NSString *const UIActivityTypeQJTorrent = @"QJMangaTorrentActivity";

@implementation QJMangaTorrentActivity

- (NSString *)activityType {
    return UIActivityTypeQJTorrent;
}

- (NSString *)activityTitle {
    return @"复制画廊磁力链接";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"torrent"];
}

@end
