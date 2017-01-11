//
//  QJSiderView.h
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/7.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QJSiderViewDelagate <NSObject>

- (void)didClickSiderWithDict:(NSDictionary *)dict;

@end

@interface QJSiderView : UIView

@property (weak, nonatomic) id<QJSiderViewDelagate>delegate;

+ (QJSiderView *)shareView;
- (void)show;

@end
