//
//  EntranceTableViewCell.m
//  TreeMall
//
//  Created by 黃思敬 on 2017/1/9.
//  Copyright © 2017年 Symphox. All rights reserved.
//

#import "EntranceTableViewCell.h"

@implementation EntranceTableViewCell

#pragma mark - Constructor

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Override

- (void)layoutSubviews
{
    [super layoutSubviews];
//    NSLog(@"EntranceTableViewCell[%4.2f,%4.2f]", self.frame.size.width, self.frame.size.height);
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.x = 0.0;
    imageFrame.origin.y = 0.0;
    imageFrame.size.width = self.contentView.frame.size.width;
    imageFrame.size.height = self.contentView.frame.size.height;
    self.imageView.frame = imageFrame;
}

#pragma mark - Actions

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
