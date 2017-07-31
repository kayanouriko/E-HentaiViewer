//
//  QJSearchTagCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSearchTagCell.h"
#import "Tag+CoreDataClass.h"
#import "NSString+StringHeight.h"

@interface QJSearchTagCell ()

@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagcnLabel;

@end

@implementation QJSearchTagCell

- (void)refreshUI:(Tag *)tag searchKey:(NSString *)searchKey {
    if ([tag.name containsString:searchKey]) {
        NSRange rage = [tag.name rangeOfString:searchKey];
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc]initWithString:tag.name];
        [attri addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:rage];
        self.tagLabel.attributedText = attri;
    } else {
        self.tagLabel.text = tag.name;
    }
    
    NSString *cname = [tag.cname removeHtmlString];
    if ([cname containsString:searchKey]) {
        NSRange rage = [cname rangeOfString:searchKey];
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc]initWithString:cname];
        [attri addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:rage];
        self.tagcnLabel.attributedText = attri;
    } else {
        self.tagcnLabel.text = cname;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
