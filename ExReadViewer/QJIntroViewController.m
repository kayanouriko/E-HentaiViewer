//
//  QJIntroViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/28.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJIntroViewController.h"
#import "QJIntroInfoModel.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "QJTagView.h"
#import "QJTagViewController.h"
#import "QJCommentCell.h"
#import "QJAllCommentViewController.h"
#import "QJThumbImageCell.h"
#import "HentaiParser.h"
#import "MWPhotoBrowser.h"
#import "QJScoreView.h"
#import "QJDataManager.h"
#import "QJDownloadManager.h"

typedef NS_ENUM(NSInteger, introButtonStyle){
    introButtonStyleDownload, //下载
    introButtonStyleRead //阅读
};

@interface QJIntroViewController ()<QJTagViewDelagate,UICollectionViewDelegate,UICollectionViewDataSource,MWPhotoBrowserDelegate,QJScoreViewDelagate>
//简介部分
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeightLine;
@property (weak, nonatomic) IBOutlet UIView *introButtonView;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *readBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIButton *categoryBtn;
@property (weak, nonatomic) IBOutlet UILabel *pageLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *postedLabel;

@property (strong, nonatomic) NSString *categoryName;
@property (strong, nonatomic) NSString *categoryUrl;
//简介类别点击事件
- (IBAction)categoryBtnAction:(UIButton *)sender;
//下载和阅读点击事件
- (IBAction)btnAction:(UIButton *)sender;
//评分部分
@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (strong, nonatomic) QJScoreView *scoreBgView;
//tag部分
@property (weak, nonatomic) IBOutlet UIView *tagView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagViewHeightLine;
//评论部分
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewHeightLine;
@property (strong, nonatomic) NSArray *allCommentArr;
//缩略图部分
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoViewHeightLine;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *datas;
//一些数据属性
@property (assign, nonatomic) BOOL isCollected;
@property (strong, nonatomic) QJDataManager *manager;
@property (assign, nonatomic) NSInteger requestCount;//请求页码的次数
@property (strong, nonatomic) NSMutableArray *bigImageUrlArr;
@property (strong, nonatomic) NSMutableArray *downImageUrlArr;
@property (strong, nonatomic) NSDictionary *colorDict;

//浏览器部分
@property (strong, nonatomic) MWPhotoBrowser *browser;

@end

@implementation QJIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self creatUI];
    [self updateResource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    self.browser = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)creatUI {
    //数据库初始化
    NSString *localPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [localPath  stringByAppendingPathComponent:@"QJCoreDataModel.db"];
    NSLog(@"%@",filePath);
    self.manager = [[QJDataManager alloc] initWithCoreData:@"Favorites" modelName:@"QJCoreDataModel" sqlPath:filePath success:nil fail:nil];
    self.isCollected = NO;
    [self.manager readEntity:@[] ascending:NO filterStr:[NSString stringWithFormat:@"url == '%@'",self.introUrl] success:^(NSArray *results) {
        if (results.count) {
            self.isCollected = YES;
        }
    } fail:nil];
    
    [self.downloadBtn setTitle:NSLocalizedString(@"download", nil) forState:UIControlStateNormal];
    [self.readBtn setTitle:NSLocalizedString(@"read", nil) forState:UIControlStateNormal];
    
    self.introButtonView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.introButtonView.layer.shadowOffset = CGSizeMake(4,4);
    self.introButtonView.layer.shadowOpacity = 0.2;
    self.introButtonView.layer.shadowRadius = 4;
    
    [self.photoView addSubview:self.collectionView];
    [self.photoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_collectionView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_collectionView)]];
    [self.photoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_collectionView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_collectionView)]];
}

