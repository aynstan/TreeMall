//
//  ReceiverInfoViewController.m
//  TreeMall
//
//  Created by 黃思敬 on 2017/5/1.
//  Copyright © 2017年 Symphox. All rights reserved.
//

#import "ReceiverInfoViewController.h"
#import "LocalizedString.h"
#import "APIDefinition.h"
#import "SHAPIAdapter.h"
#import "CryptoModule.h"
#import "TMInfoManager.h"
#import "Utility.h"
#import "InvoiceDescriptionFooterView.h"
#import "SampleImageViewController.h"

static NSString *DTAttributedTextCellIdentifier = @"DTAttributedTextCell";

typedef enum : NSUInteger {
    SectionIndexInfo,
    SectionIndexDelivery,
    SectionIndexTotal
} SectionIndex;

typedef enum : NSUInteger {
    InfoCellTagReceiverName,
    InfoCellTagCellPhone,
    InfoCellTagDayPhone,
    InfoCellTagNightPhone,
    InfoCellTagTotal
} InfoCellTag;

typedef enum : NSUInteger {
    DeliveryCellTagCity,
    DeliveryCellTagRegion,
    DeliveryCellTagAddress,
    DeliveryCellTagDeliverTime,
    DeliveryCellTagNote,
    DeliveryCellTagTotal
} DeliveryCellTag;

typedef enum : NSUInteger {
    DeliverTimeOption9_12,
    DeliverTimeOption12_17,
    DeliverTimeOption17_20,
    DeliverTimeOptionNoSpecific,
    DeliverTimeOptionTotal
} DeliverTimeOption;

typedef enum : NSUInteger {
    InvoiceLayoutTypeDefault,
    InvoiceLayoutTypeElectronicMember,
    InvoiceLayoutTypeElectronicExtraCode,
    InvoiceLayoutTypeDonate,
    InvoiceLayoutTypeDonateSpecificGroup,
    InvoiceLayoutTypeTriplicate,
    InvoiceLayoutTypeTotal
} InvoiceLayoutType;

typedef enum : NSUInteger {
    InvoiceCellTagChooseType,
    InvoiceCellTagChooseElectronicType,
    InvoiceCellTagChooseDonateTarget,
    InvoiceCellTagElectronicCode,
    InvoiceCellTagDonateCode,
    InvoiceCellTagInvoiceTitle,
    InvoiceCellTagInvoiceIdentifier,
    InvoiceCellTagReceiver,
    InvoiceCellTagCity,
    InvoiceCellTagRegion,
    InvoiceCellTagAddress,
    InvoiceCellTagInvoiceDesc,
    InvoiceCellTagUnknown,
    InvoiceCellTagTotal
} InvoiceCellTag;

typedef enum : NSUInteger {
    InvoiceTypeOptionElectronic,
    InvoiceTypeOptionDonate,
    InvoiceTypeOptionTriplicate,
    InvoiceTypeOptionTotal
} InvoiceTypeOption;

typedef enum : NSUInteger {
    InvoiceElectronicSubTypeMember,
    InvoiceElectronicSubTypeNaturalPerson,
    InvoiceElectronicSubTypeCellphoneBarcode,
    InvoiceElectronicSubTypeTotal
} InvoiceElectronicSubType;

typedef enum : NSUInteger {
    InvoiceDonateTarget1,
    InvoiceDonateTarget2,
    InvoiceDonateTarget3,
    InvoiceDonateTargetOther,
    InvoiceDonateTargetTotal
} InvoiceDonateTarget;

@interface ReceiverInfoViewController ()

@property (nonatomic, assign) InvoiceLayoutType invoiceLayoutIndex;
@property (nonatomic, assign) InvoiceTypeOption currentInvoiceType;
@property (nonatomic, assign) InvoiceElectronicSubType invoiceElectronicSubType;
@property (nonatomic, assign) InvoiceDonateTarget invoiceDonateTarget;

- (void)startToGetCarrierInfo;
- (void)retrieveCarrierInfoForProducts:(NSArray *)products;
- (void)processCarrierInfoData:(NSData *)data;
- (void)prepareData;
- (void)retrieveInvoiceDescription;
- (void)processInvoiceDescription:(NSData *)data;
- (void)retrieveDeliverTargetList;
- (void)processDeliveryTargetList:(NSArray *)array fromOneClickBuy:(BOOL)isOneClickBuy;
- (void)setCurrentDeliveryTargetForIndex:(NSInteger)index;
- (void)refreshContent;
- (void)presentAlertMessage:(NSString *)message forIndexPath:(NSIndexPath *)indexPath withTextFieldDefaultText:(NSString *)defaultText andKeyboardType:(UIKeyboardType)keyboardType fromTableView:(UITableView *)tableView;
- (void)presentPhoneInputAlertMessage:(NSString *)message forIndexPath:(NSIndexPath *)indexPath withRegionNumber:(NSString *)regionNumber phoneNumber:(NSString *)phoneNumber andSpecificNumber:(NSString *)specificNumber fromTableView:(UITableView *)tableView;
- (void)retrieveDistrictInfo;
- (void)processDistrictInfo:(id)data;
- (void)presentActionsheetWithMessage:(NSString *)message forIndexPath:(NSIndexPath *)indexPath withOptions:(NSArray *)options fromTableView:(UITableView *)tableView;
- (NSArray *)currentInvoiceSections;
- (NSArray *)currentInvoiceCellsForSection:(NSInteger)section;
- (InvoiceCellTag)cellTagForInvoiceIndexPath:(NSIndexPath *)indexPath;
- (void)updateCurrentLayoutIndex;
- (DTAttributedTextCell *)tableView:(UITableView *)tableView preparedCellForIndexPath:(NSIndexPath *)indexPath;
- (void)presentActionSheetForDeliveryTarget:(NSArray *)arrayTarget;
- (NSString *)totalPhoneNumberForRegion:(NSString *)regionNumber phoneNumber:(NSString *)phoneNumber andSpecificNumber:(NSString *)specificNumber;
- (NSDictionary *)componentsOfPhoneNumber:(NSString *)phoneNumber;
- (void)prepareOrderData;

- (IBAction)buttonContactListPressed:(id)sender;
- (void)buttonNextPressed:(id)sender;
- (void)buttonLinkPressed:(id)sender;
- (void)linkLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer;

@end

@implementation ReceiverInfoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _canSelectDeliverTime = NO;
        _invoiceLayoutIndex = InvoiceLayoutTypeDefault;
        _selectedDeliverTimeIndex = DeliverTimeOptionNoSpecific;
        _invoiceElectronicSubType = InvoiceElectronicSubTypeTotal;
        _invoiceDonateTarget = InvoiceDonateTargetTotal;
        _currentInvoiceType = InvoiceTypeOptionTotal;
        _currentInvoiceCity = nil;
        _currentInvoiceRegion = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = [LocalizedString ReceiverInfo];
    
    [self.scrollView addSubview:self.tableViewInfo];
    [self.scrollView addSubview:self.tableViewInvoice];
    [self.scrollView addSubview:self.buttonNext];
    
    [self.scrollView bringSubviewToFront:self.separator];
    [self.navigationController.tabBarController.view addSubview:self.viewLoading];
    if (self.type == CartTypeFastDelivery)
    {
        [self startToGetCarrierInfo];
    }
    else
    {
        [self prepareData];
        [self retrieveDistrictInfo];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Override

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat marginV = 10.0;
    CGFloat marginH = 10.0;
    CGFloat intervalV = 8.0;
    
    CGFloat originY = MAX(CGRectGetMaxY(self.labelDeliverTitle.frame), CGRectGetMaxY(self.buttonContactList.frame));
    
    if (self.tableViewInfo)
    {
        NSInteger totalSections = [self numberOfSectionsInTableView:self.tableViewInfo];
        CGFloat totalHeight = 0.0;
        for (NSInteger index = 0; index < totalSections; index++)
        {
            CGRect rectSection = [self.tableViewInfo rectForSection:index];
            CGFloat height = rectSection.size.height;
            totalHeight += height;
        }
        CGRect frame = CGRectMake(0.0, originY, self.view.frame.size.width, totalHeight);
        self.tableViewInfo.frame = frame;
        originY = self.tableViewInfo.frame.origin.y + self.tableViewInfo.frame.size.height - 2;
    }
    
    if (self.separator)
    {
        CGRect frame = self.separator.frame;
        frame.origin.y = originY;
        self.separator.frame = frame;
        originY = self.separator.frame.origin.y + self.separator.frame.size.height + intervalV;
    }
    if (self.labelInvoiceTitle)
    {
        CGRect frame = self.labelInvoiceTitle.frame;
        frame.origin.y = originY;
        self.labelInvoiceTitle.frame = frame;
        originY = self.labelInvoiceTitle.frame.origin.y + self.labelInvoiceTitle.frame.size.height + intervalV;
    }
    if (self.tableViewInvoice)
    {
        NSInteger totalSections = [self numberOfSectionsInTableView:self.tableViewInvoice];
        CGFloat totalHeight = 0.0;
        for (NSInteger index = 0; index < totalSections; index++)
        {
            CGRect rectSection = [self.tableViewInvoice rectForSection:index];
            NSLog(@"rectSection[%li][%4.2f,%4.2f]", (long)index, rectSection.size.width, rectSection.size.height);
            CGFloat height = rectSection.size.height;
            totalHeight += height;
        }
        CGRect frame = CGRectMake(0.0, originY, self.view.frame.size.width, totalHeight);
        self.tableViewInvoice.frame = frame;
        originY = self.tableViewInvoice.frame.origin.y + self.tableViewInvoice.frame.size.height + intervalV;
    }
    if (self.buttonNext)
    {
        CGRect frame = CGRectMake(marginH, originY, self.scrollView.frame.size.width - marginH * 2, 40.0);
        self.buttonNext.frame = frame;
        originY = CGRectGetMaxY(self.buttonNext.frame) + marginV;
    }
    NSLog(@"originY[%4.2f]", originY);
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, originY)];
    
    if (self.viewLoading)
    {
        self.viewLoading.frame = self.navigationController.tabBarController.view.bounds;
        self.viewLoading.indicatorCenter = self.viewLoading.center;
        [self.viewLoading setNeedsLayout];
    }
}

- (FullScreenLoadingView *)viewLoading
{
    if (_viewLoading == nil)
    {
        _viewLoading = [[FullScreenLoadingView alloc] initWithFrame:CGRectZero];
        [_viewLoading setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
        _viewLoading.alpha = 0.0;
    }
    return _viewLoading;
}

- (UITableView *)tableViewInfo
{
    if (_tableViewInfo == nil)
    {
        _tableViewInfo = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableViewInfo setDataSource:self];
        [_tableViewInfo setDelegate:self];
        [_tableViewInfo setShowsVerticalScrollIndicator:NO];
        [_tableViewInfo setShowsHorizontalScrollIndicator:NO];
        [_tableViewInfo setScrollEnabled:NO];
        [_tableViewInfo registerClass:[ReceiverInfoCell class] forCellReuseIdentifier:ReceiverInfoCellIdentifier];
        [_tableViewInfo registerClass:[SingleLabelHeaderView class] forHeaderFooterViewReuseIdentifier:SingleLabelHeaderViewIdentifier];
    }
    return _tableViewInfo;
}

