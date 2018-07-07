//
//  QJSecretBgTool.h
//  EHenTaiViewer
//
//  Created by zedmacbook on 2018/7/3.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QJSecretBgTool : NSObject

+ (instancetype)sharedInstance;

- (void)showSecretBackground;
- (void)hiddenSecretBackground;

@end
