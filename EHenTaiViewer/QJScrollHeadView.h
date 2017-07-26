//
//  QJScrollHeadView.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QJScrollHeadViewDelagate <NSObject>

@optional
- (void)didSelectedTitleWithIndex:(NSInteger)index;

@end

@interface QJScrollHeadView : UIView

@property (weak, nonatomic) id<QJScrollHeadViewDelagate>delegate;
@property (nonatomic, assign) NSInteger selectedIndex;

@end