- (UITableView *)tableViewInvoice
{
    if (_tableViewInvoice == nil)
    {
        _tableViewInvoice = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableViewInvoice setDataSource:self];
        [_tableViewInvoice setDelegate:self];
        [_tableViewInvoice setShowsVerticalScrollIndicator:NO];
        [_tableViewInvoice setShowsHorizontalScrollIndicator:NO];
        [_tableViewInvoice setScrollEnabled:NO];
        [_tableViewInvoice registerClass:[ReceiverInfoCell class] forCellReuseIdentifier:ReceiverInfoCellIdentifier];
        [_tableViewInvoice registerClass:[SingleLabelHeaderView class] forHeaderFooterViewReuseIdentifier:SingleLabelHeaderViewIdentifier];
        [_tableViewInvoice registerClass:[DTAttributedTextCell class] forCellReuseIdentifier:DTAttributedTextCellIdentifier];
    }
    return _tableViewInvoice;
}

- (UIButton *)buttonNext
{
    if (_buttonNext == nil)
    {
        _buttonNext = [[UIButton alloc] initWithFrame:CGRectZero];
        [_buttonNext setBackgroundColor:[UIColor orangeColor]];
        [_buttonNext.layer setCornerRadius:5.0];
        [_buttonNext setTitle:[LocalizedString NextStep] forState:UIControlStateNormal];
        [_buttonNext addTarget:self action:@selector(buttonNextPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buttonNext;
}

- (NSMutableArray *)arrayDeliveryList
{
    if (_arrayDeliveryList == nil)
    {
        _arrayDeliveryList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _arrayDeliveryList;
}

- (NSMutableDictionary *)currentDeliveryTarget
{
    if (_currentDeliveryTarget == nil)
    {
        _currentDeliveryTarget = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _currentDeliveryTarget;
}

- (NSMutableArray *)arrayCity
{
    if (_arrayCity == nil)
    {
        _arrayCity = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _arrayCity;
}

- (NSMutableDictionary *)dictionaryRegionsForCity
{
    if (_dictionaryRegionsForCity == nil)
    {
        _dictionaryRegionsForCity = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _dictionaryRegionsForCity;
}

- (NSMutableDictionary *)dictionaryZipForRegion
{
    if (_dictionaryZipForRegion == nil)
    {
        _dictionaryZipForRegion = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _dictionaryZipForRegion;
}

- (NSMutableDictionary *)dictionaryCityForZip
{
    if (_dictionaryCityForZip == nil)
    {
        _dictionaryCityForZip = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _dictionaryCityForZip;
}

- (NSMutableDictionary *)dictionaryRegionForZip
{
    if (_dictionaryRegionForZip == nil)
    {
        _dictionaryRegionForZip = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _dictionaryRegionForZip;
}

- (NSMutableArray *)arrayDeliverTime
{
    if (_arrayDeliverTime == nil)
    {
        _arrayDeliverTime = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _arrayDeliverTime;
}

- (NSMutableArray *)arraySectionContent
{
    if (_arraySectionContent == nil)
    {
        _arraySectionContent = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _arraySectionContent;
}

- (NSMutableDictionary *)dictionaryInvoiceTemp
{
    if (_dictionaryInvoiceTemp == nil)
    {
        _dictionaryInvoiceTemp = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _dictionaryInvoiceTemp;
}

- (NSMutableArray *)arrayInvoiceSection
{
    if (_arrayInvoiceSection == nil)
    {
        _arrayInvoiceSection = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _arrayInvoiceSection;
}

- (NSMutableArray *)arrayInvoiceTypeTitle
{
    if (_arrayInvoiceTypeTitle == nil)
    {
        _arrayInvoiceTypeTitle = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _arrayInvoiceTypeTitle;
}

- (NSMutableArray *)arrayElectronicSubTypeTitle
{
    if (_arrayElectronicSubTypeTitle == nil)
    {
        _arrayElectronicSubTypeTitle = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _arrayElectronicSubTypeTitle;
}

- (NSMutableArray *)arrayInvoiceDonateTitle
{
    if (_arrayInvoiceDonateTitle == nil)
    {
        _arrayInvoiceDonateTitle = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _arrayInvoiceDonateTitle;
}

- (NSCache *)cellCache
{
    if (_cellCache == nil)
    {
        _cellCache = [[NSCache alloc] init];
    }
    return _cellCache;
}

#pragma mark - Private Methods

- (void)showLoadingViewAnimated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.viewLoading.activityIndicator startAnimating];
        if (animated)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                [self.viewLoading setAlpha:1.0];
            } completion:nil];
        }
        else
        {
            [self.viewLoading setAlpha:1.0];
        }
    });
}

- (void)hideLoadingViewAnimated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.viewLoading.activityIndicator stopAnimating];
        if (animated)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                [self.viewLoading setAlpha:0.0];
            } completion:nil];
        }
        else
        {
            [self.viewLoading setAlpha:0.0];
        }
    });
}

- (void)startToGetCarrierInfo
{
    NSArray *array = [[TMInfoManager sharedManager] productArrayForCartType:self.type];
    if (array == nil)
        return;
    
    NSMutableArray *arrayCheck = [NSMutableArray array];
    
    for (NSDictionary *product in array)
    {
        NSNumber *productId = [product objectForKey:SymphoxAPIParam_cpdt_num];
        if (productId == nil)
        {
            continue;
        }
        [arrayCheck addObject:productId];
    }
    
    NSArray *arrayAddition = [[TMInfoManager sharedManager] productArrayForAdditionalCartType:self.type];
    for (NSDictionary *product in arrayAddition)
    {
        NSNumber *productId = [product objectForKey:SymphoxAPIParam_cpdt_num];
        if (productId == nil)
        {
            continue;
        }
        [arrayCheck addObject:productId];
    }
    [self retrieveCarrierInfoForProducts:arrayCheck];
}

- (void)retrieveCarrierInfoForProducts:(NSArray *)products
{
    [self showLoadingViewAnimated:YES];
    __weak ReceiverInfoViewController *weakSelf = self;
    NSString *apiKey = [CryptoModule sharedModule].apiKey;
    NSString *token = [SHAPIAdapter sharedAdapter].token;
    NSURL *url = [NSURL URLWithString:SymphoxAPI_getCarrierInfo];
    NSLog(@"login url [%@]", [url absoluteString]);
    NSDictionary *headerFields = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, SymphoxAPIParam_key, token, SymphoxAPIParam_token, nil];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:products, SymphoxAPIParam_cpdt_nums, nil];
    [[SHAPIAdapter sharedAdapter] sendRequestFromObject:weakSelf ToUrl:url withHeaderFields:headerFields andPostObject:params inPostFormat:SHPostFormatJson encrypted:YES decryptedReturnData:YES completion:^(id resultObject, NSError *error){
        NSString *errorDescription = nil;
        if (error == nil)
        {
//            NSLog(@"resultObject[%@]:\n%@", [[resultObject class] description], [resultObject description]);
            if ([resultObject isKindOfClass:[NSData class]])
            {
                NSData *data = (NSData *)resultObject;
//                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                NSLog(@"retrieveCarrierInfoForProducts - string[%@]", string);
                [weakSelf processCarrierInfoData:data];
                [weakSelf prepareData];
                [weakSelf retrieveDistrictInfo];
            }
            else
            {
                NSLog(@"Unexpected data format.");
                errorDescription = [LocalizedString UnexpectedFormatFromNetwork];
                [weakSelf hideLoadingViewAnimated:YES];
            }
        }
        else
        {
            NSLog(@"error:\n%@", [error description]);
            [weakSelf hideLoadingViewAnimated:YES];
        }
    }];
}

- (void)processCarrierInfoData:(NSData *)data
{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dictionary = (NSDictionary *)jsonObject;
        NSArray *array = [dictionary objectForKey:SymphoxAPIParam_goods];
        if (array && [array isEqual:[NSNull null]] == NO)
        {
            for (NSDictionary *product in array)
            {
                NSString *carrier = [product objectForKey:SymphoxAPIParam_cpro_carrier];
                if (carrier && [carrier isEqual:[NSNull null]] == NO && [carrier integerValue] == 8)
                {
                    self.canSelectDeliverTime = YES;
                    break;
                }
            }
        }
    }
}

