//
//  QJNewBrowerImageCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2018/4/6.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "QJNewBrowerImageCell.h"
#import "QJMangaImageModel.h"

@interface QJNewBrowerImageCell ()<UIScrollViewDelegate, QJMangaImageModelDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YYAnimatedImageView *mangaImageView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation QJNewBrowerImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addSubview:self.scrollView];
}

// 感谢KNPhotoBrowerImageView
- (void)reloadFrames {
    CGRect frame = self.frame;
    // 设置 scrollView的 原始缩放大小
    _scrollView.zoomScale = 1.0f;
    if(_mangaImageView.image){
        // 设置 imageView 的 frame
        [_mangaImageView setFrame:(CGRect){CGPointZero,_model.size}];
        
        // scrollView 的滚动区域
        _scrollView.contentSize = _mangaImageView.frame.size;
        
        // 将 scrollView.contentSize 赋值为 图片的大小. 再获取 图片的中心点
        _mangaImageView.center = [self centerOfScrollViewContent:_scrollView];
        
        // 获取 ScrollView 高 和 图片 高 的 比率
        CGFloat maxScale = frame.size.height / _model.size.height;
        // 获取 宽度的比率
        CGFloat widthRadit = frame.size.width / _model.size.width;
        
        // 取出 最大的 比率
        maxScale = widthRadit > maxScale?widthRadit:maxScale;
        // 如果 最大比率 >= PhotoBrowerImageMaxScale 倍 , 则取 最大比率 ,否则去 PhotoBrowerImageMaxScale 倍
        maxScale = maxScale > 2.f ? maxScale : 2.f;
        
        // 设置 scrollView的 最大 和 最小 缩放比率
        _scrollView.minimumZoomScale = 1.f;
        _scrollView.maximumZoomScale = maxScale;
        
    }else{
        frame.origin = CGPointZero;
        _mangaImageView.frame = frame;
        _scrollView.contentSize = _mangaImageView.frame.size;
    }
    _scrollView.contentOffset = CGPointZero;
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView{
    // scrollView.bounds.size.width > scrollView.contentSize.width : 说明:scrollView 大小 > 图片 大小
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

- (void)setModel:(QJMangaImageModel *)model {
    _model = model;
    
    _model.delegate = self;
    if ([_model hasImage]) {
        [self hiddenTip];
        self.mangaImageView.image = [YYImage imageWithContentsOfFile:_model.imagePath]; //[UIImage imageWithContentsOfFile:_model.imagePath];
    } else if (_model.rate > 0) {
        [self showTip];
        self.tipLabel.text = [NSString stringWithFormat:@"%2.0f%%", model.rate];
        self.mangaImageView.image = nil;
    } else {
        [self showTip];
        self.mangaImageView.image = nil;
    }
    
    _scrollView.frame = self.bounds;
    [self reloadFrames];
}

- (void)showTip {
    self.bgView.hidden = NO;
    self.activity.hidden = NO;
    [self.activity startAnimating];
    self.tipLabel.text = @"图片获取中";
}

- (void)hiddenTip {
    self.bgView.hidden = YES;
    self.activity.hidden = YES;
    [self.activity stopAnimating];
    self.tipLabel.text = @"";
}

#pragma mark - QJMangaImageModelDelegate
- (void)imageDidChangeRateWithModel:(QJMangaImageModel *)model {
    self.tipLabel.text = [NSString stringWithFormat:@"%2.0f%%", model.rate];
}

- (void)imageDidDownloadFinshWithModel:(QJMangaImageModel *)model {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewShouldRefreshWithModel:)]) {
            [self.delegate collectionViewShouldRefreshWithModel:model];
        }
    });
}

- (void)imageDidDownloadFailWithModel:(QJMangaImageModel *)model {
    self.bgView.hidden = NO;
    self.activity.hidden = YES;
    [self.activity stopAnimating];
    self.tipLabel.text = @"图片获取失败！";
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewInCellWillBeginDragging)]) {
        [self.delegate scrollViewInCellWillBeginDragging];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mangaImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 调整imageView的frame
    CGRect frame = self.mangaImageView.frame;
    frame.origin.y = (self.scrollView.frame.size.height - self.mangaImageView.frame.size.height) > 0 ? (self.scrollView.frame.size.height - self.mangaImageView.frame.size.height) * 0.5 : 0;
    frame.origin.x = (self.scrollView.frame.size.width - self.mangaImageView.frame.size.width) > 0 ? (self.scrollView.frame.size.width - self.mangaImageView.frame.size.width) * 0.5 : 0;
    self.mangaImageView.frame = frame;
    
    self.scrollView.contentSize = CGSizeMake(self.mangaImageView.frame.size.width, self.mangaImageView.frame.size.height);
}

#pragma mark -getter
- (UIScrollView *)scrollView {
    if (nil == _scrollView) {
        _scrollView = [UIScrollView new];
        // 这里需要适配一下iOS11以上的版本
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        // 设置缩放比例
        _scrollView.minimumZoomScale = 1.f;
        _scrollView.maximumZoomScale = 5.f;
        // 设置代理者
        _scrollView.delegate = self;
        // 加入imageView
        [_scrollView addSubview:self.mangaImageView];
    }
    return _scrollView;
}

- (YYAnimatedImageView *)mangaImageView {
    if (nil == _mangaImageView) {
        _mangaImageView = [YYAnimatedImageView new];
        //_mangaImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _mangaImageView;
}

@end
