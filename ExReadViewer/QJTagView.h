//
//  QJTagView.h
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/31.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJCategoryButtonInfo;

@protocol QJTagViewDelagate <NSObject>

- (void)didClickTagButtonWithModel:(QJCategoryButtonInfo *)model;

@end

@interface QJTagView : UIView

@property (weak, nonatomic) id<QJTagViewDelagate>delegate;
/* array构成
 数组分两个元素,第一个为分类名 第二个为tag模型,类名为QJCategoryButtonInfo
 */
- (void)refreshUI:(NSArray *)array;

@end