- (void)prepareData
{
    for (NSInteger sectionIndex = 0; sectionIndex < SectionIndexTotal; sectionIndex++)
    {
        NSMutableArray *content = [NSMutableArray array];
        switch (sectionIndex) {
            case SectionIndexInfo:
            {
                for (NSInteger index = 0; index < InfoCellTagTotal; index++)
                {
                    switch (index) {
                        default:
                        {
                            NSNumber *number = [NSNumber numberWithInteger:index];
                            [content addObject:number];
                        }
                            break;
                    }
                }
            }
                break;
            case SectionIndexDelivery:
            {
                for (NSInteger index = 0; index < DeliveryCellTagTotal; index++)
                {
                    switch (index) {
                        case DeliveryCellTagDeliverTime:
                        {
                            if (self.type == CartTypeFastDelivery && self.canSelectDeliverTime)
                            {
                                NSNumber *number = [NSNumber numberWithInteger:index];
                                [content addObject:number];
                            }
                        }
                            break;
                        default:
                        {
                            NSNumber *number = [NSNumber numberWithInteger:index];
                            [content addObject:number];
                        }
                            break;
                    }
                }
            }
                break;
            default:
                break;
        }
        [self.arraySectionContent addObject:content];
    }
    
    for (NSInteger index = 0; index < DeliverTimeOptionTotal; index++)
    {
        NSString *string = nil;
        switch (index) {
            case DeliverTimeOption9_12:
            {
                string = [LocalizedString Nine_Twelve_InTheMorning];
            }
                break;
            case DeliverTimeOption12_17:
            {
                string = [LocalizedString Twelve_Seventeen_InTheAfternoon];
            }
                break;
            case DeliverTimeOption17_20:
            {
                string = [LocalizedString Seventeen_Twenty_InTheEvening];
            }
                break;
            case DeliverTimeOptionNoSpecific:
            {
                string = [LocalizedString NotSpecified];
            }
                break;
            default:
                break;
        }
        if (string)
        {
            [self.arrayDeliverTime addObject:string];
        }
    }
    
    for (NSInteger typeIndex = 0; typeIndex < InvoiceLayoutTypeTotal; typeIndex++)
    {
        NSMutableArray *arraySection = [NSMutableArray array];
        switch (typeIndex) {
            case InvoiceLayoutTypeDefault:
            {
                NSInteger totalSection = 2;
                for (NSInteger sectionIndex = 0; sectionIndex < totalSection; sectionIndex++)
                {
                    NSMutableArray *section = [NSMutableArray array];
                    switch (sectionIndex) {
                        case 0:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagChooseType]];
                        }
                            break;
                        case 1:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagInvoiceDesc]];
                        }
                            break;
                        default:
                            break;
                    }
                    [arraySection addObject:section];
                }
            }
                break;
            case InvoiceLayoutTypeElectronicMember:
            {
                NSInteger totalSection = 2;
                for (NSInteger sectionIndex = 0; sectionIndex < totalSection; sectionIndex++)
                {
                    NSMutableArray *section = [NSMutableArray array];
                    switch (sectionIndex) {
                        case 0:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagChooseType]];
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagChooseElectronicType]];
                        }
                            break;
                        case 1:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagInvoiceDesc]];
                        }
                            break;
                        default:
                            break;
                    }
                    [arraySection addObject:section];
                }
            }
                break;
            case InvoiceLayoutTypeElectronicExtraCode:
            {
                NSInteger totalSection = 2;
                for (NSInteger sectionIndex = 0; sectionIndex < totalSection; sectionIndex++)
                {
                    NSMutableArray *section = [NSMutableArray array];
                    switch (sectionIndex) {
                        case 0:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagChooseType]];
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagChooseElectronicType]];
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagElectronicCode]];
                        }
                            break;
                        case 1:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagInvoiceDesc]];
                        }
                            break;
                        default:
                            break;
                    }
                    [arraySection addObject:section];
                }
            }
                break;
            case InvoiceLayoutTypeDonate:
            {
                NSInteger totalSection = 2;
                for (NSInteger sectionIndex = 0; sectionIndex < totalSection; sectionIndex++)
                {
                    NSMutableArray *section = [NSMutableArray array];
                    switch (sectionIndex) {
                        case 0:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagChooseType]];
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagChooseDonateTarget]];
                        }
                            break;
                        case 1:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagInvoiceDesc]];
                        }
                            break;
                        default:
                            break;
                    }
                    [arraySection addObject:section];
                }
            }
                break;
            case InvoiceLayoutTypeDonateSpecificGroup:
            {
                NSInteger totalSection = 2;
                for (NSInteger sectionIndex = 0; sectionIndex < totalSection; sectionIndex++)
                {
                    NSMutableArray *section = [NSMutableArray array];
                    switch (sectionIndex) {
                        case 0:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagChooseType]];
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagChooseDonateTarget]];
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagDonateCode]];
                        }
                            break;
                        case 1:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagInvoiceDesc]];
                        }
                            break;
                        default:
                            break;
                    }
                    [arraySection addObject:section];
                }
            }
                break;
            case InvoiceLayoutTypeTriplicate:
            {
                NSInteger totalSection = 4;
                for (NSInteger sectionIndex = 0; sectionIndex < totalSection; sectionIndex++)
                {
                    NSMutableArray *section = [NSMutableArray array];
                    switch (sectionIndex) {
                        case 0:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagChooseType]];
                        }
                            break;
                        case 1:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagInvoiceDesc]];
                        }
                            break;
                        case 2:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagInvoiceTitle]];
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagInvoiceIdentifier]];
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagReceiver]];
                        }
                            break;
                        case 3:
                        {
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagCity]];
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagRegion]];
                            [section addObject:[NSNumber numberWithInteger:InvoiceCellTagAddress]];
                        }
                            break;
                        default:
                            break;
                    }
                    [arraySection addObject:section];
                }
            }
                break;
            default:
                break;
        }
        [self.arrayInvoiceSection addObject:arraySection];
    }
    for (NSInteger index = 0; index < InvoiceTypeOptionTotal; index++)
    {
        switch (index) {
            case InvoiceTypeOptionElectronic:
            {
                [self.arrayInvoiceTypeTitle addObject:[LocalizedString ElectronicInvoice]];
            }
                break;
            case InvoiceTypeOptionDonate:
            {
                [self.arrayInvoiceTypeTitle addObject:[LocalizedString InvoiceDonate]];
            }
                break;
            case InvoiceTypeOptionTriplicate:
            {
                [self.arrayInvoiceTypeTitle addObject:[LocalizedString TriplicateUniformInvoice]];
            }
                break;
            default:
                break;
        }
    }
    for (NSInteger index = 0; index < InvoiceElectronicSubTypeTotal; index++)
    {
        switch (index) {
            case InvoiceElectronicSubTypeMember:
            {
                [self.arrayElectronicSubTypeTitle addObject:[LocalizedString CarrierMember]];
            }
                break;
            case InvoiceElectronicSubTypeNaturalPerson:
            {
                [self.arrayElectronicSubTypeTitle addObject:[LocalizedString CarrierNaturalPerson]];
            }
                break;
            case InvoiceElectronicSubTypeCellphoneBarcode:
            {
                [self.arrayElectronicSubTypeTitle addObject:[LocalizedString CarrierCellPhoneBarcode]];
            }
                break;
            default:
                break;
        }
    }
    for (NSInteger index = 0; index < InvoiceDonateTargetTotal; index++)
    {
        switch (index) {
            case InvoiceDonateTarget1:
            {
                [self.arrayInvoiceDonateTitle addObject:[LocalizedString DonateTarget1]];
            }
                break;
            case InvoiceDonateTarget2:
            {
                [self.arrayInvoiceDonateTitle addObject:[LocalizedString DonateTarget2]];
            }
                break;
            case InvoiceDonateTarget3:
            {
                [self.arrayInvoiceDonateTitle addObject:[LocalizedString DonateTarget3]];
            }
                break;
            case InvoiceDonateTargetOther:
            {
                [self.arrayInvoiceDonateTitle addObject:[LocalizedString DonateTargetOther]];
            }
                break;
            default:
                break;
        }
    }
}

- (void)retrieveInvoiceDescription
{
    [self showLoadingViewAnimated:YES];
    __weak ReceiverInfoViewController *weakSelf = self;
    NSURL *url = [NSURL URLWithString:SymphoxAPI_terms];
    NSDictionary *postDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"TM_O_03", SymphoxAPIParam_txid, @"5", SymphoxAPIParam_type, nil];
    [[SHAPIAdapter sharedAdapter] sendRequestFromObject:weakSelf ToUrl:url withHeaderFields:nil andPostObject:postDictionary inPostFormat:SHPostFormatUrlEncoded encrypted:NO decryptedReturnData:NO completion:^(id resultObject, NSError *error){
        
        if (error == nil)
        {
            NSString *string = [[NSString alloc] initWithData:resultObject encoding:NSUTF8StringEncoding];
            NSLog(@"retrieveInvoiceDescription - string:\n%@", string);
            [weakSelf processInvoiceDescription:resultObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf refreshContent];
            });
            [weakSelf retrieveDeliverTargetList];
        }
        else
        {
            NSLog(@"error:\n%@", error);
            [weakSelf hideLoadingViewAnimated:YES];
        }
    }];
}

- (void)processInvoiceDescription:(NSData *)data
{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error == nil && [jsonObject isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dictionary = (NSDictionary *)jsonObject;
        NSString *result = [dictionary objectForKey:SymphoxAPIParam_result];
        if (result && [result integerValue] == 0)
        {
            // success
            NSString *content = [dictionary objectForKey:SymphoxAPIParam_content];
            if (content)
            {
                NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
                self.attrStringInvoiceDesc = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:nil];
            }
        }
    }
}

- (void)retrieveDeliverTargetList
{
    [self showLoadingViewAnimated:YES];
    __weak ReceiverInfoViewController *weakSelf = self;
    NSString *apiKey = [CryptoModule sharedModule].apiKey;
    NSString *token = [SHAPIAdapter sharedAdapter].token;
    NSURL *url = nil;
    NSDictionary *params = nil;
    
    if (self.tradeId && ([self.tradeId isEqualToString:@"O"] || [self.tradeId isEqualToString:@"O2"]))
    {
        url = [NSURL URLWithString:SymphoxAPI_getOneClickBuyContactInfo];
        params = [NSDictionary dictionaryWithObjectsAndKeys:[TMInfoManager sharedManager].userIdentifier, SymphoxAPIParam_user_num, nil];
    }
    else
    {
        url = [NSURL URLWithString:SymphoxAPI_getContactInfo];
        params = [NSDictionary dictionaryWithObjectsAndKeys:[TMInfoManager sharedManager].userIdentifier, SymphoxAPIParam_user_num, @"N", SymphoxAPIParam_is_mask, nil];
    }
    
    NSLog(@"login url [%@]", [url absoluteString]);
    NSDictionary *headerFields = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, SymphoxAPIParam_key, token, SymphoxAPIParam_token, nil];
    [[SHAPIAdapter sharedAdapter] sendRequestFromObject:weakSelf ToUrl:url withHeaderFields:headerFields andPostObject:params inPostFormat:SHPostFormatJson encrypted:YES decryptedReturnData:YES completion:^(id resultObject, NSError *error){
        NSString *errorDescription = nil;
        if (error == nil)
        {
//            NSLog(@"resultObject[%@]:\n%@", [[resultObject class] description], [resultObject description]);
            if ([resultObject isKindOfClass:[NSData class]])
            {
                NSData *data = (NSData *)resultObject;
                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"retrieveDeliverTargetList - string[%@]", string);
                NSArray *array = nil;
                BOOL isOneClickBuy = NO;
                if (weakSelf.tradeId && ([weakSelf.tradeId isEqualToString:@"O"] || [weakSelf.tradeId isEqualToString:@"O2"]))
                {
                    array = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                    isOneClickBuy = YES;
                }
                else
                {
                    array = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                }
                
                [weakSelf processDeliveryTargetList:array fromOneClickBuy:isOneClickBuy];
            }
            else
            {
                NSLog(@"Unexpected data format.");
                errorDescription = [LocalizedString UnexpectedFormatFromNetwork];
            }
        }
        else
        {
            NSLog(@"error:\n%@", [error description]);
        }
        [weakSelf hideLoadingViewAnimated:YES];
    }];
}

