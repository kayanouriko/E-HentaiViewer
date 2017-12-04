//
//  QJSearchBar.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/11/6.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QJSearchBarDelagate <NSObject>

@optional
- (void)didClickSiftBtn;

@end

@interface QJSearchBar : UIView

@property (weak, nonatomic) id<QJSearchBarDelagate>delegate;
@property (weak, nonatomic) IBOutlet UITextField *searchTextF;

@end