- (void)updateResource {
    [SVProgressHUD show];
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer = [AFHTTPResponseSerializer serializer];
    [session GET:self.introUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSData *data = responseObject;
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",html);
        QJIntroInfoModel *model = [[QJIntroInfoModel alloc] initWithData:data];
        if (model.needUser) {
            [SVProgressHUD showErrorWithStatus:@"该画廊需要额外处理,暂不支持浏览QAQ"];
            [SVProgressHUD dismissWithDelay:2.f];
            return;
        }
        else {
            [self refreshUIWithModel:model];
            //缩略图部分
            self.datas = model.allImageUrlArr;
            [self.collectionView reloadData];
            CGFloat itemWidth = (kScreenWidth - 10) / 3 - 10;
            CGFloat itemHeight = itemWidth * 190 / 120 + 10;
            self.photoViewHeightLine.constant = (self.datas.count % 3 ? (self.datas.count / 3) + 1 : self.datas.count / 3) * itemHeight;
            [self updateScrollViewHeight];
            //获取大图地址
            self.requestCount = model.requestCount;
            [self getAllBigImageUrlWithPageCount:0];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)refreshUIWithModel:(QJIntroInfoModel *)model {
    //简介部分
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.infoDict[@"thumb"]] placeholderImage:[UIImage imageNamed:@"panda"] options:SDWebImageHandleCookies];
    self.titleLabel.text = model.introDict[@"title"];
    self.authorLabel.text = model.introDict[@"author"];
    [self.categoryBtn setTitle:[NSString stringWithFormat:@"  %@  ",model.introDict[@"category"]] forState:UIControlStateNormal];
    self.categoryName = model.introDict[@"category"];
    self.categoryBtn.backgroundColor = self.colorDict[model.introDict[@"category"]];
    self.categoryUrl = model.introDict[@"categoryUrl"];
    self.pageLabel.text = model.introDict[@"length"];
    self.languageLabel.text = model.introDict[@"language"];
    self.sizeLabel.text = model.introDict[@"size"];
    self.likeLabel.text = [NSString stringWithFormat:@"❤%@",model.introDict[@"favorited"]];
    self.postedLabel.text = model.introDict[@"posted"];
    //评分部分
    self.scoreBgView = [[NSBundle mainBundle] loadNibNamed:@"QJScoreView" owner:nil options:nil][0];
    self.scoreBgView.frame = CGRectMake(0, 0, kScreenWidth, 191);
    self.scoreBgView.delegate = self;
    if (self.isCollected) {
        [self.scoreBgView.collectBtn setImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
        self.scoreBgView.favoritesLabel.text = NSLocalizedString(@"favorited", nil);
    }
    [self.scoreBgView refreshUI:model.introDict];
    [self.scoreView addSubview:self.scoreBgView];
    //tag部分
    CGFloat tagViewHeight = 10;
    for (NSArray *subArray in model.tagArr) {
        CGFloat viewHeight = [subArray[2] floatValue];
        QJTagView *tagView = [[QJTagView alloc] initWithFrame:CGRectMake(0, tagViewHeight, kScreenWidth, viewHeight)];
        tagView.delegate = self;
        [self.tagView addSubview:tagView];
        [tagView refreshUI:subArray];
        tagViewHeight += viewHeight;
    }
    //如果没有tag,提示没有tag
    if (model.tagArr.count == 0) {
        UILabel *tagLabel = [UILabel new];
        tagLabel.text = NSLocalizedString(@"notag", nil);
        tagLabel.textAlignment = NSTextAlignmentCenter;
        tagLabel.font = kNormalFontSize;
        tagLabel.frame = CGRectMake(0, 0, kScreenWidth, 50);
        tagLabel.textColor = [UIColor lightGrayColor];
        [self.tagView addSubview:tagLabel];
        tagViewHeight = 50;
    }
    self.tagViewHeightLine.constant = tagViewHeight;
    //评论部分
    CGFloat commentViewHeight = 0;
    for (NSInteger i = 0; i < model.commentsArr.count; i++) {
        if (i == 2) {
            break;
        }
        NSDictionary *subDict = model.commentsArr[i];
        NSString *content = subDict[@"content"];
        CGFloat height = [content boundingRectWithSize:CGSizeMake(kScreenWidth - 40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]} context:nil].size.height + 80;
        QJCommentCell *cell = [[NSBundle mainBundle] loadNibNamed:@"QJCommentCell" owner:nil options:nil][0];
        cell.frame = CGRectMake(0, commentViewHeight, kScreenWidth, height);
        [cell refreshUI:subDict];
        [self.commentView addSubview:cell];
        commentViewHeight += height;
    }
    //如果评论大于两个,则跳转新界面
    if (model.commentsArr.count > 2) {
        self.allCommentArr = model.commentsArr;
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [moreBtn setTitle:NSLocalizedString(@"more", nil) forState:UIControlStateNormal];
        moreBtn.titleLabel.font = kNormalFontSize;
        [moreBtn addTarget:self action:@selector(pushAllCommentVC) forControlEvents:UIControlEventTouchUpInside];
        moreBtn.frame = CGRectMake(0, commentViewHeight, kScreenWidth, 30);
        [self.commentView addSubview:moreBtn];
        commentViewHeight += 30;
    }
    self.commentViewHeightLine.constant = commentViewHeight;
    //如果没有评论,提示没有评论
    if (model.commentsArr.count == 0) {
        UILabel *commentLabel = [UILabel new];
        commentLabel.text = NSLocalizedString(@"nocomment", nil);
        commentLabel.textAlignment = NSTextAlignmentCenter;
        commentLabel.font = kNormalFontSize;
        commentLabel.frame = CGRectMake(0, commentViewHeight, kScreenWidth, 50);
        commentLabel.textColor = [UIColor lightGrayColor];
        [self.commentView addSubview:commentLabel];
        commentViewHeight += 50;
    }
    self.commentViewHeightLine.constant = commentViewHeight;
    //先更新一次约束线
    [self updateScrollViewHeight];
}

