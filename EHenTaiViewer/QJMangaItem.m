//
//  QJMangaItem.m
//  testImageView
//
//  Created by QinJ on 2017/5/4.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJMangaItem.h"
#import "QJBigImageItem.h"
#import <WebKit/WebKit.h>
#import "NJKWebViewProgress.h"

@interface QJMangaItem ()<UIScrollViewDelegate,WKNavigationDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progress;
@property (nonatomic, strong) UITapGestureRecognizer *tapGes;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGes;
@property (nonatomic, strong) QJBigImageItem *item;

@end

@implementation QJMangaItem

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self customInit];
    }
    return self;
}

- (void)customInit {
    [self addSubview:self.webView];
    [self addSubview:self.progress];
    [self addSubview:self.activity];
}

- (void)refreshItem:(QJBigImageItem *)item {
    [self.activity startAnimating];
    self.item = item;
    if (item.realImageUrl) {
        [self.webView loadHTMLString:[self getHtmlWithUrl:item.realImageUrl x:item.x y:item.y] baseURL:nil];
    }
    else {
        [item getReallyImageUrl:^(NSString *url) {
            [self.webView loadHTMLString:[self getHtmlWithUrl:item.realImageUrl x:item.x y:item.y] baseURL:nil];
        }];
    }
}

#pragma mark -创建一个本地离线html
- (NSString *)getHtmlWithUrl:(NSString *)url x:(NSString *)x y:(NSString *)y {
    CGFloat bl = UIScreenWidth() / UIScreenHeight();
    CGFloat imgbl = [x floatValue] / [y floatValue];
    NSString *css = @"";
    if (bl > imgbl) {
        css = @"height:100%;";
    }
    else {
        css = @"width:100%;";
    }
    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html>\
                      <html>\
                      <head>\
                      <meta charset=\"utf-8\" />\
                      <title></title>\
                      <style>\
                      div {\
                        display: flex;\
                        justify-content: center;\
                      }\
                      img {\
                        %@\
                        position: absolute;\
                        left: 0;\
                        top: 0;\
                        right: 0;\
                        bottom: 0;\
                        margin: auto;\
                      }\
                      </style>\
                      </head>\
                      <body>\
                      <div>\
                      <img src=\"%@\" />\
                      </div>\
                      </body>\
                      </html>",css , url];
    return html;
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(changeWillBegin)]) {
        [self.delegate changeWillBegin];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(changeWillBegin)]) {
        [self.delegate changeWillBegin];
    }
}

#pragma mark -WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self.activity stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.activity stopAnimating];
}

#pragma mark -懒加载
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth(), UIScreenHeight() - 20)];
        _webView.scrollView.delegate = self;
        [_webView addGestureRecognizer:self.tapGes];
        [_webView addGestureRecognizer:self.longGes];
        
        //禁止长按弹出 UIMenuController 相关
        //禁止选择 css 配置相关
        NSString*css = @"body{-webkit-user-select:none;-webkit-user-drag:none;}";
        //css 选中样式取消
        NSMutableString *javascript = [NSMutableString string];
        [javascript appendString:@"var style = document.createElement('style');"];
        [javascript appendString:@"style.type = 'text/css';"];
        [javascript appendFormat:@"var cssContent = document.createTextNode('%@');", css];
        [javascript appendString:@"style.appendChild(cssContent);"];
        [javascript appendString:@"document.body.appendChild(style);"];
        [javascript appendString:@"document.documentElement.style.webkitUserSelect='none';"];//禁止选择
        [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
        //javascript 注入
        WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController *userContentController = [WKUserContentController new];
        [userContentController addUserScript:noneSelectScript];
        WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
        configuration.userContentController = userContentController;
        
        //控件加载
        [_webView.configuration.userContentController addUserScript:noneSelectScript];
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        
        _webView.navigationDelegate = self;
    }
    return _webView;
}

#pragma mark -进度条监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progress.progress = [change[@"new"] floatValue];
        self.progress.hidden = self.progress.progress >= 1;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (UIProgressView *)progress {
    if (!_progress) {
        _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth(), 2)];
        _progress.progress = 0;
        _progress.trackTintColor = [UIColor clearColor];
    }
    return _progress;
}

- (UITapGestureRecognizer *)tapGes {
    if (!_tapGes) {
        _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureAction:)];
        _tapGes.delegate = self;
    }
    return _tapGes;
}

- (UILongPressGestureRecognizer *)longGes {
    if (!_longGes) {
        _longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureAction:)];
        _longGes.delegate = self;
    }
    return _longGes;
}

#pragma mark -手势连续响应,wkwebview自带手势,需要执行这个
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)longPressGestureAction:(UILongPressGestureRecognizer *)longGres {
    if (longGres.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定刷新该图片?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancelBtn];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.webView loadHTMLString:[self getHtmlWithUrl:self.item.realImageUrl x:self.item.x y:self.item.y] baseURL:nil];
        }];
        [alertVC addAction:okBtn];
        [[self viewController] presentViewController:alertVC animated:YES completion:nil];
    }
}

- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)singleTapGestureAction:(UITapGestureRecognizer *)tapGes {
    CGPoint touchPoint = [tapGes locationInView:self];
    CGFloat width = UIScreenWidth() / 3.f;
    CGFloat height = UIScreenHeight() / 3.f;
    //中心区域
    CGRect midRect = CGRectMake(width, height, width, height);
    //上一页区域
    CGRect leftRect1 = CGRectMake(width, 0, width, height);
    CGRect leftRect2 = CGRectMake(0, 0, width, UIScreenHeight());
    //下一页的区域
    CGRect rightRect1 = CGRectMake(width, height * 2, width, height);
    CGRect rightRect2 = CGRectMake(width * 2, 0, width, UIScreenHeight());
    
    if (CGRectContainsPoint(midRect, touchPoint)) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tapInWebView)]) {
            [self.delegate tapInWebView];
        }
    }
    else if (CGRectContainsPoint(leftRect1, touchPoint) || CGRectContainsPoint(leftRect2, touchPoint)) {
        //上一页
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(forwardPage)]) {
            [self.delegate forwardPage];
        }
    }
    else if (CGRectContainsPoint(rightRect1, touchPoint) || CGRectContainsPoint(rightRect2, touchPoint)) {
        //下一页
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(nextPage)]) {
            [self.delegate nextPage];
        }
    }
}

#pragma mark -getter
- (UIActivityIndicatorView *)activity {
    if (nil == _activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(UIScreenWidth() / 2 - 10 , UIScreenHeight() / 2 - 10, 20, 20)];
        _activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _activity.hidesWhenStopped = YES;
    }
    return _activity;
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
