//
//  QJFavouriteViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/16.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJFavouriteViewController.h"
#import "QJFavSelectViewController.h"
#import "QJFavSelectViewController.h"

@interface QJFavouriteViewController ()<QJFavSelectViewControllerDelagate>

@property (weak, nonatomic) IBOutlet UIButton *folderBtn;
@property (weak, nonatomic) IBOutlet UITextView *contentTextV;
@property (nonatomic, assign) NSInteger index;

- (IBAction)btnAction:(UIButton *)sender;

- (IBAction)canelAction:(UIBarButtonItem *)sender;
- (IBAction)likeAction:(UIBarButtonItem *)sender;

@end

@implementation QJFavouriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //默认在收藏夹0
    self.index = 0;
    //激活
    [self.contentTextV becomeFirstResponder];
}

- (IBAction)btnAction:(UIButton *)sender {
    QJFavSelectViewController *vc = [QJFavSelectViewController new];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark -QJFavSelectViewControllerDelagate
- (void)didSelectFavFolder:(NSInteger)index {
    self.index = index;
    [self.folderBtn setTitle:[NSString stringWithFormat:@"Favorites %ld >",index] forState:UIControlStateNormal];
}

- (IBAction)canelAction:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)likeAction:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didSelectFolder:content:)]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.delegate didSelectFolder:self.index content:self.contentTextV.text];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
