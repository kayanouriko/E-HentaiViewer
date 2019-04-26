//
//  QJPasteManager.h
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/25.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

// 该类主要是检测粘贴板里面的内容

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJPasteManager : NSObject

+ (instancetype)sharedInstance;

- (void)checkInfoFromPasteBoard;

@end

NS_ASSUME_NONNULL_END