- (void)processDeliveryTargetList:(NSArray *)array fromOneClickBuy:(BOOL)isOneClickBuy
{
    if (array == nil)
        return;
    NSInteger defaultIndex = NSNotFound;
    NSMutableArray *deliveryTargets = [NSMutableArray array];
    for (NSInteger index = 0; index < [array count]; index++)
    {
        NSDictionary *dictionary = [array objectAtIndex:index];
        NSMutableDictionary *deliveryTarget = [NSMutableDictionary dictionary];
        if (isOneClickBuy)
        {
            NSString *name = [dictionary objectForKey:SymphoxAPIParam_name];
            NSString *day_area_code = [dictionary objectForKey:SymphoxAPIParam_day_area_code];
            NSString *day_tel = [dictionary objectForKey:SymphoxAPIParam_day_tel];
            NSString *day_extension = [dictionary objectForKey:SymphoxAPIParam_day_extension];
            NSString *night_area_code = [dictionary objectForKey:SymphoxAPIParam_night_area_code];
            NSString *night_tel = [dictionary objectForKey:SymphoxAPIParam_night_tel];
            NSString *night_extension = [dictionary objectForKey:SymphoxAPIParam_night_extension];
            NSString *zip = [dictionary objectForKey:SymphoxAPIParam_zip];
            NSString *addr = [dictionary objectForKey:SymphoxAPIParam_addr];
            NSString *cell_phone = [dictionary objectForKey:SymphoxAPIParam_cell_phone];
            NSNumber *order_num = [dictionary objectForKey:SymphoxAPIParam_order_num];
            
            if (name && [name isEqual:[NSNull null]] == NO)
            {
                [deliveryTarget setObject:name forKey:SymphoxAPIParam_name];
            }
            NSString *dayPhone = [self totalPhoneNumberForRegion:day_area_code phoneNumber:day_tel andSpecificNumber:day_extension];
            if (dayPhone > 0)
            {
                [deliveryTarget setObject:dayPhone forKey:SymphoxAPIParam_day_tel];
            }
            NSString *nightPhone = [self totalPhoneNumberForRegion:night_area_code phoneNumber:night_tel andSpecificNumber:night_extension];
            if (nightPhone > 0)
            {
                [deliveryTarget setObject:nightPhone forKey:SymphoxAPIParam_night_tel];
            }
            if (cell_phone && [cell_phone isEqual:[NSNull null]] == NO && [cell_phone length] > 0)
            {
                [deliveryTarget setObject:cell_phone forKey:SymphoxAPIParam_cellphone];
            }
            if (addr && [addr isEqual:[NSNull null]] == NO && [addr length] > 0)
            {
                [deliveryTarget setObject:addr forKey:SymphoxAPIParam_address];
            }
            if (zip && [zip isEqual:[NSNull null]] == NO && [zip length] > 0)
            {
                [deliveryTarget setObject:zip forKey:SymphoxAPIParam_zip];
            }
            if (order_num && [order_num isEqual:[NSNull null]] == NO)
            {
                [deliveryTarget setObject:zip forKey:SymphoxAPIParam_order_num];
            }
        }
        else
        {
            NSString *name = [dictionary objectForKey:SymphoxAPIParam_name];
            NSString *tel_area = [dictionary objectForKey:SymphoxAPIParam_tel_area];
            NSString *tel_num = [dictionary objectForKey:SymphoxAPIParam_tel_num];
            NSString *tel_ex = [dictionary objectForKey:SymphoxAPIParam_tel_ex];
            NSString *mobile = [dictionary objectForKey:SymphoxAPIParam_mobile];
            NSString *address = [dictionary objectForKey:SymphoxAPIParam_address];
            NSString *zip = [dictionary objectForKey:SymphoxAPIParam_zip];
            NSString *as_shipping = [dictionary objectForKey:SymphoxAPIParam_as_shipping];
            
            
            if (name && [name isEqual:[NSNull null]] == NO)
            {
                [deliveryTarget setObject:name forKey:SymphoxAPIParam_name];
            }
            
            NSString *phone = [self totalPhoneNumberForRegion:tel_area phoneNumber:tel_num andSpecificNumber:tel_ex];
            if ([phone length] > 0)
            {
                [deliveryTarget setObject:phone forKey:SymphoxAPIParam_day_tel];
                [deliveryTarget setObject:phone forKey:SymphoxAPIParam_night_tel];
            }
            if (mobile && [mobile isEqual:[NSNull null]] == NO && [mobile length] > 0)
            {
                [deliveryTarget setObject:mobile forKey:SymphoxAPIParam_cellphone];
            }
            
            if (address && [address isEqual:[NSNull null]] == NO && [address length] > 0)
            {
                [deliveryTarget setObject:address forKey:SymphoxAPIParam_address];
            }
            if (zip && [zip isEqual:[NSNull null]] == NO && [zip length] > 0)
            {
                [deliveryTarget setObject:zip forKey:SymphoxAPIParam_zip];
            }
            
            if (as_shipping && [as_shipping isEqual:[NSNull null]] == NO && [as_shipping length] > 0)
            {
                if ([as_shipping boolValue])
                {
                    defaultIndex = index;
                }
            }
        }
        [deliveryTargets addObject:deliveryTarget];
    }
    
    if (isOneClickBuy)
    {
        [deliveryTargets sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSComparisonResult result = NSOrderedSame;
            
            NSNumber *orderNum1 = [obj1 objectForKey:SymphoxAPIParam_order_num];
            NSNumber *orderNum2 = [obj2 objectForKey:SymphoxAPIParam_order_num];
            if (orderNum1 == nil || [orderNum1 isEqual:[NSNull null]])
            {
                result = NSOrderedDescending;
            }
            else if (orderNum2 == nil || [orderNum2 isEqual:[NSNull null]])
            {
                result = NSOrderedAscending;
            }
            else if ([orderNum1 integerValue] > [orderNum2 integerValue])
            {
                result = NSOrderedDescending;
            }
            else if ([orderNum1 integerValue] < [orderNum2 integerValue])
            {
                result = NSOrderedAscending;
            }
            
            return result;
        }];
    }
    
    NSLog(@"deliveryTargets:\n%@", [deliveryTargets description]);
    
    [self.arrayDeliveryList setArray:deliveryTargets];
    
    if (defaultIndex != NSNotFound)
    {
        [self setCurrentDeliveryTargetForIndex:defaultIndex];
    }
}

- (void)setCurrentDeliveryTargetForIndex:(NSInteger)index
{
    if (index < [self.arrayDeliveryList count])
    {
        NSDictionary *deliveryTarget = [self.arrayDeliveryList objectAtIndex:index];
        [self.currentDeliveryTarget setDictionary:deliveryTarget];
    }
    else
    {
        [self.currentDeliveryTarget removeAllObjects];
    }
    NSString *zip = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_zip];
    if (zip)
    {
        NSString *city = [self.dictionaryCityForZip objectForKey:zip];
        if (city)
        {
            self.currentCity = city;
        }
        NSString *region = [self.dictionaryRegionForZip objectForKey:zip];
        if (region)
        {
            self.currentRegion = region;
        }
    }
    [self refreshContent];
}

- (void)refreshContent
{
    __weak ReceiverInfoViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableViewInfo reloadData];
        
        if (weakSelf.currentInvoiceType == InvoiceTypeOptionTotal)
        {
            weakSelf.invoiceLayoutIndex = InvoiceLayoutTypeDefault;
        }
        [weakSelf.tableViewInvoice reloadData];
        [weakSelf.view setNeedsLayout];
    });
}

