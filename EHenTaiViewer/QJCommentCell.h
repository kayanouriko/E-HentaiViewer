//
//  QJCommentCell.h
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/31.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJTableViewCell.h"

@class QJCommentCell;

@protocol QJCommentCellDelegate <NSObject>

@optional
// 点击了用户的名字
- (void)commentCell:(QJCommentCell *)cell didClickUserImageWithUserName:(NSString *)userName;
// 点击了评论内容的url
- (void)commentCell:(QJCommentCell *)cell didClickContentUrlWithURL:(NSURL *)URL;

@end

@interface QJCommentCell : QJTableViewCell

@property (weak, nonatomic) id<QJCommentCellDelegate>delegate;

- (void)refreshUI:(NSDictionary *)dict;

@end
