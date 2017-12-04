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
#import "QJNetworkTool.h"
//其他列表
#import "QJOtherListController.h"
#import "QJSearchViewController.h"
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
//收藏
#import "QJFavouriteViewController.h"

@interface QJInfoViewController ()<UITableViewDelegate,UITableViewDataSource,QJSecondCellDelagate,UIScrollViewDelegate,QJFavouriteViewControllerDelagate>

@property (weak, nonatomic) IBOutlet UIVisualEffectView *headView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet XHStarRateView *starView;
@property (weak, nonatomic) IBOutlet UILabel *starLabel;
@property (weak, nonatomic) IBOutlet UIButton *torrentBtn;

@property (weak, nonatomic) IBOutlet UIView *segView;
@property (weak, nonatomic) IBOutlet UIView *segUnderLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segViewLeftLine;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

//内容部分
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *infoTableView;
@property (nonatomic, strong) UITableView *conmentTableView;

@property (nonatomic, strong) NSArray *firstArr;
@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, strong) QJGalleryItem *galleryItem;
@property (nonatomic, assign, getter=isNeedRefresh) BOOL needRefresh; //是否需要刷新布局

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setContent];
    [self updateResource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isNeedRefresh) {
        self.needRefresh = NO;
        CGRect rect = self.headView.frame;
        self.infoTableView.contentInset = UIEdgeInsetsMake(rect.origin.y + rect.size.height, 0, 10, 0);
        self.conmentTableView.contentInset = UIEdgeInsetsMake(rect.origin.y + rect.size.height, 0, 10, 0);
        self.segViewLeftLine.constant = self.segView.frame.size.width / 4 - 45;
        self.segUnderLine.hidden = NO;
    }
}

#pragma mark -右上角收藏
- (void)didClickItem {
    /*
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
    if (self.galleryItem.isFavorite) {
        self.likeItem.state = QJLikeBarButtonItemStateLoading;
        //取消收藏
        [[QJHenTaiParser parser] updateFavoriteStatus:self.galleryItem.isFavorite model:self.item index:0 content:@"" complete:^(QJHenTaiParserStatus status) {
            if (status == QJHenTaiParserStatusSuccess) {
                self.galleryItem.isFavorite = !self.galleryItem.isFavorite;
                [self changeFavoritesStatus];
            }
        }];
    } else {
        //收藏,跳转收藏界面
        QJFavouriteViewController *vc = [QJFavouriteViewController new];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }
     */
}

/*
#pragma mark -QJFavouriteViewControllerDelagate
- (void)didSelectFolder:(NSInteger)index content:(NSString *)content {
    self.likeItem.state = QJLikeBarButtonItemStateLoading;
    [[QJHenTaiParser parser] updateFavoriteStatus:self.galleryItem.isFavorite model:self.item index:index content:content complete:^(QJHenTaiParserStatus status) {
        if (status == QJHenTaiParserStatusSuccess) {
            self.galleryItem.isFavorite = !self.galleryItem.isFavorite;
            [self changeFavoritesStatus];
        }
    }];
}
*/
#pragma mark -设置内容
- (void)setContent {
    self.view.backgroundColor = [UIColor whiteColor];
    //导航栏部分
    //self.navigationItem.rightBarButtonItem = self.likeItem;
    
    [self setHeadPart];
    [self setButton];
    [self setTableView];
}

- (void)setHeadPart {
    self.needRefresh = YES;
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
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(UIScreenWidth() * 2, UIScreenHeight());
    //tableView
    if (@available(iOS 11.0, *)) {
        self.infoTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.conmentTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.scrollView addSubview:self.infoTableView];
    [self.scrollView addSubview:self.conmentTableView];
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
            [self.infoTableView reloadData];
            [self.conmentTableView reloadData];
        }
        [self.activity stopAnimating];
    }];
}

- (void)changeFavoritesStatus {
    /*
    if (self.galleryItem.isFavorite) {
        self.galleryItem.isFavorite = YES;
        self.likeItem.state = QJLikeBarButtonItemStateLike;
    } else {
        self.galleryItem.isFavorite = NO;
        self.likeItem.state = QJLikeBarButtonItemStateUnlike;
    }
     */
}