- (void)presentAlertMessage:(NSString *)message forIndexPath:(NSIndexPath *)indexPath withTextFieldDefaultText:(NSString *)defaultText andKeyboardType:(UIKeyboardType)keyboardType fromTableView:(UITableView *)tableView
{
    UIAlertController *alertControlelr = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertControlelr addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setKeyboardType:keyboardType];
        if (defaultText && [defaultText length] > 0)
        {
            [textField setText:defaultText];
            [textField selectAll:nil];
        }
    }];
    __weak ReceiverInfoViewController *weakSelf = self;
    UIAlertAction *action = [UIAlertAction actionWithTitle:[LocalizedString Confirm] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if ([alertControlelr.textFields count] <= 0)
            return;
        UITextField *textField = [alertControlelr.textFields objectAtIndex:0];
        NSString *text = textField.text;
        if ([text length] == 0)
        {
            return;
        }
        if (tableView == weakSelf.tableViewInfo)
        {
            switch (indexPath.section) {
                case SectionIndexInfo:
                {
                    switch (indexPath.row) {
                        case InfoCellTagReceiverName:
                        {
                            [weakSelf.currentDeliveryTarget setObject:text forKey:SymphoxAPIParam_name];
                        }
                            break;
                        case InfoCellTagCellPhone:
                        {
                            if ([Utility evaluateCellPhoneNumber:text])
                            {
                                [weakSelf.currentDeliveryTarget setObject:text forKey:SymphoxAPIParam_cellphone];
                            }
                        }
                            break;
                        case InfoCellTagDayPhone:
                        {
                            if ([Utility evaluateLocalPhoneNumber:text])
                            {
                                [weakSelf.currentDeliveryTarget setObject:text forKey:SymphoxAPIParam_day_tel];
                            }
                        }
                            break;
                        case InfoCellTagNightPhone:
                        {
                            if ([Utility evaluateLocalPhoneNumber:text])
                            {
                                [weakSelf.currentDeliveryTarget setObject:text forKey:SymphoxAPIParam_night_tel];
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case SectionIndexDelivery:
                {
                    switch (indexPath.row) {
                        case DeliveryCellTagAddress:
                        {
                            [weakSelf.currentDeliveryTarget setObject:text forKey:SymphoxAPIParam_address];
                        }
                            break;
                        case DeliveryCellTagNote:
                        {
                            [weakSelf.currentDeliveryTarget setObject:text forKey:SymphoxAPIParam_notes];
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                default:
                    break;
            }
        }
        else if (tableView == weakSelf.tableViewInvoice)
        {
            InvoiceCellTag cellTag = [weakSelf cellTagForInvoiceIndexPath:indexPath];
            switch (cellTag) {
                case InvoiceCellTagElectronicCode:
                {
                    [weakSelf.dictionaryInvoiceTemp setObject:text forKey:SymphoxAPIParam_icarrier_id];
                }
                    break;
                case InvoiceCellTagDonateCode:
                {
                    [weakSelf.dictionaryInvoiceTemp setObject:text forKey:SymphoxAPIParam_inpoban];
                }
                    break;
                case InvoiceCellTagInvoiceTitle:
                {
                    [weakSelf.dictionaryInvoiceTemp setObject:text forKey:SymphoxAPIParam_inv_title];
                }
                    break;
                case InvoiceCellTagInvoiceIdentifier:
                {
                    [weakSelf.dictionaryInvoiceTemp setObject:text forKey:SymphoxAPIParam_inv_regno];
                }
                    break;
                case InvoiceCellTagReceiver:
                {
                    [weakSelf.dictionaryInvoiceTemp setObject:text forKey:SymphoxAPIParam_inv_name];
                }
                    break;
                case InvoiceCellTagAddress:
                {
                    [weakSelf.dictionaryInvoiceTemp setObject:text forKey:SymphoxAPIParam_inv_address];
                }
                default:
                    break;
            }
        }
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [alertControlelr addAction:action];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LocalizedString Cancel] style:UIAlertActionStyleCancel handler:nil];
    [alertControlelr addAction:actionCancel];
    [self presentViewController:alertControlelr animated:YES completion:nil];
}

- (void)presentPhoneInputAlertMessage:(NSString *)message forIndexPath:(NSIndexPath *)indexPath withRegionNumber:(NSString *)regionNumber phoneNumber:(NSString *)phoneNumber andSpecificNumber:(NSString *)specificNumber fromTableView:(UITableView *)tableView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setReturnKeyType:UIReturnKeyNext];
        [textField setPlaceholder:[LocalizedString PleaseInputRegionNumber]];
        if (regionNumber && [regionNumber length] > 0)
        {
            [textField setText:regionNumber];
            [textField selectAll:nil];
        }
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setReturnKeyType:UIReturnKeyNext];
        [textField setPlaceholder:[LocalizedString PleaseInputPhoneNumber]];
        if (phoneNumber && [phoneNumber length] > 0)
        {
            [textField setText:phoneNumber];
            [textField selectAll:nil];
        }
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setPlaceholder:[LocalizedString PleaseInputSpecificNumber]];
        if (specificNumber && [specificNumber length] > 0)
        {
            [textField setText:specificNumber];
            [textField selectAll:nil];
        }
    }];
    __weak ReceiverInfoViewController *weakSelf = self;
    UIAlertAction *action = [UIAlertAction actionWithTitle:[LocalizedString Confirm] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if ([alertController.textFields count] <= 0)
            return;
        UITextField *textField1 = [alertController.textFields objectAtIndex:0];
        NSString *text1 = textField1.text;
        UITextField *textField2 = [alertController.textFields objectAtIndex:1];
        NSString *text2 = textField2.text;
        UITextField *textField3 = [alertController.textFields objectAtIndex:2];
        NSString *text3 = textField3.text;
        if ([text1 length] == 0)
        {
            UIAlertController *alertController1 = [UIAlertController alertControllerWithTitle:nil message:[LocalizedString PleaseInputRegionNumber] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:[LocalizedString Confirm] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [weakSelf presentPhoneInputAlertMessage:message forIndexPath:indexPath withRegionNumber:text1 phoneNumber:text2 andSpecificNumber:text3 fromTableView:tableView];
            }];
            [alertController1 addAction:action1];
            [weakSelf presentViewController:alertController1 animated:YES completion:nil];
            return;
        }
        
        if ([text2 length] == 0)
        {
            UIAlertController *alertController1 = [UIAlertController alertControllerWithTitle:nil message:[LocalizedString PleaseInputPhoneNumber] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:[LocalizedString Confirm] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [weakSelf presentPhoneInputAlertMessage:message forIndexPath:indexPath withRegionNumber:text1 phoneNumber:text2 andSpecificNumber:text3 fromTableView:tableView];
            }];
            [alertController1 addAction:action1];
            [weakSelf presentViewController:alertController1 animated:YES completion:nil];
            return;
        }
        
        NSString *totalString = [weakSelf totalPhoneNumberForRegion:text1 phoneNumber:text2 andSpecificNumber:text3];
        if (tableView == weakSelf.tableViewInfo)
        {
            switch (indexPath.section) {
                case SectionIndexInfo:
                {
                    switch (indexPath.row) {
                        case InfoCellTagDayPhone:
                        {
                            [weakSelf.currentDeliveryTarget setObject:totalString forKey:SymphoxAPIParam_day_tel];
                        }
                            break;
                        case InfoCellTagNightPhone:
                        {
                            [weakSelf.currentDeliveryTarget setObject:totalString forKey:SymphoxAPIParam_night_tel];
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                default:
                    break;
            }
        }
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [alertController addAction:action];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LocalizedString Cancel] style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)retrieveDistrictInfo
{
    [self showLoadingViewAnimated:YES];
    __weak ReceiverInfoViewController *weakSelf = self;
    NSString *apiKey = [CryptoModule sharedModule].apiKey;
    NSString *token = [SHAPIAdapter sharedAdapter].token;
    NSURL *url = [NSURL URLWithString:SymphoxAPI_getDistrictInfo];
    NSLog(@"login url [%@]", [url absoluteString]);
    NSDictionary *headerFields = [NSDictionary dictionaryWithObjectsAndKeys:apiKey, SymphoxAPIParam_key, token, SymphoxAPIParam_token, nil];
    
    [[SHAPIAdapter sharedAdapter] sendRequestFromObject:weakSelf ToUrl:url withHeaderFields:headerFields andPostObject:nil inPostFormat:SHPostFormatJson encrypted:YES decryptedReturnData:YES completion:^(id resultObject, NSError *error){
        NSString *errorDescription = nil;
        if (error == nil)
        {
//            NSLog(@"resultObject[%@]:\n%@", [[resultObject class] description], [resultObject description]);
            if ([resultObject isKindOfClass:[NSData class]])
            {
                NSData *data = (NSData *)resultObject;
                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"retrieveDistrictInfo - string[%@]", string);
//                NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//                [weakSelf processDeliveryTargetList:array];
                [weakSelf processDistrictInfo:data];
                [weakSelf retrieveInvoiceDescription];
            }
            else
            {
                NSLog(@"Unexpected data format.");
                errorDescription = [LocalizedString UnexpectedFormatFromNetwork];
                [weakSelf hideLoadingViewAnimated:YES];
            }
        }
        else
        {
            NSLog(@"error:\n%@", [error description]);
            [weakSelf hideLoadingViewAnimated:YES];
        }
    }];
}

- (void)processDistrictInfo:(id)data
{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error)
        return;
    if ([jsonObject isKindOfClass:[NSArray class]])
    {
        NSArray *array = (NSArray *)jsonObject;
        for (NSDictionary *dictionaryCity in array)
        {
            NSString *city = [dictionaryCity objectForKey:SymphoxAPIParam_zip_city];
            [self.arrayCity addObject:city];
            
            NSArray *townList = [dictionaryCity objectForKey:SymphoxAPIParam_townList];
            
            NSMutableArray *regions = [NSMutableArray array];
            for (NSDictionary *dictionaryRegion in townList)
            {
                NSString *zip_town = [dictionaryRegion objectForKey:SymphoxAPIParam_zip_town];
                NSString *zip_num = [dictionaryRegion objectForKey:SymphoxAPIParam_zip_num];
                if ([self.dictionaryCityForZip objectForKey:zip_num] == nil)
                {
                    [self.dictionaryCityForZip setObject:city forKey:zip_num];
                }
                if ([self.dictionaryRegionForZip objectForKey:zip_num] == nil)
                {
                    [self.dictionaryRegionForZip setObject:zip_town forKey:zip_num];
                }
                if ([self.dictionaryZipForRegion objectForKey:zip_town] == nil)
                {
                    [self.dictionaryZipForRegion setObject:zip_num forKey:zip_town];
                }
                if ([regions containsObject:zip_town] == NO)
                {
                    [regions addObject:zip_town];
                }
            }
            if (regions && [regions count] > 0)
            {
                [self.dictionaryRegionsForCity setObject:regions forKey:city];
            }
        }
    }
}

