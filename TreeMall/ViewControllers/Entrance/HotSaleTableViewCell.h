//
//  HotSaleTableViewCell.h
//  TreeMall
//
//  Created by 黃思敬 on 2017/4/28.
//  Copyright © 2017年 Symphox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HotSaleTableViewCell;

@protocol HotSaleTableViewCellDelegate <NSObject>

- (void)hotSaleTableViewCell:(HotSaleTableViewCell *)cell didPressAddToCartBySender:(id)sender;
- (void)hotSaleTableViewCell:(HotSaleTableViewCell *)cell didPressFavoriteBySender:(id)sender;

@end

static NSString *HotSaleTableViewCellIdentifier = @"HotSaleTableViewCell";

@interface HotSaleTableViewCell : UITableViewCell

@property (nonatomic, weak) id <HotSaleTableViewCellDelegate> delegate;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIImageView *imageViewProduct;
@property (nonatomic, strong) UIImageView *imageViewTag;
@property (nonatomic, strong) UILabel *labelTag;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UILabel *labelPrice;
@property (nonatomic, strong) UILabel *labelSeparator;
@property (nonatomic, strong) UILabel *labelPoint;
@property (nonatomic, strong) UIButton *buttonAddToCart;
@property (nonatomic, strong) UIButton *buttonFavorite;

@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *point;
@property (nonatomic, assign) BOOL favorite;

@end
