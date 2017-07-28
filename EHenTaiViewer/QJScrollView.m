//
//  QJScrollView.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/28.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJScrollView.h"

@interface QJScrollView ()<UIGestureRecognizerDelegate>

@end

@implementation QJScrollView

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if(gestureRecognizer.state != 0) {
        return YES;
    }else {
        return NO;
    }
}

@end
