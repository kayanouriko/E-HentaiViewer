//
//  QJGoCommentController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/1.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJGoCommentController.h"
#import "QJHenTaiParser.h"

@interface QJGoCommentController ()

@property (weak, nonatomic) IBOutlet UITextView *textV;

- (IBAction)cancelAction:(UIBarButtonItem *)sender;
- (IBAction)sendInfoAction:(UIBarButtonItem *)sender;

@end

@implementation QJGoCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.textV becomeFirstResponder];
}

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendInfoAction:(UIBarButtonItem *)sender {
    if (!self.textV.text.length) {
        ToastWarning(nil, @"评论内容不能为空!");
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