- (void)presentActionsheetWithMessage:(NSString *)message forIndexPath:(NSIndexPath *)indexPath withOptions:(NSArray *)options fromTableView:(UITableView *)tableView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
    __weak ReceiverInfoViewController *weakSelf = self;
    for (NSInteger index = 0; index < [options count]; index++)
    {
        NSString *string = [options objectAtIndex:index];
        UIAlertAction *action = [UIAlertAction actionWithTitle:string style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (tableView == weakSelf.tableViewInfo)
            {
                BOOL shouldReloadEntireTableView = NO;
                NSArray *sectionContent = [weakSelf.arraySectionContent objectAtIndex:indexPath.section];
                NSNumber *number = [sectionContent objectAtIndex:indexPath.row];
                switch (indexPath.section) {
                    case SectionIndexDelivery:
                    {
                        switch ([number integerValue]) {
                            case DeliveryCellTagCity:
                            {
                                NSString *city = [options objectAtIndex:index];
                                if ([weakSelf.currentCity isEqualToString:city] == NO)
                                {
                                    weakSelf.currentCity = city;
                                    [weakSelf.currentDeliveryTarget removeObjectForKey:SymphoxAPIParam_address];
                                    shouldReloadEntireTableView = YES;
                                }
                            }
                                break;
                            case DeliveryCellTagRegion:
                            {
                                NSString *region = [options objectAtIndex:index];
                                if ([weakSelf.currentRegion isEqualToString:region] == NO)
                                {
                                    weakSelf.currentRegion = region;
                                    [weakSelf.currentDeliveryTarget removeObjectForKey:SymphoxAPIParam_address];
                                    shouldReloadEntireTableView = YES;
                                }
                            }
                                break;
                            case DeliveryCellTagDeliverTime:
                            {
                                weakSelf.selectedDeliverTimeIndex = index;
                            }
                                break;
                            default:
                                break;
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
                if (shouldReloadEntireTableView)
                {
                    [tableView reloadData];
                }
                else
                {
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            else if (tableView == weakSelf.tableViewInvoice)
            {
                InvoiceCellTag cellTag = [weakSelf cellTagForInvoiceIndexPath:indexPath];
                switch (cellTag) {
                    case InvoiceCellTagChooseType:
                    {
                        weakSelf.currentInvoiceType = index;
                        if (weakSelf.currentInvoiceType == InvoiceTypeOptionTriplicate)
                        {
                            [weakSelf.dictionaryInvoiceTemp setObject:[NSNumber numberWithInteger:3] forKey:SymphoxAPIParam_inv_type];
                        }
                        else if (weakSelf.currentInvoiceType == InvoiceTypeOptionElectronic || weakSelf.currentInvoiceType == InvoiceTypeOptionDonate)
                        {
                            [weakSelf.dictionaryInvoiceTemp setObject:[NSNumber numberWithInteger:2] forKey:SymphoxAPIParam_inv_type];
                        }
                        [weakSelf updateCurrentLayoutIndex];
                        [weakSelf refreshContent];
                    }
                        break;
                    case InvoiceCellTagChooseElectronicType:
                    {
                        weakSelf.invoiceElectronicSubType = index;
                        switch (weakSelf.invoiceElectronicSubType) {
                            case InvoiceElectronicSubTypeMember:
                            {
                                [weakSelf.dictionaryInvoiceTemp setObject:@"EG0031" forKey:SymphoxAPIParam_icarrier_type];
                                NSString *stringUID = [[TMInfoManager sharedManager].userIdentifier stringValue];
                                [weakSelf.dictionaryInvoiceTemp setObject:stringUID forKey:SymphoxAPIParam_icarrier_id];
                            }
                                break;
                            case InvoiceElectronicSubTypeNaturalPerson:
                            {
                                [weakSelf.dictionaryInvoiceTemp setObject:@"CQ0001" forKey:SymphoxAPIParam_icarrier_type];
                                [weakSelf.dictionaryInvoiceTemp removeObjectForKey:SymphoxAPIParam_icarrier_id];
                            }
                                break;
                            case InvoiceElectronicSubTypeCellphoneBarcode:
                            {
                                [weakSelf.dictionaryInvoiceTemp setObject:@"3j0002" forKey:SymphoxAPIParam_icarrier_type];
                                [weakSelf.dictionaryInvoiceTemp removeObjectForKey:SymphoxAPIParam_icarrier_id];
                            }
                                break;
                            default:
                                break;
                        }
                        [weakSelf updateCurrentLayoutIndex];
                        [weakSelf refreshContent];
                    }
                        break;
                    case InvoiceCellTagChooseDonateTarget:
                    {
                        weakSelf.invoiceDonateTarget = index;
                        switch (weakSelf.invoiceDonateTarget) {
                            case InvoiceDonateTarget1:
                            {
                                [weakSelf.dictionaryInvoiceTemp setObject:@"51811" forKey:SymphoxAPIParam_inpoban];
                            }
                                break;
                            case InvoiceDonateTarget2:
                            {
                                [weakSelf.dictionaryInvoiceTemp setObject:@"919" forKey:SymphoxAPIParam_inpoban];
                            }
                                break;
                            case InvoiceDonateTarget3:
                            {
                                [weakSelf.dictionaryInvoiceTemp setObject:@"8455" forKey:SymphoxAPIParam_inpoban];
                            }
                            case InvoiceDonateTargetOther:
                            {
                                [weakSelf.dictionaryInvoiceTemp removeObjectForKey:SymphoxAPIParam_inpoban];
                            }
                                break;
                            default:
                                break;
                        }
                        [weakSelf updateCurrentLayoutIndex];
                        [weakSelf refreshContent];
                    }
                        break;
                    case InvoiceCellTagCity:
                    {
                        NSString *city = [options objectAtIndex:index];
                        weakSelf.currentInvoiceCity = city;
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                        break;
                    case InvoiceCellTagRegion:
                    {
                        NSString *region = [options objectAtIndex:index];
                        weakSelf.currentInvoiceRegion = region;
                        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                        break;
                    default:
                        break;
                }
            }
            else
            {
                
            }
        }];
        [alertController addAction:action];
    }
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LocalizedString Cancel] style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSArray *)currentInvoiceSections
{
    NSArray *array = nil;
    if (self.invoiceLayoutIndex < [self.arrayInvoiceSection count])
    {
        array = [self.arrayInvoiceSection objectAtIndex:self.invoiceLayoutIndex];
    }
    return array;
}

- (NSArray *)currentInvoiceCellsForSection:(NSInteger)section
{
    NSArray *arraySection = [self currentInvoiceSections];
    if (arraySection == nil)
        return nil;
    if (section >= [arraySection count])
        return nil;
    NSArray *array = [arraySection objectAtIndex:section];
    return array;
}

- (InvoiceCellTag)cellTagForInvoiceIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arraySectionContent = [self currentInvoiceCellsForSection:indexPath.section];
    if (arraySectionContent == nil)
        return InvoiceCellTagUnknown;
    NSNumber *numberCellTag = [arraySectionContent objectAtIndex:indexPath.row];
    return [numberCellTag integerValue];
}

- (void)updateCurrentLayoutIndex
{
    switch (self.currentInvoiceType) {
        
        case InvoiceTypeOptionElectronic:
        {
            if (self.invoiceElectronicSubType == InvoiceElectronicSubTypeMember || self.invoiceElectronicSubType == InvoiceElectronicSubTypeTotal)
            {
                self.invoiceLayoutIndex = InvoiceLayoutTypeElectronicMember;
            }
            else
            {
                self.invoiceLayoutIndex = InvoiceLayoutTypeElectronicExtraCode;
            }
        }
            break;
        case InvoiceTypeOptionDonate:
        {
            if (self.invoiceDonateTarget == InvoiceDonateTargetOther)
            {
                self.invoiceLayoutIndex = InvoiceLayoutTypeDonateSpecificGroup;
            }
            else
            {
                self.invoiceLayoutIndex = InvoiceLayoutTypeDonate;
            }
        }
            break;
        case InvoiceTypeOptionTriplicate:
        {
            self.invoiceLayoutIndex = InvoiceLayoutTypeTriplicate;
        }
            break;
        default:
        {
            self.invoiceLayoutIndex = InvoiceLayoutTypeDefault;
        }
            break;
    }
}

- (DTAttributedTextCell *)tableView:(UITableView *)tableView preparedCellForIndexPath:(NSIndexPath *)indexPath
{
    DTAttributedTextCell *dtCell = [self.cellCache objectForKey:DTAttributedTextCellIdentifier];
    if (dtCell == nil)
    {
        DTAttributedTextCell *dtCell = [[DTAttributedTextCell alloc] initWithReuseIdentifier:DTAttributedTextCellIdentifier];
        dtCell.textDelegate = self;
        [dtCell.attributedTextContextView setShouldDrawLinks:YES];
        [dtCell.attributedTextContextView setShouldDrawImages:YES];
        [self.cellCache setObject:dtCell forKey:DTAttributedTextCellIdentifier];
    }
    if (self.attrStringInvoiceDesc)
    {
        [dtCell setAttributedString:self.attrStringInvoiceDesc];
    }
    return dtCell;
}

- (void)presentActionSheetForDeliveryTarget:(NSArray *)arrayTarget
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[LocalizedString SelectReceiver] preferredStyle:UIAlertControllerStyleActionSheet];
    __weak ReceiverInfoViewController *weakSelf = self;
    for (NSInteger index = 0; index < [arrayTarget count]; index++)
    {
        NSDictionary *dictionary = [arrayTarget objectAtIndex:index];
        NSString *name = [dictionary objectForKey:SymphoxAPIParam_name];
        UIAlertAction *action = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [weakSelf setCurrentDeliveryTargetForIndex:index];
        }];
        [alertController addAction:action];
    }
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LocalizedString Cancel] style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:actionCancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSString *)totalPhoneNumberForRegion:(NSString *)regionNumber phoneNumber:(NSString *)phoneNumber andSpecificNumber:(NSString *)specificNumber
{
    NSMutableString *totalString = [NSMutableString string];
    if (regionNumber && [regionNumber isEqual:[NSNull null]] == NO && [regionNumber length] > 0)
    {
        [totalString appendString:regionNumber];
    }
    if (phoneNumber && [phoneNumber isEqual:[NSNull null]] == NO && [phoneNumber length] > 0)
    {
        [totalString appendString:@"-"];
        [totalString appendString:phoneNumber];
    }
    if (specificNumber && [specificNumber isEqual:[NSNull null]] == NO && [specificNumber length] > 0)
    {
        [totalString appendString:@"-"];
        [totalString appendString:specificNumber];
    }
    return totalString;
}

- (NSDictionary *)componentsOfPhoneNumber:(NSString *)phoneNumber
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *components = [phoneNumber componentsSeparatedByString:@"-"];
    if ([components count] == 1)
    {
        NSString *phone = [components objectAtIndex:0];
        [dictionary setObject:phone forKey:SymphoxAPIParam_tel_num];
    }
    else
    {
        for (NSInteger index = 0; index < [components count]; index++)
        {
            NSString *text = [components objectAtIndex:index];
            switch (index) {
                case 0:
                {
                    [dictionary setObject:text forKey:SymphoxAPIParam_tel_area];
                }
                    break;
                case 1:
                {
                    [dictionary setObject:text forKey:SymphoxAPIParam_tel_num];
                }
                    break;
                case 2:
                {
                    [dictionary setObject:text forKey:SymphoxAPIParam_tel_ex];
                }
                    break;
                default:
                    break;
            }
        }
    }
    return dictionary;
}

