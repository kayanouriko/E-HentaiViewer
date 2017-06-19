//
//  QJTorrentInfoCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/9.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJTorrentInfoCell.h"
#import "QJTorrentItem.h"

@interface QJTorrentInfoCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *postedLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *seedsLabel;
@property (weak, nonatomic) IBOutlet UILabel *peersLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadsLabel;

@end

@implementation QJTorrentInfoCell

- (void)refreshUI:(QJTorrentItem *)item {
    self.nameLabel.text = item.name;
    self.uploaderLabel.text = item.uploader;
    self.postedLabel.text = item.posted;
    self.sizeLabel.text = item.size;
    self.seedsLabel.text = item.seeds;
    self.peersLabel.text = item.peers;
    self.downloadsLabel.text = item.downloads;
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