- (void)updateScrollViewHeight {
    self.scrollViewHeightLine.constant = 340 + 1 + 191 + 1 + self.tagViewHeightLine.constant + 1 + self.commentViewHeightLine.constant + 1 + self.photoViewHeightLine.constant;
}

- (void)getAllBigImageUrlWithPageCount:(NSInteger)index {
    [HentaiParser requestImagesAtURL:self.introUrl atIndex:index completion:^(HentaiParserStatus status, NSArray *images) {
        if (status == HentaiParserStatusSuccess) {
            [self.downImageUrlArr addObjectsFromArray:images];
            for (NSString *iamgeUrl in images) {
                [self.bigImageUrlArr addObject:[MWPhoto photoWithURL:[NSURL URLWithString:iamgeUrl]]];
                [SVProgressHUD dismiss];
                [self.browser reloadData];
            }
            NSInteger i = index + 1;
            if (i <= self.requestCount) {
                [self getAllBigImageUrlWithPageCount:i];
            }
        }
    }];
}

#pragma mark -阅读和下载
- (IBAction)btnAction:(UIButton *)sender {
    if (self.bigImageUrlArr.count) {
        introButtonStyle status = sender.tag - 1000;
        switch (status) {
            case introButtonStyleDownload:
            {
                
                [SVProgressHUD showErrorWithStatus:@"功能待开发QAQ"];
                [SVProgressHUD dismissWithDelay:1.f];
                
                //[[QJDownloadManager shareQueue] addOneBookDownQueueWithImageUrlArr:self.downImageUrlArr bookName:self.infoDict[@"title"]];
                
            }
                break;
            case introButtonStyleRead:
            {
                [self.browser setCurrentPhotoIndex:0];
                [self.navigationController pushViewController:self.browser animated:YES];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark -QJScoreViewDelagate
- (void)didClickBtnWithStatus:(ScoreViewType)status {
    if (self.bigImageUrlArr.count) {
        switch (status) {
            case ScoreViewTypeFavorites:
            {
                //收藏
                [self changeFavoritesStatus];
            }
                break;
            case ScoreViewTypeShare:
            {
                //分享
                [self shareInfo];
                
            }
                break;
            case ScoreViewTypeSimilar:
            {
                //搜索类似
                [self pushSimilarVC];
            }
                break;
            case ScoreViewTypeCover:
            {
                //搜索封面
                [SVProgressHUD showErrorWithStatus:@"功能待开发QAQ"];
                [SVProgressHUD dismissWithDelay:1.f];
            }
                break;
            default:
                break;
        }
    }
}

- (void)pushSimilarVC {
    NSString *url = [NSString stringWithFormat:@"http://g.e-hentai.org/?f_doujinshi=1&f_manga=1&f_artistcg=1&f_gamecg=1&f_western=1&f_non-h=1&f_imageset=1&f_cosplay=1&f_asianporn=1&f_misc=1&f_search=%@&f_apply=Apply+Filter",[self handleStringWithString:self.titleLabel.text]];
    QJTagViewController *vc = [QJTagViewController new];
    vc.tagName = NSLocalizedString(@"similar_gallery", nil);
    vc.mainUrl = url;
    [self.navigationController pushViewController:vc animated:YES];
}

//傻逼算法
- (NSString *)handleStringWithString:(NSString *)str {
    NSMutableString * muStr = [NSMutableString stringWithString:str];
    while (1) {
        NSRange range = [muStr rangeOfString:@"("];
        NSRange range1 = [muStr rangeOfString:@")"];
        if (range.location != NSNotFound) {
            NSInteger loc = range.location;
            NSInteger len = range1.location - range.location;
            [muStr deleteCharactersInRange:NSMakeRange(loc, len + 1)];
        }else{
            NSRange range = [muStr rangeOfString:@"（"];
            NSRange range1 = [muStr rangeOfString:@"）"];
            if (range.location != NSNotFound) {
                NSInteger loc = range.location;
                NSInteger len = range1.location - range.location;
                [muStr deleteCharactersInRange:NSMakeRange(loc, len + 1)];
            }else{
                NSRange range = [muStr rangeOfString:@"【"];
                NSRange range1 = [muStr rangeOfString:@"】"];
                if (range.location != NSNotFound) {
                    NSInteger loc = range.location;
                    NSInteger len = range1.location - range.location;
                    [muStr deleteCharactersInRange:NSMakeRange(loc, len + 1)];
                }else{
                    NSRange range = [muStr rangeOfString:@"["];
                    NSRange range1 = [muStr rangeOfString:@"]"];
                    if (range.location != NSNotFound) {
                        NSInteger loc = range.location;
                        NSInteger len = range1.location - range.location;
                        [muStr deleteCharactersInRange:NSMakeRange(loc, len + 1)];
                    }else{
                        break;
                    }
                }
            }
        }
    }
    NSString *string = [muStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

- (void)changeFavoritesStatus {
    if (self.isCollected) {
        __block NSManagedObject *obj = nil;
        [self.manager readEntity:@[] ascending:NO filterStr:[NSString stringWithFormat:@"url == '%@'",self.introUrl] success:^(NSArray *results) {
            if (results.count) {
                obj = (NSManagedObject *)results.firstObject;
            }
        } fail:nil];
        [self.manager deleteEntity:obj success:^{
            [self.scoreBgView.collectBtn setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateNormal];
            self.scoreBgView.favoritesLabel.text = NSLocalizedString(@"favorites", nil);
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"remove_from_favorite_success", nil)];
            [SVProgressHUD dismissWithDelay:1.f];
        } fail:nil];
    } else {
        [self.manager insertNewEntity:self.infoDict success:^{
            [self.scoreBgView.collectBtn setImage:[UIImage imageNamed:@"collected"] forState:UIControlStateNormal];
            self.scoreBgView.favoritesLabel.text = NSLocalizedString(@"favorited", nil);
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"add_to_favorite_success", nil)];
            [SVProgressHUD dismissWithDelay:1.f];
            
        } fail:nil];
    }
    self.isCollected = !self.isCollected;
}

- (void)shareInfo {
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[self.titleLabel.text,self.introUrl] applicationActivities:@[[[UIActivity alloc] init]]];
    UIPopoverPresentationController *popover = activity.popoverPresentationController;
    if (popover) {
        popover.sourceView = self.scoreBgView.shareBtn;
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
    [self presentViewController:activity animated:YES completion:nil];
}

#pragma mark -MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.bigImageUrlArr.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.bigImageUrlArr.count) {
        return [self.bigImageUrlArr objectAtIndex:index];
    }
    return nil;
}

