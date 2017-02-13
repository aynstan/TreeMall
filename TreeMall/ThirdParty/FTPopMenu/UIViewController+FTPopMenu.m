//
//  UIViewController+FTPopMenu.m
//  FTPopMenu
//
//  Created by liufengting https://github.com/liufengting on 16/6/2.
//  Copyright © 2016年 liufengting. All rights reserved.
//

#import "UIViewController+FTPopMenu.h"
#import "FTPopTableViewController.h"

@implementation UIViewController (FTPopMenu)

/**
 *  From any UIView
 */
-(void)showFTMenuFromView:(UIView *)sender
                menuArray:(NSArray<NSString *> *)menuArray
                     doneBlock:(void(^)(NSInteger selectedIndex))doneBlock
                   cancelBlock:(void(^)())cancelBlock
{
        [self showFromBarButtonItem:nil
                         senderView:sender
                              title:nil
                          tintColor:nil
                          textColor:nil
                      perferedWidth:0
                          rowHeight:0
                          menuArray:menuArray
                 menuImageNameArray:nil
                               doneBlock:doneBlock
                             cancelBlock:cancelBlock];
}

-(void)showFTMenuFromView:(UIView *)sender
                    title:(NSString *)title
                menuArray:(NSArray<NSString *> *)menuArray
                     doneBlock:(void(^)(NSInteger selectedIndex))doneBlock
                   cancelBlock:(void(^)())cancelBlock
{
    [self showFromBarButtonItem:nil
                     senderView:sender
                          title:title
                      tintColor:nil
                      textColor:nil
                  perferedWidth:0
                      rowHeight:0
                      menuArray:menuArray
             menuImageNameArray:nil
                           doneBlock:doneBlock
                         cancelBlock:cancelBlock];
}

- (void)showFTMenuFromView:(UIView *)sender
                     title:(NSString *)title
                 textColor:(UIColor *)textColor
             perferedWidth:(CGFloat )perferedWidth
                   menuKey:(NSString *)key
     inDictionaryFromArray:(NSArray<NSString *> *)menuArray
                 doneBlock:(void (^)(NSInteger))doneBlock
               cancelBlock:(void (^)())cancelBlock
{
    NSMutableArray *menuNameArray = [NSMutableArray array];
    for (NSDictionary *dictionary in menuArray)
    {
        NSString *menuTitle = [dictionary objectForKey:key];
        if (menuTitle == nil)
        {
            menuTitle = @"";
        }
        [menuNameArray addObject:menuTitle];
    }
    [self showFromBarButtonItem:nil
                     senderView:sender
                          title:title
                      tintColor:nil
                      textColor:textColor
                  perferedWidth:perferedWidth
                      rowHeight:0
                      menuArray:menuNameArray
             menuImageNameArray:nil
                      doneBlock:doneBlock
                    cancelBlock:cancelBlock];
}

-(void)showFTMenuFromView:(UIView *)sender
                    title:(NSString *)title
                menuArray:(NSArray<NSString *> *)menuArray
       menuImageNameArray:(NSArray<NSString *> *)menuImageNameArray
                     doneBlock:(void(^)(NSInteger selectedIndex))doneBlock
                   cancelBlock:(void(^)())cancelBlock
{
    [self showFromBarButtonItem:nil
                     senderView:sender
                          title:title
                      tintColor:nil
                      textColor:nil
                  perferedWidth:0
                      rowHeight:0
                      menuArray:menuArray
             menuImageNameArray:menuImageNameArray
                           doneBlock:doneBlock
                         cancelBlock:cancelBlock];
}

-(void)showFTMenuFromView:(UIView *)sender
                    title:(NSString *)title
                menuArray:(NSArray<NSString *> *)menuArray
       menuImageNameArray:(NSArray<NSString *> *)menuImageNameArray
            perferedWidth:(CGFloat )perferedWidth
                rowHeight:(CGFloat )rowHeight
                tintColor:(UIColor *)tintColor
                     doneBlock:(void(^)(NSInteger selectedIndex))doneBlock
                   cancelBlock:(void(^)())cancelBlock
{
    [self showFromBarButtonItem:nil
                     senderView:sender
                          title:title
                      tintColor:tintColor
                      textColor:nil
                  perferedWidth:perferedWidth
                      rowHeight:rowHeight
                      menuArray:menuArray
             menuImageNameArray:menuImageNameArray
                           doneBlock:doneBlock
                         cancelBlock:cancelBlock];
}
/**
 *  From any UIBarButtonItem
 */
