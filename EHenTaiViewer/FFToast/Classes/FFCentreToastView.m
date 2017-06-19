//
//  FFCentreToastView.m
//  FFToastDemo
//
//  Created by 李峰峰 on 2017/2/24.
//  Copyright © 2017年 李峰峰. All rights reserved.
//

#import "FFCentreToastView.h"
#import "NSString+FFToast.h"
#import "UIImage+FFToast.h"

#define HORIZONTAL_SPACE_TO_SCREEN 100.f
#define HORIZONTAL_SPACE_TO_TOASTVIEW 10.f
#define TOP_SPACE_TO_TOASTVIEW 10.f
#define ICON_IMG_SIZE CGSizeMake(35.f, 35.f)
#define DISMISS_BTN_IMG_SIZE CGSizeMake(20.f, 20.f)

@interface FFCentreToastView()

//Toast图标ImageView
@property(strong,nonatomic)UIImageView *iconImageView;
//Toast标题Label
@property(strong,nonatomic)UILabel *titleLabel;
//Toast内容Label
@property(strong,nonatomic)UILabel *messageLabel;
//关闭按钮
@property(strong,nonatomic)UIButton *dismissBtn;

@property (nonatomic, copy) NSString* titleString;
@property (nonatomic, copy) NSString* messageString;
@property (strong, nonatomic) UIImage* iconImage;

@property (assign, nonatomic) CGSize titleLabelSize;
@property (assign, nonatomic) CGSize messageLabelSize;
@property (assign, nonatomic) CGSize iconImageSize;
@property (assign, nonatomic) CGRect toastViewFrame;

//是否是自定义的View
@property (assign, nonatomic) BOOL isCustomToastView;
//真正展示内容的View
@property(strong,nonatomic)UIView *toastView;

@property handler handler;


@end


@implementation FFCentreToastView

static NSMutableArray* toastArray = nil;


- (instancetype)initToastWithTitle:(NSString *)title message:(NSString *)message iconImage:(UIImage*)iconImage{
    if (!toastArray) {
        toastArray = [NSMutableArray new];
    }
    
    self.isCustomToastView = NO;
    self.titleString = title;
    self.messageString = message;
    self.iconImage = iconImage;
    
    return [self init];
}

-(instancetype)initCentreToastWithView:(UIView *)customToastView{
    
    if (!toastArray) {
        toastArray = [NSMutableArray new];
    }
    
    self.isCustomToastView = YES;
    
    self.toastView = [[UIView alloc]init];
    self.toastView = customToastView;
    
    return [self init];
}


-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        if(_isCustomToastView == NO){
            
            self.toastView = [[UIView alloc]init];
            
            self.iconImageView = [[UIImageView alloc]init];
            [self.toastView addSubview:self.iconImageView];
            
            self.titleLabel = [[UILabel alloc]init];
            self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            self.titleLabel.textAlignment = NSTextAlignmentLeft;
            self.titleLabel.numberOfLines = 0;
            [self.toastView addSubview:self.titleLabel];
            
            self.messageLabel = [[UILabel alloc]init];
            self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
            self.messageLabel.textAlignment = NSTextAlignmentLeft;
            self.messageLabel.numberOfLines = 0;
            [self.toastView addSubview:self.messageLabel];
            
            [self addSubview:self.toastView];
        
        }else{
            
             [self addSubview:self.toastView];
            
        }
        self.dismissBtn = [[UIButton alloc]init];
        [self addSubview:self.dismissBtn];
        

    }
    
    return self;
}


/**
 设置Toast的frame、属性及内部控件的属性等
 */
