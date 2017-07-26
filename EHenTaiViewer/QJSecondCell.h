//
//  QJSecondCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/1.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QJTableViewCell.h"

@protocol QJSecondCellDelagate <NSObject>

- (void)didClickSecondBtnWithTag:(NSInteger)tag;

@end

@interface QJSecondCell : QJTableViewCell

@property (weak, nonatomic) id<QJSecondCellDelagate>delegate;

@end