#pragma mark -按钮点击事件
- (IBAction)btnAction:(UIButton *)sender {
    switch (sender.tag - 400) {
        case 0:
        {
            //上传者
            //废弃
        }
            break;
        case 1:
        {
            //分类
            //废弃
        }
            break;
        case 2:
        {
            //阅读
            if ([[QJNetworkTool shareTool] isEnableMobleNetwork] && ![NSObjForKey(@"WatchMode") boolValue]) {
                Toast(@"想要浏览大图画廊请到设置中打开相关选项");
                return;
            }
            QJMangaViewController *vc = [QJMangaViewController new];
            vc.url = self.item.url;
            vc.gid = self.item.gid;
            vc.count = self.item.filecount;
            vc.showkey = self.galleryItem.showkey;
            [self presentViewController:vc animated:YES completion:nil];
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
        case 5:
        {
            //详情
            [self changeUnderLineWithBool:NO isChangeScrollView:YES];
        }
            break;
        case 6:
        {
            //评论
            [self changeUnderLineWithBool:YES isChangeScrollView:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark -标签切换
- (void)changeUnderLineWithBool:(BOOL)isRight isChangeScrollView:(BOOL)isChangeScrollView {
    //修改下滑线
    [UIView animateWithDuration:0.25f animations:^{
        self.segViewLeftLine.constant = isRight ? self.segView.frame.size.width * 3 / 4 - 45 : self.segView.frame.size.width / 4 - 45;
        [self.segView layoutIfNeeded];
    }];
    //修改按钮颜色
    UIButton *button1 = (UIButton *)[self.view viewWithTag:405];
    UIButton *button2 = (UIButton *)[self.view viewWithTag:406];
    [button1 setTitleColor:isRight ? [UIColor blackColor] : DEFAULT_COLOR forState:UIControlStateNormal];
    [button2 setTitleColor:isRight ? DEFAULT_COLOR : [UIColor blackColor] forState:UIControlStateNormal];
    //修改scrollview的Offset
    if (isChangeScrollView) {
        [self.scrollView setContentOffset:CGPointMake(isRight ? UIScreenWidth() : 0, 0) animated:YES];
    }
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        BOOL isRight = self.scrollView.contentOffset.x / UIScreenWidth();
        [self changeUnderLineWithBool:isRight isChangeScrollView:NO];
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
    if (tableView == self.conmentTableView) {
        return self.galleryItem.comments.count + 2;
    }
    else {
        return self.rowCount;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.conmentTableView) {
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
    }
    else {
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
    if (tableView == self.infoTableView && (indexPath.row == 3 || indexPath.row == 4)) {
        NSString *searchKey = @"";
        NSString *url = @"";
        if (indexPath.row == 3) {
            searchKey = [self.item.title handleString];
            url = [NSString stringWithFormat:@"?f_doujinshi=1&f_manga=1&f_artistcg=1&f_gamecg=1&f_western=1&f_non-h=1&f_imageset=1&f_cosplay=1&f_asianporn=1&f_misc=1&f_search=%@&f_apply=Apply+Filter",[searchKey urlEncode]];
        }
        else {
            searchKey = [NSString stringWithFormat:@"uploader:%@", self.item.uploader];
            url = [NSString stringWithFormat:@"uploader/%@/", self.item.uploader];
        }
        if (indexPath.row == 3 && searchKey.length == 0) {
            Toast(@"暂无类似画廊");
            return;
        }
        
        QJGalleryTagItem *model = [QJGalleryTagItem new];
        model.searchKey = searchKey;
        model.url = url;
        
        QJSearchViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([QJSearchViewController class])];
        vc.model = model;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -getter
-  (UITableView *)infoTableView {
    if (nil == _infoTableView) {
        _infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(isPad ? 130 : 0, 0, isPad ? UIScreenWidth() - 260 : UIScreenWidth(), UIScreenHeight())];
        _infoTableView.showsVerticalScrollIndicator = NO;
        _infoTableView.rowHeight = UITableViewAutomaticDimension;
        _infoTableView.estimatedRowHeight = 100;
        _infoTableView.delegate = self;
        _infoTableView.dataSource = self;
        _infoTableView.tableFooterView = [UIView new];
        [_infoTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJInfoThumbCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJInfoThumbCell class])];
        [_infoTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJInfoBaseCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJInfoBaseCell class])];
        [_infoTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJInfoOtherCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJInfoOtherCell class])];
        [_infoTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJInfoTagCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJInfoTagCell class])];
    }
    return _infoTableView;
}

- (UITableView *)conmentTableView {
    if (nil == _conmentTableView) {
        _conmentTableView = [[UITableView alloc] initWithFrame:CGRectMake(isPad ?  UIScreenWidth() + 130 : UIScreenWidth(), 0,isPad ? UIScreenWidth() - 260 : UIScreenWidth(), UIScreenHeight())];
        _conmentTableView.showsVerticalScrollIndicator = NO;
        _conmentTableView.rowHeight = UITableViewAutomaticDimension;
        _conmentTableView.estimatedRowHeight = 100;
        _conmentTableView.delegate = self;
        _conmentTableView.dataSource = self;
        _conmentTableView.tableFooterView = [UIView new];
        [_conmentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJCommentCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJCommentCell class])];
        [_conmentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJSecondCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJSecondCell class])];
        [_conmentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([QJStarViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([QJStarViewCell class])];
    }
    return _conmentTableView;
}

- (NSInteger)rowCount {
    if (!_rowCount) {
        _rowCount = 0;
    }
    return _rowCount;
}

- (NSArray *)firstArr {
    if (!_firstArr) {
        _firstArr = @[@"类似画廊",@"上传者的其他画廊"];
    }
    return _firstArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
