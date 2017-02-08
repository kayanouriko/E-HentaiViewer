//
//  QJTopButtonView.h
//  ExReadViewer
//
//  Created by QinJ on 2017/2/2.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QJTopButtonViewDelagate <NSObject>

- (void)didClickChannelWithName:(NSString *)title;

@end

@interface QJTopButtonView : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) id<QJTopButtonViewDelagate>delegate;

@end
