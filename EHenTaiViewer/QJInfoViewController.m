//
//  QJInfoViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJInfoViewController.h"
#import "XHStarRateView.h"
#import "QJInfoThumbCell.h"
#import "QJInfoBaseCell.h"
#import "QJInfoOtherCell.h"
#import "QJHenTaiParser.h"
#import "QJCommentCell.h"
#import "QJInfoTagCell.h"
#import "QJSecondCell.h"
#import "QJStarViewCell.h"
#import "QJListItem.h"
#import "QJGalleryItem.h"
#import "NSString+StringHeight.h"
#import "QJLikeBarButtonItem.h"
//其他列表
#import "QJOtherListController.h"
//评论
#import "QJGoCommentController.h"
//评星
#import "QJGoStarController.h"
//图片浏览器
#import "QJMangaViewController.h"
//种子
#import "QJTorrentInfoController.h"
//登陆
#import "QJLoginViewController.h"

@interface QJInfoViewController ()<UITableViewDelegate,UITableViewDataSource,QJSecondCellDelagate,QJLikeBarButtonItemDelagate>

@property (nonatomic, strong) QJLikeBarButtonItem *likeItem;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *headView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet XHStarRateView *starView;
@property (weak, nonatomic) IBOutlet UILabel *starLabel;
@property (weak, nonatomic) IBOutlet UIButton *torrentBtn;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *firstArr;
@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, strong) QJGalleryItem *galleryItem;

- (IBAction)valueChange:(UISegmentedControl *)sender;
- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
    [self updateResource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGRect rect = self.headView.frame;
    self.tableView.contentInset = UIEdgeInsetsMake(rect.origin.y + rect.size.height, 0, 10, 0);
}

#pragma mark -右上角收藏
- (void)didClickItem {
    //正在操作状态
    if (self.likeItem.state == QJLikeBarButtonItemStateLoading) {
        return;
    }
    //检测是否登录
    if (![[QJHenTaiParser parser] checkCookie]) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"未登录" message:@"是否前往登陆?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancelBtn];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            QJLoginViewController *vc = [QJLoginViewController new];
            [self presentViewController:vc animated:YES completion:nil];
        }];
        [alertVC addAction:okBtn];
        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    //正式操作
    self.likeItem.state = QJLikeBarButtonItemStateLoading;
    [[QJHenTaiParser parser] updateFavoriteStatus:self.galleryItem.isFavorite model:self.item complete:^(QJHenTaiParserStatus status) {
        if (status == QJHenTaiParserStatusSuccess) {
            self.galleryItem.isFavorite = !self.galleryItem.isFavorite;
            [self changeFavoritesStatus];
        }
    }];
}

#pragma mark -设置内容
- (void)setContent {
    //导航栏部分
    self.navigationItem.rightBarButtonItem = self.likeItem;
    
    [self setHeadPart];
    [self setButton];
    [self setTableView];
}

- (void)setHeadPart {
    //封面
    [self.thumbImageView yy_setImageWithURL:[NSURL URLWithString:self.item.thumb] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
    //标题
    self.titleLabel.text = self.item.title;
    //评分
    self.starView.backgroundColor = [UIColor clearColor];
    self.starView.currentScore = self.item.rating;
    //提示
    self.torrentBtn.hidden = !self.item.torrentcount;
}

- (void)setButton {
    /**
     *  400 上传者
     *  401 分类
     *  402 阅读
     *  403 废弃tag
     *  404 种子磁力链接
     */
    UIButton *btn = (UIButton *)[self.view viewWithTag:400];
    [btn setTitle:[NSString stringWithFormat:@"%@",self.item.uploader] forState:UIControlStateNormal];
    
    UIButton *btn1 = (UIButton *)[self.view viewWithTag:401];
    [btn1 setTitle:[NSString stringWithFormat:@"  %@  ",self.item.category] forState:UIControlStateNormal];
    btn1.backgroundColor = self.item.categoryColor;
    
    UIButton *btn2 = (UIButton *)[self.view viewWithTag:402];
    btn2.layer.borderColor = DEFAULT_COLOR.CGColor;
    btn2.layer.borderWidth = 1.f;
    btn2.layer.cornerRadius = 4.f;
    btn2.clipsToBounds = YES;
}

- (void)setTableView {
    //tableView
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJInfoThumbCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJInfoThumbCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJInfoBaseCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJInfoBaseCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJInfoOtherCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJInfoOtherCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJCommentCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJCommentCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJInfoTagCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJInfoTagCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSecondCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSecondCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJStarViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJStarViewCell class])];
}

#pragma mark -请求数据
- (void)updateResource {
    self.view.userInteractionEnabled = NO;
    [[QJHenTaiParser parser] updateGalleryInfoWithUrl:self.item.url complete:^(QJHenTaiParserStatus status, QJGalleryItem *item) {
        if (status == QJHenTaiParserStatusSuccess) {
            self.view.userInteractionEnabled = YES;
            self.galleryItem = item;
            self.rowCount = 3 + self.firstArr.count;
            //更新评价
            self.starLabel.text = [NSString stringWithFormat:@"(%@)",[item.baseInfoDic[@"favorited"] componentsSeparatedByString:@" "].firstObject];
            //改变收藏按钮
            [self changeFavoritesStatus];
            //刷新tableview
            [self.tableView reloadData];
        }
        [self.activity stopAnimating];
    }];
}

