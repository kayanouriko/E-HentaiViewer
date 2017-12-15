//
//  QJFavouriteViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/16.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJFavouriteViewController.h"
#import "QJHenTaiParser.h"
#import "QJFavoritesSelectController.h"

@interface QJFavouriteViewController ()<QJFavoritesSelectControllerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *favFolderViewTopLine;

@property (weak, nonatomic) IBOutlet UIButton *folderBtn;
@property (weak, nonatomic) IBOutlet UITextView *contentTextV;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSArray *selectArr;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJFavouriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加收藏";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(likeAction:)];
    self.navigationItem.rightBarButtonItem = item;
    
    self.view.backgroundColor = [UIColor whiteColor];
    //默认在收藏夹0
    self.index = 0;
    //激活
    [self.contentTextV becomeFirstResponder];
    
    self.favFolderViewTopLine.constant = UINavigationBarHeight() + 20;
    
    [self readFavInfo];
}

- (void)readFavInfo {
    NSArray<NSArray<NSString *> *> *array = NSObjForKey(@"favorites");
    if (nil != array && array.count) {
        [self.folderBtn setTitle:[NSString stringWithFormat:@"%@ >",array.firstObject.firstObject] forState:UIControlStateNormal];
    }
    else {
        [self showFreshingViewWithTip:nil];
        [[QJHenTaiParser parser] updateLikeListInfoWithUrl:@"favorites.php" complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
            NSArray<NSArray<NSString *> *> *array = NSObjForKey(@"favorites");
            if (nil != array && array.count) {
                [self.folderBtn setTitle:[NSString stringWithFormat:@"%@ >",array.firstObject.firstObject] forState:UIControlStateNormal];
                [self hiddenFreshingView];
            }
            else {
                [self showErrorViewWithTip:nil];
            }
        }];
    }
}

- (IBAction)btnAction:(UIButton *)sender {
    QJFavoritesSelectController *vc = [QJFavoritesSelectController new];
    vc.likeVCJump = NO;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -QJFavoritesSelectControllerDelegate
- (void)didSelectFavFolderNameWithArr:(NSArray<NSString *> *)array index:(NSInteger)index {
    self.index = index;
    [self.folderBtn setTitle:[NSString stringWithFormat:@"%@ >",array.firstObject] forState:UIControlStateNormal];
}

- (void)likeAction:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didSelectFolder:content:)]) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate didSelectFolder:self.index content:self.contentTextV.text];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
