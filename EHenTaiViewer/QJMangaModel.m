//
//  QJMangaModel.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJMangaModel.h"

@implementation QJMangaModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.page = 1;
        self.state = QJMangaModelStateNotUrl;
    }
    return self;
}

@end
