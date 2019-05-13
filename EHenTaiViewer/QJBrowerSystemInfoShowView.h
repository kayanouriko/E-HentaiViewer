//
//  QJBrowerSystemInfoShowView.h
//  EHenTaiViewer
//
//  Created by QinJ on 2019/5/10.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJBrowerSystemInfoShowView : UIView

@property (weak, nonatomic) IBOutlet UILabel *progessLabel;

- (void)updateInfo;

@end

NS_ASSUME_NONNULL_END
