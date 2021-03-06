//
//  ImageTextView.h
//  TreeMall
//
//  Created by 黃思敬 on 2017/2/21.
//  Copyright © 2017年 Symphox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTextView : UIView

@property (nonatomic, strong) UIImageView *imageViewIcon;
@property (nonatomic, strong) UILabel *labelText;

- (CGSize)referenceSizeForViewWidth:(CGFloat)viewWidth;

@end
