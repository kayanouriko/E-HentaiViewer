//
//  QJHomeViewController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/18.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

@interface QJHomeViewController : QJViewController

@property (nonatomic, strong) NSString *navTitle;
@property (nonatomic, strong) NSString *url;

- (void)scrollToTop;

@end
