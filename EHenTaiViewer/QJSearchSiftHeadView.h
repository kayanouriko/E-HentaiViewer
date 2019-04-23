//
//  QJSearchSiftHeadView.h
//  EHenTaiViewer
//
//  Created by QinJ on 2019/3/26.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QJSearchSiftHeadView;

@protocol QJSearchSiftHeadViewDelegate <NSObject>

@optional
// 点击标签按钮
- (void)didClickTagActionWithHeadView:(QJSearchSiftHeadView *)headView index:(NSInteger)index;

@end

@interface QJSearchSiftHeadView : UIVisualEffectView

@property (strong, nonatomic) NSArray *keys;
@property (weak, nonatomic) id<QJSearchSiftHeadViewDelegate>delegate;

- (instancetype)initWithKeys:(NSArray *)keys theDelegate:(id<QJSearchSiftHeadViewDelegate>)delegate;


@end

NS_ASSUME_NONNULL_END
