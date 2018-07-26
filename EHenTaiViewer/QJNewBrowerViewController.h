//
//  QJNewBrowerViewController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/7.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

@interface QJNewBrowerViewController : QJViewController

@property (nonatomic, strong) NSString *mangaName;
@property (nonatomic, strong) NSString *showkey;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *gid;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSArray *imageUrls;
@property (nonatomic, strong) NSArray *smallImageUrls;

@end
