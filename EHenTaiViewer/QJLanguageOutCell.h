//
//  QJLanguageOutCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJSettingLanguageItem;

@protocol QJLanguageOutCellDelagate <NSObject>

@optional
- (void)didClickBtn;

@end

@interface QJLanguageOutCell : UITableViewCell

@property (weak, nonatomic) id<QJLanguageOutCellDelagate>delegate;
@property (nonatomic, strong) QJSettingLanguageItem *model;

@end
