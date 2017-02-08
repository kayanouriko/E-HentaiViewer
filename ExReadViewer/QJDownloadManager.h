//
//  QJDownloadManager.h
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/13.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QJDownloadManager : NSOperationQueue

+ (QJDownloadManager *)shareQueue;

- (void)addOneBookDownQueueWithImageUrlArr:(NSArray *)images bookName:(NSString *)bookName;

@end