#pragma mark -跳转类别
- (IBAction)categoryBtnAction:(UIButton *)sender {
    if (self.bigImageUrlArr.count) {
        QJTagViewController *vc = [QJTagViewController new];
        vc.mainUrl = self.categoryUrl;
        vc.tagName = self.categoryName;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -跳转全部评论
- (void)pushAllCommentVC {
    if (self.bigImageUrlArr.count) {
        QJAllCommentViewController *vc = [QJAllCommentViewController new];
        vc.commentArr = self.allCommentArr;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -tag点击事件
- (void)didClickTagButtonWithModel:(QJCategoryButtonInfo *)model {
    if (self.bigImageUrlArr.count) {
        QJTagViewController *vc = [QJTagViewController new];
        vc.mainUrl = model.url;
        vc.tagName = model.name;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -collection协议
- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 10.f, 10.f, 10.f);
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    QJThumbImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    [cell refreshUI:self.datas[indexPath.item] row:indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.bigImageUrlArr.count >= indexPath.row) {
        [self.browser setCurrentPhotoIndex:indexPath.row];
        [self.navigationController pushViewController:self.browser animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -懒加载
- (NSDictionary *)colorDict {
    if (nil == _colorDict) {
        _colorDict = @{
                       @"DOUJINSHI":DOUJINSHI_COLOR,
                       @"MANGA":MANGA_COLOR,
                       @"ARTISTCG":ARTISTCG_COLOR,
                       @"GAMECG":GAMECG_COLOR,
                       @"WESTERN":WESTERN_COLOR,
                       @"NON-H":NONH_COLOR,
                       @"IMAGESET":IMAGESET_COLOR,
                       @"COSPLAY":COSPLAY_COLOR,
                       @"ASIAN PORN":ASIANPORN_COLOR,
                       @"MISC":MISC_COLOR
                       };
    }
    return _colorDict;
}

- (UICollectionView *)collectionView {
    if (nil == _collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        CGFloat itemWidth = (kScreenWidth - 10) / 3 - 10;
        CGFloat itemHeight = itemWidth * 190 / 120;
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [_collectionView registerNib:[UINib nibWithNibName:@"QJThumbImageCell" bundle:nil] forCellWithReuseIdentifier:@"item"];
    }
    return _collectionView;
}

- (MWPhotoBrowser *)browser {
    if (nil == _browser) {
        _browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        _browser.displayActionButton = NO;
        _browser.zoomPhotosToFill = NO;
        _browser.enableGrid = NO;
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height - 31, [UIScreen mainScreen].bounds.size.width - 40, 31)];
        slider.minimumTrackTintColor = [UIColor colorWithRed:0.082 green:0.584 blue:0.533 alpha:1.00];
        slider.maximumTrackTintColor = [UIColor whiteColor];
        slider.alpha = 1;
        [slider setThumbImage:[UIImage imageNamed:@"slider_small"] forState:UIControlStateNormal];
        [slider setThumbImage:[UIImage imageNamed:@"slider_normal"] forState:UIControlStateHighlighted];
        
        _browser.slider = slider;
    }
    return _browser;
}

- (NSArray *)datas {
    if (nil == _datas) {
        _datas = [NSArray new];
    }
    return _datas;
}

- (NSMutableArray *)bigImageUrlArr {
    if (nil == _bigImageUrlArr) {
        _bigImageUrlArr = [NSMutableArray new];
    }
    return _bigImageUrlArr;
}

- (NSMutableArray *)downImageUrlArr {
    if (nil == _downImageUrlArr) {
        _downImageUrlArr = [NSMutableArray new];
    }
    return _downImageUrlArr;
}

@end
