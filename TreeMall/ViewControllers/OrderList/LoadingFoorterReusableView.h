//
//  LoadingFoorterReusableView.h
//  TreeMall
//
//  Created by 黃思敬 on 2017/3/10.
//  Copyright © 2017年 Symphox. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *LoadingFoorterReusableViewIdentifier = @"LoadingFoorterReusableView";

@interface LoadingFoorterReusableView : UICollectionReusableView

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end
