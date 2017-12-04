//
//  QJGoCommentController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/1.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJGoCommentController.h"
#import "QJHenTaiParser.h"

@interface QJGoCommentController ()<UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navgationBar;
@property (weak, nonatomic) IBOutlet UITextView *textV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarTopLine;

- (IBAction)cancelAction:(UIBarButtonItem *)sender;
- (IBAction)sendInfoAction:(UIBarButtonItem *)sender;

@end

@implementation QJGoCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.textV becomeFirstResponder];
    
    self.navgationBar.delegate = self;
    self.navigationBarTopLine.constant = UIStatusBarHeight();
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendInfoAction:(UIBarButtonItem *)sender {
    if (!self.textV.text.length) {
        Toast(@"评论内容为空");
        return;
    }
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [[QJHenTaiParser parser] updateCommentWithContent:self.textV.text url:self.url complete:^(QJHenTaiParserStatus status) {
            
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