-(void)showFTMenuFromBarButtonItem:(UIBarButtonItem *)barButtonItem
                         menuArray:(NSArray<NSString *> *)menuArray
                              doneBlock:(void(^)(NSInteger selectedIndex))doneBlock
                            cancelBlock:(void(^)())cancelBlock
{
    [self showFromBarButtonItem:barButtonItem
                     senderView:nil
                          title:nil
                      tintColor:nil
                      textColor:nil
                  perferedWidth:0
                      rowHeight:0
                      menuArray:menuArray
             menuImageNameArray:nil
                           doneBlock:doneBlock
                         cancelBlock:cancelBlock];
}

-(void)showFTMenuFromBarButtonItem:(UIBarButtonItem *)barButtonItem
                             title:(NSString *)title
                         menuArray:(NSArray<NSString *> *)menuArray
                              doneBlock:(void(^)(NSInteger selectedIndex))doneBlock
                            cancelBlock:(void(^)())cancelBlock
{
    [self showFromBarButtonItem:barButtonItem
                     senderView:nil
                          title:title
                      tintColor:nil
                      textColor:nil
                  perferedWidth:0
                      rowHeight:0
                      menuArray:menuArray
             menuImageNameArray:nil
                           doneBlock:doneBlock
                         cancelBlock:cancelBlock];
}

-(void)showFTMenuFromBarButtonItem:(UIBarButtonItem *)barButtonItem
                             title:(NSString *)title
                         menuArray:(NSArray<NSString *> *)menuArray
                menuImageNameArray:(NSArray<NSString *> *)menuImageNameArray
                              doneBlock:(void(^)(NSInteger selectedIndex))doneBlock
                            cancelBlock:(void(^)())cancelBlock
{
    [self showFromBarButtonItem:barButtonItem
                     senderView:nil
                          title:title
                      tintColor:nil
                      textColor:nil
                  perferedWidth:0
                      rowHeight:0
                      menuArray:menuArray
             menuImageNameArray:menuImageNameArray
                           doneBlock:doneBlock
                         cancelBlock:cancelBlock];
}


-(void)showFTMenuFromBarButtonItem:(UIBarButtonItem *)barButtonItem
                             title:(NSString *)title
                         menuArray:(NSArray<NSString *> *)menuArray
                menuImageNameArray:(NSArray<NSString *> *)menuImageNameArray
                     perferedWidth:(CGFloat )perferedWidth
                         rowHeight:(CGFloat )rowHeight
                         tintColor:(UIColor *)tintColor
                              doneBlock:(void(^)(NSInteger selectedIndex))doneBlock
                            cancelBlock:(void(^)())cancelBlock
{
    [self showFromBarButtonItem:barButtonItem
                     senderView:nil
                          title:title
                      tintColor:tintColor
                      textColor:nil
                  perferedWidth:perferedWidth
                      rowHeight:rowHeight
                      menuArray:menuArray
             menuImageNameArray:menuImageNameArray
                           doneBlock:doneBlock
                         cancelBlock:cancelBlock];
}


#pragma mark - Total methods

-(void)showFromBarButtonItem:(UIBarButtonItem *)barButtonItem
                  senderView:(UIView *)sender
                       title:(NSString *)title
                   tintColor:(UIColor *)tintColor
                   textColor:(UIColor *)textColor
               perferedWidth:(CGFloat )perferedWidth
                   rowHeight:(CGFloat )rowHeight
                   menuArray:(NSArray<NSString *> *)menuArray
          menuImageNameArray:(NSArray<NSString *> *)menuImageNameArray
                        doneBlock:(void(^)(NSInteger selectedIndex))doneBlock
                      cancelBlock:(void(^)())cancelBlock
{
    FTPopTableViewController *pop = [[FTPopTableViewController alloc] init];
    pop.barButtonItem = barButtonItem;
    pop.sourceView = sender;
    pop.titleString = title;
    pop.rowHeight = rowHeight;
    pop.perferdWidth = perferedWidth;
    pop.tintColor = tintColor;
    pop.textColor = textColor;
    pop.menuStringArray = menuArray;
    pop.menuImageNameArray = menuImageNameArray;
    pop.doneBlock = doneBlock;
    pop.cancelBlock = cancelBlock;
    [self presentViewController:pop animated:YES completion:^{
        
    }];
}


@end
 
