//
//  QJPasteManager.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/25.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJPasteManager.h"
#import "QJHenTaiParser.h"
#import "QJNewInfoViewController.h"
#import "QJTool.h"
#import "QJListItem.h"
#import "NSString+StringHeight.h"

@interface QJPasteManager ()

@property (strong, nonatomic) NSString *oldUrl; // 跳转成功后记录老url
@property (assign, nonatomic, getter=isSuccess) BOOL success; // 是否跳转画廊

@end

@implementation QJPasteManager

+ (instancetype)sharedInstance {
    static QJPasteManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [QJPasteManager new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.oldUrl = @"";
        self.success = NO;
    }
    return self;
}

- (void)checkInfoFromPasteBoard {
    NSString *string = [UIPasteboard generalPasteboard].string;
    // 解析数据
    NSArray *array = [string matchWithRegex:@"http.*?e[x-]hentai\\.org\\/g\\/.*?\\/.*?\\/"];
    if (array.count == 0) return;
    string = array.firstObject;
    // 先判断是否需要解析
    if ([self.oldUrl isEqualToString:string] && self.isSuccess) return;
    self.oldUrl = string;
    // 开始解析数据
    [[QJHenTaiParser parser] updateOneUrlInfoWithUrl:string complete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        if (listArray.count >= 1) {
            // 执行弹窗
            [self showSheetViewWithArray:listArray];
        }
    }];
}

- (void)showSheetViewWithArray:(NSArray *)lists {
    // 检测当前控制器不是看图浏览器页面
    QJListItem *model = lists.firstObject;
    
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (![vc isKindOfClass:NSClassFromString(@"QJNewBrowerViewController")]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"检测到剪切板存在画廊" message:[NSString stringWithFormat:@"%@", ([QJGlobalInfo isExHentaiTitleJnMode] && model.title_jpn.length) ? model.title_jpn : model.title] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"立马前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            self.success = YES;
            // 这里前往画廊
            QJNewInfoViewController *infoVC = [QJNewInfoViewController new];
            infoVC.model = model;
            [[QJTool visibleNavigationController] pushViewController:infoVC animated:YES];
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"暂不前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.success = NO;
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"该画廊不再提示" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            self.success = YES;
        }]];
        
        [vc presentViewController:alert animated:YES completion:nil];
    }
}

@end