- (void)prepareOrderData
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 1;
    if (tableView == self.tableViewInfo)
    {
        numberOfSections = [self.arraySectionContent count];
    }
    else if (tableView == self.tableViewInvoice)
    {
        NSArray *arraySections = [self currentInvoiceSections];
        numberOfSections = [arraySections count];
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if (tableView == self.tableViewInfo)
    {
        if (section < [self.arraySectionContent count])
        {
            NSArray *content = [self.arraySectionContent objectAtIndex:section];
            numberOfRows = [content count];
        }
    }
    else if (tableView == self.tableViewInvoice)
    {
        NSArray *arraySectionContent = [self currentInvoiceCellsForSection:section];
        if (arraySectionContent)
        {
            numberOfRows = [arraySectionContent count];
        }
    }
    return numberOfRows;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = nil;
    if (tableView == self.tableViewInfo)
    {
        SingleLabelHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:SingleLabelHeaderViewIdentifier];
        view.tag = section;
        switch (section) {
            case SectionIndexInfo:
            {
                view.label.text = [LocalizedString ReceiverInfo];
            }
                break;
            case SectionIndexDelivery:
            {
                view.label.text = [LocalizedString ReceiverAddress];
            }
                break;
            default:
                break;
        }
        headerView = view;
    }
    else if (tableView == self.tableViewInvoice)
    {
        SingleLabelHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:SingleLabelHeaderViewIdentifier];
        view.delegate = self;
        view.backgroundColor = [UIColor orangeColor];
        if (section == 3)
        {
            view.label.text = [LocalizedString InvoiceDeliverAddress];
            view.buttonTitle = [LocalizedString SameAsReceiver];
        }
        headerView = view;
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView == self.tableViewInfo)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:ReceiverInfoCellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = indexPath.row;
        ReceiverInfoCell *infoCell = (ReceiverInfoCell *)cell;
        if (infoCell.delegate == nil)
        {
            infoCell.delegate = self;
        }
        infoCell.parentTableView = tableView;
        infoCell.indexPath = indexPath;
        infoCell.accessoryTitle = nil;
        NSArray *sectionContent = [self.arraySectionContent objectAtIndex:indexPath.section];
        NSNumber *number = [sectionContent objectAtIndex:indexPath.row];
        switch (indexPath.section) {
            case SectionIndexInfo:
            {
                switch ([number integerValue]) {
                    case InfoCellTagReceiverName:
                    {
                        infoCell.labelTitle.text = [LocalizedString Receiver];
                        NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_name];
                        if (text == nil)
                        {
                            infoCell.labelContent.text = [LocalizedString PleaseInputName];
                        }
                        else
                        {
                            infoCell.labelContent.text = text;
                        }
                    }
                        break;
                    case InfoCellTagCellPhone:
                    {
                        infoCell.labelTitle.text = [LocalizedString CellPhone];
                        NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_cellphone];
                        if (text == nil)
                        {
                            infoCell.labelContent.text = [LocalizedString PleaseInputCellPhoneNumber];
                        }
                        else
                        {
                            infoCell.labelContent.text = text;
                        }
                    }
                        break;
                    case InfoCellTagDayPhone:
                    {
                        infoCell.labelTitle.text = [LocalizedString DayPhone];
                        NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_day_tel];
                        if (text == nil)
                        {
                            infoCell.labelContent.text = [LocalizedString PleaseInputPhoneNumber];
                        }
                        else
                        {
                            infoCell.labelContent.text = text;
                        }
                        infoCell.accessoryTitle = [LocalizedString SameAsCellPhone];
                    }
                        break;
                    case InfoCellTagNightPhone:
                    {
                        infoCell.labelTitle.text = [LocalizedString NightPhone];
                        NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_night_tel];
                        if (text == nil)
                        {
                            infoCell.labelContent.text = [LocalizedString PleaseInputPhoneNumber];
                        }
                        else
                        {
                            infoCell.labelContent.text = text;
                        }
                        infoCell.accessoryTitle = [LocalizedString SameAsCellPhone];
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case SectionIndexDelivery:
            {
                switch ([number integerValue]) {
                    case DeliveryCellTagCity:
                    {
                        infoCell.labelTitle.text = [LocalizedString DeliveryCity];
                        if (self.currentCity)
                        {
                            infoCell.labelContent.text = self.currentCity;
                        }
                        else
                        {
                            infoCell.labelContent.text = [LocalizedString PleaseSelectCity];
                        }
                    }
                        break;
                    case DeliveryCellTagRegion:
                    {
                        infoCell.labelTitle.text = [LocalizedString DeliveryRegion];
                        if (self.currentRegion)
                        {
                            infoCell.labelContent.text = self.currentRegion;
                        }
                        else
                        {
                            infoCell.labelContent.text = [LocalizedString PleaseSelectRegion];
                        }
                    }
                        break;
                    case DeliveryCellTagAddress:
                    {
                        infoCell.labelTitle.text  = [LocalizedString Address];
                        NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_address];
                        if (text == nil)
                        {
                            infoCell.labelContent.text = [LocalizedString PleaseInputAddress];
                        }
                        else
                        {
                            infoCell.labelContent.text = text;
                        }
                    }
                        break;
                    case DeliveryCellTagDeliverTime:
                    {
                        infoCell.labelTitle.text = [LocalizedString DeliveryTime];
                        NSString *text = nil;
                        if (self.selectedDeliverTimeIndex < [self.arrayDeliverTime count])
                        {
                            text = [self.arrayDeliverTime objectAtIndex:self.selectedDeliverTimeIndex];
                        }
                        if (text)
                        {
                            infoCell.labelContent.text = text;
                        }
                        else
                        {
                            infoCell.labelContent.text = [LocalizedString PleaseSelectDeliveryTime];
                        }
                    }
                        break;
                    case DeliveryCellTagNote:
                    {
                        infoCell.labelTitle.text = [LocalizedString Note];
                        NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_notes];
                        if (text == nil)
                        {
                            infoCell.labelContent.text = [LocalizedString PleaseInputNote];
                        }
                        else
                        {
                            infoCell.labelContent.text = text;
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            default:
                break;
        }
        [infoCell setNeedsLayout];
    }
    else if (tableView == self.tableViewInvoice)
    {
        InvoiceCellTag cellTag = [self cellTagForInvoiceIndexPath:indexPath];
        if (cellTag == InvoiceCellTagInvoiceDesc)
        {
            cell = [self tableView:tableView preparedCellForIndexPath:indexPath];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:ReceiverInfoCellIdentifier forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            ReceiverInfoCell *infoCell = (ReceiverInfoCell *)cell;
            if (infoCell.delegate == nil)
            {
                infoCell.delegate = self;
            }
            infoCell.parentTableView = tableView;
            infoCell.indexPath = indexPath;
            infoCell.accessoryTitle = nil;
            switch (cellTag) {
                case InvoiceCellTagChooseType:
                {
                    infoCell.labelTitle.text = [LocalizedString InvoiceType];
                    if (self.currentInvoiceType < [self.arrayInvoiceTypeTitle count])
                    {
                        NSString *text = [self.arrayInvoiceTypeTitle objectAtIndex:self.currentInvoiceType];
                        infoCell.labelContent.text = text;
                    }
                    else
                    {
                        infoCell.labelContent.text = [LocalizedString PleaseSelect];
                    }
                }
                    break;
                case InvoiceCellTagChooseElectronicType:
                {
                    infoCell.labelTitle.text = [LocalizedString ElectronicInvoiceCarrier];
                    if (self.invoiceElectronicSubType < [self.arrayElectronicSubTypeTitle count])
                    {
                        NSString *text = [self.arrayElectronicSubTypeTitle objectAtIndex:self.invoiceElectronicSubType];
                        infoCell.labelContent.text = text;
                    }
                    else
                    {
                        infoCell.labelContent.text = [LocalizedString PleaseSelect];
                    }
                }
                    break;
                case InvoiceCellTagChooseDonateTarget:
                {
                    infoCell.labelTitle.text = [LocalizedString DonateTarget];
                    if (self.invoiceDonateTarget < [self.arrayInvoiceDonateTitle count])
                    {
                        NSString *text = [self.arrayInvoiceDonateTitle objectAtIndex:self.invoiceDonateTarget];
                        infoCell.labelContent.text = text;
                    }
                    else
                    {
                        infoCell.labelContent.text = [LocalizedString PleaseSelect];
                    }
                }
                    break;
                case InvoiceCellTagElectronicCode:
                {
                    NSString *title = nil;
                    if (self.invoiceElectronicSubType == InvoiceElectronicSubTypeNaturalPerson)
                    {
                        title = [LocalizedString CertificateID];
                    }
                    else if (self.invoiceElectronicSubType == InvoiceElectronicSubTypeCellphoneBarcode)
                    {
                        title = [LocalizedString CellphoneBarcode];
                    }
                    if (title)
                    {
                        infoCell.labelTitle.text = title;
                    }
                    NSString *text = [self.dictionaryInvoiceTemp objectForKey:SymphoxAPIParam_icarrier_id];
                    if (text)
                    {
                        infoCell.labelContent.text = text;
                    }
                    else
                    {
                        infoCell.labelContent.text = [LocalizedString PleaseInput];
                    }
                    infoCell.accessoryTitle = [LocalizedString SampleImage];
                }
                    break;
                case InvoiceCellTagDonateCode:
                {
                    infoCell.labelTitle.text = [LocalizedString HeartCode];
                    NSString *text = [self.dictionaryInvoiceTemp objectForKey:SymphoxAPIParam_inpoban];
                    if (text)
                    {
                        infoCell.labelContent.text = text;
                    }
                    else
                    {
                        infoCell.labelContent.text = [LocalizedString PleaseInput];
                    }
                }
                    break;
                case InvoiceCellTagInvoiceTitle:
                {
                    infoCell.labelTitle.text = [LocalizedString InvoiceTitle];
                    NSString *text = [self.dictionaryInvoiceTemp objectForKey:SymphoxAPIParam_inv_title];
                    if (text)
                    {
                        infoCell.labelContent.text = text;
                    }
                    else
                    {
                        infoCell.labelContent.text = [LocalizedString PleaseInput];
                    }
                }
                    break;
                case InvoiceCellTagInvoiceIdentifier:
                {
                    infoCell.labelTitle.text = [LocalizedString UnifiedNumber];
                    NSString *text = [self.dictionaryInvoiceTemp objectForKey:SymphoxAPIParam_inv_regno];
                    if (text)
                    {
                        infoCell.labelContent.text = text;
                    }
                    else
                    {
                        infoCell.labelContent.text = [LocalizedString PleaseInput];
                    }
                }
                    break;
                case InvoiceCellTagReceiver:
                {
                    infoCell.labelTitle.text = [LocalizedString InvoiceReceiver];
                    NSString *text = [self.dictionaryInvoiceTemp objectForKey:SymphoxAPIParam_inv_name];
                    if (text)
                    {
                        infoCell.labelContent.text = text;
                    }
                    else
                    {
                        infoCell.labelContent.text = [LocalizedString PleaseInput];
                    }
                }
                    break;
                case InvoiceCellTagCity:
                {
                    infoCell.labelTitle.text = [LocalizedString DeliveryCity];
                    if (self.currentInvoiceCity)
                    {
                        infoCell.labelContent.text = self.currentInvoiceCity;
                    }
                    else
                    {
                        infoCell.labelContent.text = [LocalizedString PleaseSelectCity];
                    }
                }
                    break;
                case InvoiceCellTagRegion:
                {
                    infoCell.labelTitle.text = [LocalizedString DeliveryRegion];
                    if (self.currentInvoiceRegion)
                    {
                        infoCell.labelContent.text = self.currentInvoiceRegion;
                    }
                    else
                    {
                        infoCell.labelContent.text = [LocalizedString PleaseSelectRegion];
                    }
                }
                    break;
                case InvoiceCellTagAddress:
                {
                    infoCell.labelTitle.text = [LocalizedString Address];
                    NSString *text = [self.dictionaryInvoiceTemp objectForKey:SymphoxAPIParam_inv_address];
                    if (text)
                    {
                        infoCell.labelContent.text = text;
                    }
                    else
                    {
                        infoCell.labelContent.text = [LocalizedString PleaseInput];
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat heightForHeader = 0.0;
    if (tableView == self.tableViewInfo)
    {
        switch (section) {
            case SectionIndexDelivery:
            {
                heightForHeader = 30.0;
            }
                break;
                
            default:
                break;
        }
    }
    else if (tableView == self.tableViewInvoice)
    {
        if (section == 3)
        {
            heightForHeader = 30.0;
        }
    }
    return heightForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow = 0.0;
    if (tableView == self.tableViewInfo)
    {
        heightForRow = 40.0;
    }
    else if (tableView == self.tableViewInvoice)
    {
        InvoiceCellTag cellTag = [self cellTagForInvoiceIndexPath:indexPath];
        if (cellTag == InvoiceCellTagInvoiceDesc)
        {
            DTAttributedTextCell *cell = (DTAttributedTextCell *)[self tableView:tableView preparedCellForIndexPath:indexPath];
            heightForRow = [cell requiredRowHeightInTableView:tableView];
        }
        else
        {
            heightForRow = 40.0;
        }
    }
    return heightForRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewInfo)
    {
        NSArray *sectionContent = [self.arraySectionContent objectAtIndex:indexPath.section];
        NSNumber *number = [sectionContent objectAtIndex:indexPath.row];
        switch (indexPath.section) {
            case SectionIndexInfo:
            {
                switch ([number integerValue]) {
                    case InfoCellTagReceiverName:
                    {
                        NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_name];
                        [self presentAlertMessage:[LocalizedString PleaseInputName] forIndexPath:indexPath withTextFieldDefaultText:text andKeyboardType:UIKeyboardTypeDefault fromTableView:tableView];
                    }
                        break;
                    case InfoCellTagCellPhone:
                    {
                        NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_cellphone];
                        [self presentAlertMessage:[LocalizedString PleaseInputPhoneNumber] forIndexPath:indexPath withTextFieldDefaultText:text andKeyboardType:UIKeyboardTypePhonePad fromTableView:tableView];
                    }
                        break;
                    case InfoCellTagDayPhone:
                    {
                        NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_day_tel];
                        NSDictionary *dictionary = [self componentsOfPhoneNumber:text];
                        NSString *region = [dictionary objectForKey:SymphoxAPIParam_tel_area];
                        NSString *phone = [dictionary objectForKey:SymphoxAPIParam_tel_num];
                        NSString *specific = [dictionary objectForKey:SymphoxAPIParam_tel_ex];
                        [self presentPhoneInputAlertMessage:[LocalizedString PleaseInputPhoneNumber] forIndexPath:indexPath withRegionNumber:region phoneNumber:phone andSpecificNumber:specific fromTableView:tableView];
                    }
                        break;
                    case InfoCellTagNightPhone:
                    {
                        NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_night_tel];
                        NSDictionary *dictionary = [self componentsOfPhoneNumber:text];
                        NSString *region = [dictionary objectForKey:SymphoxAPIParam_tel_area];
                        NSString *phone = [dictionary objectForKey:SymphoxAPIParam_tel_num];
                        NSString *specific = [dictionary objectForKey:SymphoxAPIParam_tel_ex];
                        [self presentPhoneInputAlertMessage:[LocalizedString PleaseInputPhoneNumber] forIndexPath:indexPath withRegionNumber:region phoneNumber:phone andSpecificNumber:specific fromTableView:tableView];
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case SectionIndexDelivery:
            {
                switch ([number integerValue]) {
                    case DeliveryCellTagCity:
                    {
                        [self presentActionsheetWithMessage:[LocalizedString PleaseSelectCity] forIndexPath:indexPath withOptions:self.arrayCity fromTableView:tableView];
                    }
                        break;
                    case DeliveryCellTagRegion:
                    {
                        if (self.currentCity)
                        {
                            NSArray *regions = [self.dictionaryRegionsForCity objectForKey:self.currentCity];
                            if (regions && [regions count] > 0)
                            {
                                [self presentActionsheetWithMessage:[LocalizedString PleaseSelectRegion] forIndexPath:indexPath withOptions:regions fromTableView:tableView];
                            }
                        }
                    }
                        break;
                    case DeliveryCellTagAddress:
                    {
                        NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_address];
                        [self presentAlertMessage:[LocalizedString PleaseInputAddress] forIndexPath:indexPath withTextFieldDefaultText:text andKeyboardType:UIKeyboardTypeDefault fromTableView:tableView];
                    }
                        break;
                    case DeliveryCellTagDeliverTime:
                    {
                        if (self.arrayDeliverTime && [self.arrayDeliverTime count] > 0)
                        {
                            [self presentActionsheetWithMessage:[LocalizedString PleaseSelectDeliveryTime] forIndexPath:indexPath withOptions:self.arrayDeliverTime fromTableView:tableView];
                        }
                    }
                        break;
                    case DeliveryCellTagNote:
                    {
                        NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_notes];
                        [self presentAlertMessage:[LocalizedString PleaseInputNote] forIndexPath:indexPath withTextFieldDefaultText:text andKeyboardType:UIKeyboardTypeDefault fromTableView:tableView];
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            default:
                break;
        }
    }
    else if (tableView == self.tableViewInvoice)
    {
        InvoiceCellTag cellTag = [self cellTagForInvoiceIndexPath:indexPath];
        switch (cellTag) {
            case InvoiceCellTagChooseType:
            {
                [self presentActionsheetWithMessage:nil forIndexPath:indexPath withOptions:self.arrayInvoiceTypeTitle fromTableView:tableView];
            }
                break;
            case InvoiceCellTagChooseElectronicType:
            {
                [self presentActionsheetWithMessage:nil forIndexPath:indexPath withOptions:self.arrayElectronicSubTypeTitle fromTableView:tableView];
            }
                break;
            case InvoiceCellTagElectronicCode:
            {
                NSString *message = nil;
                if (self.invoiceElectronicSubType == InvoiceElectronicSubTypeNaturalPerson)
                {
                    message = [LocalizedString CertificateID];
                }
                else if (self.invoiceElectronicSubType == InvoiceElectronicSubTypeCellphoneBarcode)
                {
                    message = [LocalizedString CellphoneBarcode];
                }
                [self presentAlertMessage:message forIndexPath:indexPath withTextFieldDefaultText:nil andKeyboardType:UIKeyboardTypeASCIICapableNumberPad fromTableView:tableView];
            }
                break;
            case InvoiceCellTagChooseDonateTarget:
            {
                [self presentActionsheetWithMessage:nil forIndexPath:indexPath withOptions:self.arrayInvoiceDonateTitle fromTableView:tableView];
            }
                break;
            case InvoiceCellTagDonateCode:
            {
                [self presentAlertMessage:[LocalizedString HeartCode] forIndexPath:indexPath withTextFieldDefaultText:nil andKeyboardType:UIKeyboardTypeNumberPad fromTableView:tableView];
            }
                break;
            case InvoiceCellTagInvoiceTitle:
            {
                [self presentAlertMessage:[LocalizedString InvoiceTitle] forIndexPath:indexPath withTextFieldDefaultText:nil andKeyboardType:UIKeyboardTypeDefault fromTableView:tableView];
            }
                break;
            case InvoiceCellTagInvoiceIdentifier:
            {
                [self presentAlertMessage:[LocalizedString UnifiedNumber] forIndexPath:indexPath withTextFieldDefaultText:nil andKeyboardType:UIKeyboardTypeASCIICapableNumberPad fromTableView:tableView];
            }
                break;
            case InvoiceCellTagReceiver:
            {
                [self presentAlertMessage:[LocalizedString InvoiceReceiver] forIndexPath:indexPath withTextFieldDefaultText:nil andKeyboardType:UIKeyboardTypeDefault fromTableView:tableView];
            }
                break;
            case InvoiceCellTagCity:
            {
                [self presentActionsheetWithMessage:[LocalizedString PleaseSelectCity] forIndexPath:indexPath withOptions:self.arrayCity fromTableView:tableView];
            }
                break;
            case InvoiceCellTagRegion:
            {
                if (self.currentInvoiceCity)
                {
                    NSArray *regions = [self.dictionaryRegionsForCity objectForKey:self.currentCity];
                    if (regions && [regions count] > 0)
                    {
                        [self presentActionsheetWithMessage:[LocalizedString PleaseSelectRegion] forIndexPath:indexPath withOptions:regions fromTableView:tableView];
                    }
                }
            }
                break;
            case InvoiceCellTagAddress:
            {
                [self presentAlertMessage:[LocalizedString PleaseInputAddress] forIndexPath:indexPath withTextFieldDefaultText:nil andKeyboardType:UIKeyboardTypeDefault fromTableView:tableView];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - Actions

- (void)buttonContactListPressed:(id)sender
{
    NSLog(@"self.arrayDeliveryList:\n%@", [self.arrayDeliveryList description]);
    [self presentActionSheetForDeliveryTarget:self.arrayDeliveryList];
}

- (void)buttonNextPressed:(id)sender
{
    [self prepareOrderData];
}

- (void)buttonLinkPressed:(id)sender
{
    if ([sender isKindOfClass:[DTLinkButton class]] == NO)
        return;
    DTLinkButton *buttonLink = (DTLinkButton *)sender;
    NSURL *url = buttonLink.URL;
    if (url == nil)
        return;
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)linkLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        DTLinkButton *button = (id)[gestureRecognizer view];
        button.highlighted = NO;
        
        if ([[UIApplication sharedApplication] canOpenURL:[button.URL absoluteURL]])
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *actionOpenInSafari = [UIAlertAction actionWithTitle:[LocalizedString OpenInSafari] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [[UIApplication sharedApplication] openURL:button.URL];
            }];
            UIAlertAction *actionCopyLink = [UIAlertAction actionWithTitle:[LocalizedString CopyLink] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                NSString *urlString = [button.URL absoluteString];
                if (urlString)
                {
                    [[UIPasteboard generalPasteboard] setString:[button.URL absoluteString]];
                }
            }];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:[LocalizedString Cancel] style:UIAlertActionStyleDestructive handler:nil];
            [alertController addAction:actionOpenInSafari];
            [alertController addAction:actionCopyLink];
            [alertController addAction:actionCancel];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

#pragma mark - ReceiverInfoCellDelegate

- (void)receiverInfoCell:(ReceiverInfoCell *)cell didPressAccessoryView:(UIButton *)accessoryView
{
    if (cell.parentTableView == self.tableViewInfo)
    {
        switch (cell.tag) {
            case InfoCellTagDayPhone:
            {
                NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_cellphone];
                if (text != nil)
                {
                    [self.currentDeliveryTarget setObject:text forKey:SymphoxAPIParam_day_tel];
                }
                [self.tableViewInfo reloadData];
            }
                break;
            case InfoCellTagNightPhone:
            {
                NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_cellphone];
                if (text != nil)
                {
                    [self.currentDeliveryTarget setObject:text forKey:SymphoxAPIParam_night_tel];
                }
                [self.tableViewInfo reloadData];
            }
                break;
            default:
                break;
        }
    }
    else if (cell.parentTableView == self.tableViewInvoice && cell.indexPath != nil)
    {
        InvoiceCellTag cellTag = [self cellTagForInvoiceIndexPath:cell.indexPath];
        if (cellTag == InvoiceCellTagElectronicCode)
        {
            UIImage *image = nil;
            if (self.invoiceElectronicSubType == InvoiceElectronicSubTypeNaturalPerson)
            {
                image = [UIImage imageNamed:@"carrier_citizen"];
                
            }
            else if (self.invoiceElectronicSubType == InvoiceElectronicSubTypeCellphoneBarcode)
            {
                image = [UIImage imageNamed:@"cellphone"];
            }
            if (image)
            {
                SampleImageViewController *viewController = [[SampleImageViewController alloc] initWithNibName:nil bundle:nil];
                [viewController.buttonImage setImage:image forState:UIControlStateNormal];
                viewController.preferredContentSize = image.size;
                viewController.modalPresentationStyle = UIModalPresentationPopover;
                UIPopoverPresentationController *presentationController = viewController.popoverPresentationController;
                presentationController.sourceView = cell;
                presentationController.sourceRect = cell.button.frame;
                presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
                presentationController.delegate = self;
                [self presentViewController:viewController animated:YES completion:nil];
            }
        }
    }
}

#pragma mark - DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame
{
    NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
    
    NSURL *URL = [attributes objectForKey:DTLinkAttribute];
    NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
    
    
    DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
    button.URL = URL;
    button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
    button.GUID = identifier;
    
    // get image with normal link text
    UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
    [button setImage:normalImage forState:UIControlStateNormal];
    
    // get image for highlighted link text
    UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    
    // use normal push action for opening URL
    [button addTarget:self action:@selector(buttonLinkPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // demonstrate combination with long press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
    [button addGestureRecognizer:longPress];
    
    return button;
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - SingleLabelHeaderViewDelegate

- (void)singleLabelHeaderView:(SingleLabelHeaderView *)headerView didPressButton:(id)sender
{
    if (self.currentCity)
    {
        self.currentInvoiceCity = self.currentCity;
    }
    if (self.currentRegion)
    {
        self.currentInvoiceRegion = self.currentRegion;
    }
    NSString *text = [self.currentDeliveryTarget objectForKey:SymphoxAPIParam_address];
    if (text)
    {
        [self.dictionaryInvoiceTemp setObject:text forKey:SymphoxAPIParam_inv_address];
    }
    [self.tableViewInvoice reloadData];
}

@end