-(void)layoutToastView{
    
    if(_isCustomToastView == NO){
        
        //设置子控件属性
        self.titleLabel.textColor = _titleTextColor;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = _titleFont;
        
        self.messageLabel.textColor = _messageTextColor;
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.font = _messageFont;
        
        self.toastView.alpha = _toastAlpha;
        self.toastView.layer.cornerRadius = _toastCornerRadius;
        self.toastView.layer.masksToBounds = YES;
        
        if (_dismissBtnImage != nil) {
            self.dismissBtn.imageView.image = self.dismissBtnImage;
        }
        
        //根据toastType设置icon
        switch (self.toastType) {
            case FFToastTypeDefault: {
                self.toastBackgroundColor = [UIColor whiteColor];
                break;
            }
            case FFToastTypeSuccess: {
                if (!_iconImage) {
                    self.iconImage = [UIImage imageWithName:@"fftoast_success_highlight"];
                }
                break;
            }
            case FFToastTypeError: {
                if (!_iconImage) {
                    self.iconImage = [UIImage imageWithName:@"fftoast_error_highlight"];
                }
                break;
            }
            case FFToastTypeWarning: {
                if (!_iconImage) {
                    self.iconImage = [UIImage imageWithName:@"fftoast_warning_highlight"];
                }
                break;
            }
            case FFToastTypeInfo: {
                
                if (!_iconImage) {
                    self.iconImage = [UIImage imageWithName:@"fftoast_info_highlight"];
                }
                break;
            }
                
            default:
                break;
        }

        
        self.iconImageSize = self.iconImage == nil ? CGSizeZero : ICON_IMG_SIZE;
        
    }
    
    self.toastViewFrame = [self toastViewFrame];
    
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    //设置动画起始Frame
    CGFloat toastViewW = _toastViewFrame.size.width/2;
    CGFloat toastViewH = _toastViewFrame.size.height/2;
    CGFloat toastViewX = (self.frame.size.width - toastViewW)/2;
    CGFloat toastViewY = (self.frame.size.height - toastViewH)/2;
    self.toastView.frame = CGRectMake(toastViewX, toastViewY, toastViewW, toastViewH);
    
    CGFloat dismissBtnW = DISMISS_BTN_IMG_SIZE.width;
    CGFloat dismissBtnH = DISMISS_BTN_IMG_SIZE.height;
    CGFloat dismissBtnX = toastViewX + toastViewW - dismissBtnW/2;
    CGFloat dismissBtnY = toastViewY - dismissBtnH/2;
    self.dismissBtn.frame = CGRectMake(dismissBtnX, dismissBtnY, dismissBtnW, dismissBtnH);
    
    switch (self.toastPosition) {
        case FFToastPositionCentre: {
            self.toastView.layer.cornerRadius = _toastCornerRadius;
            self.toastView.layer.masksToBounds = YES;
            break;
        }
        case FFToastPositionCentreWithFillet: {

            if (self.toastCornerRadius == 0) {
                self.toastCornerRadius = 5.f;
            }
            self.toastView.layer.cornerRadius = _toastCornerRadius;
            self.toastView.layer.masksToBounds = YES;

            break;
        }

        default:
            break;
    }
    
    if (_toastBackgroundColor != nil) {
        self.toastView.backgroundColor = _toastBackgroundColor;
    }
    self.toastView.alpha = 0.f;
    self.alpha = 0.f;
    self.dismissBtn.alpha = 0.f;

}

/**
 计算ToastView的frame
 
 @return ToastView的frame
 */