- (void)changeFavoritesStatus {
    if (self.galleryItem.isFavorite) {
        self.galleryItem.isFavorite = YES;
        self.likeItem.state = QJLikeBarButtonItemStateLike;
    } else {
        self.galleryItem.isFavorite = NO;
        self.likeItem.state = QJLikeBarButtonItemStateUnlike;
    }
}

#pragma mark -切换标签
- (IBAction)valueChange:(UISegmentedControl *)sender {
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
}

#pragma mark -按钮点击事件
- (IBAction)btnAction:(UIButton *)sender {
    switch (sender.tag - 400) {
        case 0:
        {
            //上传者
            /*
            QJOtherListController *vc = [QJOtherListController new];
            vc.type = QJOtherListControllerTypePerson;
            vc.key = self.item.uploader;
            [self.navigationController pushViewController:vc animated:YES];
             */
        }
            break;
        case 1:
        {
            //分类
            QJOtherListController *vc = [QJOtherListController new];
            vc.type = QJOtherListControllerTypeCatgoery;
            vc.key = [self.item.category lowercaseString];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            //阅读
            QJMangaViewController *vc = [QJMangaViewController new];
            vc.url = self.item.url;
            vc.gid = self.item.gid;
            vc.count = self.item.filecount;
            vc.showkey = self.galleryItem.showkey;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            //废弃
        }
            break;
        case 4:
        {
            //种子
            QJTorrentInfoController *vc = [QJTorrentInfoController new];
            vc.gid = self.item.gid;
            vc.token = self.item.token;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark -QJSecondCellDelagate
- (void)didClickSecondBtnWithTag:(NSInteger)tag {
    if (![[QJHenTaiParser parser] checkCookie]) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"未登录" message:@"是否前往登陆?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancelBtn];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            QJLoginViewController *vc = [QJLoginViewController new];
            [self presentViewController:vc animated:YES completion:nil];
        }];
        [alertVC addAction:okBtn];
        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    if (tag) {
        //评星
        QJGoStarController *vc = [QJGoStarController new];
        vc.apiuid = self.galleryItem.apiuid;
        vc.apikey = self.galleryItem.apikey;
        vc.token = self.item.token;
        vc.gid = self.item.gid;
        [self presentViewController:vc animated:YES completion:nil];
    }
    else {
        //评论
        QJGoCommentController *vc = [QJGoCommentController new];
        vc.url = self.item.url;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark -tableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segController.selectedSegmentIndex == 1) {
        return self.galleryItem.comments.count + 2;
    } else {
        return self.rowCount;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segController.selectedSegmentIndex == 1) {
        if (indexPath.row == 0) {
            QJStarViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJStarViewCell class])];
            [cell refreshUI:self.galleryItem listItem:self.item];
            return cell;
        }
        else if (indexPath.row == 1) {
            QJSecondCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJSecondCell class])];
            cell.delegate = self;
            return cell;
        }
        else {
            QJCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJCommentCell class])];
            [cell refreshUI:self.galleryItem.comments[indexPath.row - 2]];
            return cell;
        }
    } else {
        if (indexPath.row == 0) {
            QJInfoThumbCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJInfoThumbCell class])];
            [cell refreshUI:self.galleryItem];
            return cell;
        }
        else if (indexPath.row == 1) {
            QJInfoTagCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJInfoTagCell class])];
            [cell refreshUI:self.galleryItem.tagArr];
            return cell;
        }
        else if (indexPath.row == 2) {
            QJInfoBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJInfoBaseCell class])];
            [cell refreshUI:self.galleryItem listItem:self.item];
            return cell;
        }
        else {
            QJInfoOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJInfoOtherCell class])];
            cell.titleNameLabel.text = self.firstArr[indexPath.row - 3];
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.segController.selectedSegmentIndex == 0 && (indexPath.row == 3 || indexPath.row == 4)) {
        NSString *url = [NSString stringWithFormat:@"?f_doujinshi=1&f_manga=1&f_artistcg=1&f_gamecg=1&f_western=1&f_non-h=1&f_imageset=1&f_cosplay=1&f_asianporn=1&f_misc=1&f_search=%@&f_apply=Apply+Filter",[[self.item.title handleString] urlEncode]];
        QJOtherListController *vc = [QJOtherListController new];
        vc.type = indexPath.row == 3 ? QJOtherListControllerTypeTag : QJOtherListControllerTypePerson;
        vc.key = indexPath.row == 3 ? url : self.item.uploader;
        vc.titleName = indexPath.row == 3 ? @"类似画廊" : nil;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -setter
- (NSInteger)rowCount {
    if (!_rowCount) {
        _rowCount = 0;
    }
    return _rowCount;
}

- (NSArray *)firstArr {
    if (!_firstArr) {
        _firstArr = @[@"类似画廊",@"上传者上传的其他画廊"];
    }
    return _firstArr;
}

- (QJLikeBarButtonItem *)likeItem {
    if (!_likeItem) {
        _likeItem = [QJLikeBarButtonItem new];
        _likeItem.delegate = self;
    }
    return _likeItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
