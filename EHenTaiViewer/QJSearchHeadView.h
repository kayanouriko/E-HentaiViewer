//
//  QJSearchHeadView.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/15.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QJSearchHeadViewDelagate <NSObject>

@optional
- (void)didClickMoreBtnWithTitle:(NSString *)title;

@end

@interface QJSearchHeadView : UITableViewCell

@property (weak, nonatomic) id<QJSearchHeadViewDelagate>delegate;

@end