-(CGRect)toastViewFrame{
    
    CGFloat toastViewW = 0;
    CGFloat toastViewH = 0;
    CGFloat toastViewX = 0;
    CGFloat toastViewY = 0;
    
    if(_isCustomToastView == NO){
        
        toastViewW = SCREEN_WIDTH - 2 * HORIZONTAL_SPACE_TO_SCREEN;
        toastViewX = (SCREEN_WIDTH - toastViewW)/2;
        
        CGFloat textMaxWidth = SCREEN_WIDTH - 2 * (HORIZONTAL_SPACE_TO_SCREEN + HORIZONTAL_SPACE_TO_TOASTVIEW);

        self.titleLabelSize = [NSString sizeForString:_titleString font:_titleFont maxWidth:textMaxWidth];
        self.messageLabelSize = [NSString sizeForString:_messageString font:_messageFont maxWidth:textMaxWidth];
        
        if (_iconImage != nil) {
            //有图标
            toastViewH = _iconImageSize.height + _titleLabelSize.height + _messageLabelSize.height + 4 * TOP_SPACE_TO_TOASTVIEW;
        }else{
            //没有图标
            toastViewH = _titleLabelSize.height + _messageLabelSize.height + 3 * TOP_SPACE_TO_TOASTVIEW;
        }
        
        toastViewY = (SCREEN_HEIGHT - toastViewH)/2;
        
    }else{
        toastViewW = _toastView.frame.size.width;
        toastViewH = _toastView.frame.size.height;
        toastViewX = (SCREEN_WIDTH - toastViewW)/2;
        toastViewY = (SCREEN_HEIGHT - toastViewH)/2;
    }
    
    return CGRectMake(toastViewX, toastViewY, toastViewW, toastViewH);
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if(_isCustomToastView == NO){
    
        CGFloat iconImageViewX = (_toastViewFrame.size.width - _iconImageSize.width)/2;
        CGFloat iconImageViewY = TOP_SPACE_TO_TOASTVIEW;
        CGFloat iconImageViewW = ICON_IMG_SIZE.width;
        CGFloat iconImageViewH = ICON_IMG_SIZE.height;
        self.iconImageView.frame = CGRectMake(iconImageViewX, iconImageViewY, iconImageViewW, iconImageViewH);
        
        CGFloat titleLabelW = _titleLabelSize.width;
        CGFloat titleLabelH = _titleLabelSize.height;
        CGFloat titleLabelX = (_toastViewFrame.size.width - titleLabelW)/2;
        CGFloat titleLabelY = _iconImage == nil ? TOP_SPACE_TO_TOASTVIEW : iconImageViewY + iconImageViewH +TOP_SPACE_TO_TOASTVIEW ;
        self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
        
        CGFloat messageLabelW = _messageLabelSize.width;
        CGFloat messageLabelH = _messageLabelSize.height;
        CGFloat messageLabelX = (_toastViewFrame.size.width - messageLabelW)/2;
        CGFloat messageLabelY = _titleString == nil ? titleLabelY : titleLabelY + titleLabelH + TOP_SPACE_TO_TOASTVIEW;
        self.messageLabel.frame = CGRectMake(messageLabelX, messageLabelY, messageLabelW, messageLabelH);
        
    
        [self loadViewData];
    }
    
    if(_enableDismissBtn == YES){
        if (_dismissBtnImage != nil) {
            [self.dismissBtn setImage:_dismissBtnImage forState:UIControlStateNormal];
        }else{
            [self.dismissBtn setImage:[UIImage imageWithName:@"fftoast_dismiss"] forState:UIControlStateNormal];
        }
        [self.dismissBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }else{
        self.dismissBtn.hidden = YES;
    }

    
}


/**
 加载各View数据
 */
-(void)loadViewData{
    
    self.iconImageView.image = self.iconImage;
    self.titleLabel.text = self.titleString;
    self.messageLabel.text = self.messageString;

    
}





/**
 显示一个Toast
 */
- (void)show{
    
    [self layoutToastView];
    
    //显示之前先把之前的移除
    if ([toastArray count] != 0) {
        [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:YES];
    }
    
    @synchronized (toastArray) {
        
        UIWindow *windowView = [UIApplication sharedApplication].keyWindow;
        [windowView addSubview:self];
        
        [UIView animateWithDuration:0.5f
                              delay:0.f
             usingSpringWithDamping:0.7f
              initialSpringVelocity:0.5f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{

                             self.toastView.frame = _toastViewFrame;
                             self.toastView.alpha = _toastAlpha;
                             
                             CGFloat dismissBtnW = DISMISS_BTN_IMG_SIZE.width;
                             CGFloat dismissBtnH = DISMISS_BTN_IMG_SIZE.height;
                             CGFloat dismissBtnX = _toastViewFrame.origin.x + _toastViewFrame.size.width - dismissBtnW/2;
                             CGFloat dismissBtnY = _toastViewFrame.origin.y - dismissBtnH/2;
                             self.dismissBtn.frame = CGRectMake(dismissBtnX, dismissBtnY, dismissBtnW, dismissBtnH);

                             
                             self.alpha = 1.f;
                             self.dismissBtn.alpha = 1.f;
                             self.backgroundColor = [UIColor colorWithRed:104/255.0 green:104/255.0 blue:104/255.0 alpha:0.3];
                             
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
        [toastArray addObject:self];
        
        if(_autoDismiss == YES){
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:_duration];
        }
        
    }
    

}



/**
 隐藏一个Toast
 */
-(void)dismiss{
    
    if (toastArray && [toastArray count] > 0) {
        @synchronized (toastArray) {
            
            FFCentreToastView* toast = toastArray[0];
            [NSRunLoop cancelPreviousPerformRequestsWithTarget:toast];
            [toastArray removeObject:toast];
            
            if (self.dismissToastAnimated == YES) {
                
                [UIView animateWithDuration:0.2f
                                 animations:^{

                                     CGFloat toastViewW = _toastViewFrame.size.width/2;
                                     CGFloat toastViewH = _toastViewFrame.size.height/2;
                                     CGFloat toastViewX = (self.frame.size.width - toastViewW)/2;
                                     CGFloat toastViewY = (self.frame.size.height - toastViewH)/2;
                                     self.toastView.frame = CGRectMake(toastViewX, toastViewY, toastViewW, toastViewH);
                                     
                                     CGFloat dismissBtnW = DISMISS_BTN_IMG_SIZE.width;
                                     CGFloat dismissBtnH = DISMISS_BTN_IMG_SIZE.height;
                                     CGFloat dismissBtnX = toastViewX + toastViewW - dismissBtnW/2;
                                     CGFloat dismissBtnY = toastViewY - dismissBtnH/2;
                                     self.dismissBtn.frame = CGRectMake(dismissBtnX, dismissBtnY, dismissBtnW, dismissBtnH);
                                     
                                     self.toastView.alpha = 0.f;
                                     self.alpha = 0.f;

                                 } completion:^(BOOL finished) {
                                     [toast removeFromSuperview];
                                 }];
                
                
            }else{
                [UIView animateWithDuration:0.f
                                 animations:^{

                                     self.toastView.alpha = 0.f;
                                     self.alpha = 0.f;

                                 } completion:^(BOOL finished) {
                                     [toast removeFromSuperview];
                                 }];
                
            }
            
        }
    }
    
    
}

@end
