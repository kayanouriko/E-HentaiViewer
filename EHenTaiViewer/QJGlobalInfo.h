//
//  QJGlobalInfo.h
//  wikiForMHXX
//
//  Created by QinJ on 2017/4/18.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QJGlobalInfo : NSObject

+ (instancetype)sharedInstance;
- (void)putAttribute:(NSString*)key value:(id)value;
- (id)getAttribute:(NSString*)key;

@end
