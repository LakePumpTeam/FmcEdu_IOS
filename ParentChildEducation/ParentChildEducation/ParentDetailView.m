//
//  ParentDetailView.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/16.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "ParentDetailView.h"

typedef NS_ENUM(NSInteger, ControllTag) {
    eProvTag = 1,
    eCityTag,
    eSchoolTag,
    eClassTag,
    eHeadTeacherTag,
    eStudentNameTag,
    eStudentSexTag,
    eStudentAgeTag,
    eParentNameTag,
    eParentPhoneTag,
    eParentChildRelationTag,
    eAddressTag,
    eBraceletCardNumTag,
    eBraceletNumTag,
    
};

#define kItemHeight             30
#define kMarginV                8

@implementation ParentDetailView

- (id)initWithParentInfo:(ParentRelateInfoResult *)parentInfo
{
    self = [super init];
    
    if (self)
    {
        _parentInfo = parentInfo;
    
        // 布局界面
        [self setupSuspendedView];
        [self setFrame:[UIScreen mainScreen].bounds];
        
        // 关闭手势
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        [_tapGestureRecognizer setDelegate:self];
        
        [self addGestureRecognizer:_tapGestureRecognizer];
    }
    
    return self;
}

- (void)setupSuspendedView
{
    // =======================================================================
    // 游标
    // =======================================================================
    NSInteger spaceXStart = 20;
    NSInteger spaceYStart = kNavigationBarHeight;
    
    // =======================================================================
    // 底层半透明浮窗
    // =======================================================================
    
    CGSize suspendedViewSize = [UIScreen mainScreen].bounds.size;
    _suspendView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, suspendedViewSize.width, suspendedViewSize.height)];
    
    [_suspendView setBackgroundColor:[UIColor colorWithHex:0x333333 alpha:0.5f]];
    
    // 添加
    [_suspendView setUserInteractionEnabled:NO];
    [self addSubview:_suspendView];
    
    // =======================================================================
    // _scrollView
    // =======================================================================

    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setFrame:CGRectMake(spaceXStart, spaceYStart+30, kScreenWidth-spaceXStart*2, kScreenHeight-spaceYStart-30*2)];

    CGSize scrollSize = CGSizeMake(kScreenWidth-spaceXStart*2, 0);
    // 子View
    [self setupSuspendedScrollViewSubs:_scrollView inSize:&scrollSize];
    
    [_scrollView setContentSize:scrollSize];
    [_scrollView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    
    [self addSubview:_scrollView];
    
    if (scrollSize.height < kScreenHeight-spaceYStart-30*2)
    {
        [_scrollView setFrame:CGRectMake(spaceXStart, spaceYStart+30, kScreenWidth-spaceXStart*2, scrollSize.height)];
    }
}

- (void)setupSuspendedScrollViewSubs:(UIView *)viewParent inSize:(CGSize *)inSize
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 10;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFont:kMiddleTitleFont andText:@"家长详细信息" andColor:kWhiteColor];
    titleLabel.backgroundColor = kBackgroundGreenColor;
    titleLabel.frame = CGRectMake(0, spaceYStart, kScreenWidth-spaceXStart*2, 40);
    
    [viewParent addSubview:titleLabel];
    
    // 调整Y
    spaceYStart += titleLabel.height;
    spaceYStart += 10;
    // =======================================================================
    // 省份
    // =======================================================================
    NSString *provString = [NSString stringWithFormat:@"%@%@", @"省份：", _parentInfo.provName];
    
    UILabel *provLabel = (UILabel *)[viewParent viewWithTag:eProvTag];
    if (provLabel == nil) {
        provLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:provString andColor:kTextColor];
        provLabel.textAlignment = NSTextAlignmentLeft;
        provLabel.tag = eProvTag;
        
        [viewParent addSubview:provLabel];
    }
    CGSize provSize = [provString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewParent.width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    provLabel.frame = CGRectMake(spaceXStart, spaceYStart, provSize.width, provSize.height);
    provLabel.text = provString;
    
    
    // 调整Y
    spaceYStart += provLabel.height;
    spaceYStart += kMarginV;

    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // 调整Y
    spaceYStart += 1;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 城市
    // =======================================================================
    NSString *cityString = [NSString stringWithFormat:@"%@%@", @"城市：", _parentInfo.cityName];
    
    UILabel *cityLabel = (UILabel *)[viewParent viewWithTag:eCityTag];
    if (cityLabel == nil)
    {
        cityLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:cityString andColor:kTextColor];
        cityLabel.textAlignment = NSTextAlignmentLeft;
        cityLabel.tag = eCityTag;
        
        [viewParent addSubview:cityLabel];

    }
    CGSize citySize = [cityString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewParent.width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    cityLabel.frame = CGRectMake(spaceXStart, spaceYStart, citySize.width, citySize.height);
    cityLabel.text = cityString;

    
    // 调整Y
    spaceYStart += cityLabel.height;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine1 = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine1];
    
    // 调整Y
    spaceYStart += 1;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 学校
    // =======================================================================

    NSString *schoolString = [NSString stringWithFormat:@"%@%@", @"学校：", _parentInfo.schoolName];
    
    UILabel *schoolLabel = (UILabel *)[viewParent viewWithTag:eSchoolTag];
    if (schoolLabel == nil)
    {
        schoolLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:provString andColor:kTextColor];
        schoolLabel.textAlignment = NSTextAlignmentLeft;
        schoolLabel.tag = eSchoolTag;
        
        [viewParent addSubview:schoolLabel];

    }
    CGSize schoolSize = [schoolString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewParent.width-spaceXStart*2, CGFLOAT_MAX)lineBreakMode:NSLineBreakByTruncatingTail];
    
    schoolLabel.frame = CGRectMake(spaceXStart, spaceYStart, schoolSize.width, schoolSize.height);
    schoolLabel.text = schoolString;
    
    
    // 调整Y
    spaceYStart += schoolLabel.height;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine2 = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine2];
    
    // 调整Y
    spaceYStart += 1;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 班级
    // =======================================================================
    NSString *classString = [NSString stringWithFormat:@"%@%@", @"班级：", _parentInfo.className];
    
    UILabel *classLabel = (UILabel *)[viewParent viewWithTag:eClassTag];
    if (classLabel == nil)
    {
        classLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:provString andColor:kTextColor];
        classLabel.textAlignment = NSTextAlignmentLeft;
        classLabel.tag = eClassTag;
        
        [viewParent addSubview:classLabel];

    }
    CGSize classSize = [classString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewParent.width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    classLabel.frame = CGRectMake(spaceXStart, spaceYStart, classSize.width, classSize.height);
    classLabel.text = classString;
    
    
    // 调整Y
    spaceYStart += classLabel.height;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine3 = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine3];
    
    // 调整Y
    spaceYStart += 1;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 班主任
    // =======================================================================
    NSString *headTeacherString = [NSString stringWithFormat:@"%@%@", @"班主任：", _parentInfo.teacherName];
    
    UILabel *headTeacherLabel = (UILabel *)[viewParent viewWithTag:eHeadTeacherTag];
    if (headTeacherLabel == nil)
    {
        headTeacherLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:provString andColor:kTextColor];
        headTeacherLabel.textAlignment = NSTextAlignmentLeft;
        headTeacherLabel.tag = eHeadTeacherTag;
        
        [viewParent addSubview:headTeacherLabel];
        
    }
    CGSize headTeacherSize = [headTeacherString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewParent.width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    headTeacherLabel.frame = CGRectMake(spaceXStart, spaceYStart, headTeacherSize.width, headTeacherSize.height);
    headTeacherLabel.text = headTeacherString;
    
    
    // 调整Y
    spaceYStart += headTeacherLabel.height;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine4 = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine4];
    
    // 调整Y
    spaceYStart += 1;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 学生姓名
    // =======================================================================
    NSString *studentNameString = [NSString stringWithFormat:@"%@%@", @"学生姓名：", _parentInfo.studentName];
    
    UILabel *studentNameLabel = (UILabel *)[viewParent viewWithTag:eStudentNameTag];
    if (studentNameLabel == nil)
    {
        studentNameLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:provString andColor:kTextColor];
        studentNameLabel.textAlignment = NSTextAlignmentLeft;
        studentNameLabel.tag = eStudentNameTag;
        
        [viewParent addSubview:studentNameLabel];
        
    }
    CGSize studentNameSize = [studentNameString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewParent.width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    studentNameLabel.frame = CGRectMake(spaceXStart, spaceYStart, studentNameSize.width, studentNameSize.height);
    studentNameLabel.text = studentNameString;
    
    
    // 调整Y
    spaceYStart += studentNameLabel.height;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine5 = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine5];
    
    // 调整Y
    spaceYStart += 1;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 学生性别
    // =======================================================================
    NSString *studentSexString = [NSString stringWithFormat:@"%@%@", @"学生性别：", _parentInfo.studentSex];
    
    UILabel *studentSexLabel = (UILabel *)[viewParent viewWithTag:eStudentSexTag];
    if (studentSexLabel == nil)
    {
        studentSexLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:provString andColor:kTextColor];
        studentSexLabel.textAlignment = NSTextAlignmentLeft;
        studentSexLabel.tag = eStudentSexTag;
        
        [viewParent addSubview:studentSexLabel];
        
    }
    CGSize studentSexSize = [studentSexString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewParent.width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    studentSexLabel.frame = CGRectMake(spaceXStart, spaceYStart, studentSexSize.width, studentSexSize.height);
    studentSexLabel.text = studentSexString;
    
    
    // 调整Y
    spaceYStart += studentSexLabel.height;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine6 = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine6];
    
    // 调整Y
    spaceYStart += 1;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 学生出生日期
    // =======================================================================
    NSString *studentBirthString = [NSString stringWithFormat:@"%@%@", @"学生出生日期：", _parentInfo.studentBirth];
    
    UILabel *studentBirthLabel = (UILabel *)[viewParent viewWithTag:eStudentAgeTag];
    if (studentBirthLabel == nil)
    {
        studentBirthLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:provString andColor:kTextColor];
        studentBirthLabel.textAlignment = NSTextAlignmentLeft;
        studentBirthLabel.tag = eStudentAgeTag;
        
        [viewParent addSubview:studentBirthLabel];
        
    }
    CGSize studentBirthSize = [studentBirthString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewParent.width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    studentBirthLabel.frame = CGRectMake(spaceXStart, spaceYStart, studentBirthSize.width, studentBirthSize.height);
    studentBirthLabel.text = studentBirthString;
    
    
    // 调整Y
    spaceYStart += studentBirthLabel.height;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine7 = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine7];
    
    // 调整Y
    spaceYStart += 1;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 家长姓名
    // =======================================================================
    NSString *parentNameString = [NSString stringWithFormat:@"%@%@", @"家长姓名：", _parentInfo.parentName];
    
    UILabel *parentNameLabel = (UILabel *)[viewParent viewWithTag:eParentNameTag];
    if (parentNameLabel == nil)
    {
        parentNameLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:provString andColor:kTextColor];
        parentNameLabel.textAlignment = NSTextAlignmentLeft;
        parentNameLabel.tag = eParentNameTag;
        [viewParent addSubview:parentNameLabel];
        
    }
    CGSize parentNameSize = [parentNameString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewParent.width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    parentNameLabel.frame = CGRectMake(spaceXStart, spaceYStart, parentNameSize.width, parentNameSize.height);
    parentNameLabel.text = parentNameString;
    
    
    // 调整Y
    spaceYStart += parentNameLabel.height;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine8 = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine8];
    
    // 调整Y
    spaceYStart += 1;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 家长电话
    // =======================================================================
    NSString *cellPhoneString = [NSString stringWithFormat:@"%@%@", @"家长电话：", _parentInfo.cellPhone];
    
    UILabel *cellPhoneLabel = (UILabel *)[viewParent viewWithTag:eParentPhoneTag];
    if (cellPhoneLabel == nil)
    {
        cellPhoneLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:provString andColor:kTextColor];
        cellPhoneLabel.textAlignment = NSTextAlignmentLeft;
        cellPhoneLabel.tag = eParentPhoneTag;
        
        [viewParent addSubview:cellPhoneLabel];
        
    }
    CGSize cellPhoneSize = [cellPhoneString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewParent.width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    cellPhoneLabel.frame = CGRectMake(spaceXStart, spaceYStart, cellPhoneSize.width, cellPhoneSize.height);
    cellPhoneLabel.text = cellPhoneString;
    
    
    // 调整Y
    spaceYStart += cellPhoneLabel.height;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine9 = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine9];
    
    // 调整Y
    spaceYStart += 1;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 亲子关系
    // =======================================================================
    NSString *relationString = [NSString stringWithFormat:@"%@%@", @"亲子关系：", _parentInfo.relation];
    
    UILabel *relationLabel = (UILabel *)[viewParent viewWithTag:eParentChildRelationTag];
    if (relationLabel == nil)
    {
        relationLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:provString andColor:kTextColor];
        relationLabel.textAlignment = NSTextAlignmentLeft;
        relationLabel.tag = eParentChildRelationTag;
        
        [viewParent addSubview:relationLabel];
        
    }
    // 重置frame
    CGSize relationSize = [relationString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewParent.width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    relationLabel.frame = CGRectMake(spaceXStart, spaceYStart, relationSize.width, relationSize.height);
    relationLabel.text = relationString;
    
    
    // 调整Y
    spaceYStart += relationLabel.height;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine10 = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine10];
    
    // 调整Y
    spaceYStart += 1;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 家庭地址
    // =======================================================================
    NSString *addressString = [NSString stringWithFormat:@"%@%@", @"家庭地址：", _parentInfo.address];
    
    UILabel *addressLabel = (UILabel *)[viewParent viewWithTag:eAddressTag];
    if (addressLabel == nil)
    {
        addressLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:provString andColor:kTextColor];
        addressLabel.textAlignment = NSTextAlignmentLeft;
        addressLabel.tag = eAddressTag;
        
        [viewParent addSubview:addressLabel];
        
    }
    // 重置frame
    CGSize addressSize = [addressString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewParent.width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    addressLabel.frame = CGRectMake(spaceXStart, spaceYStart, addressSize.width, addressSize.height);
    addressLabel.text = addressString;
    
    
    // 调整Y
    spaceYStart += addressLabel.height;
    spaceYStart += kMarginV;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine11 = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine11];
    
    // 调整Y
    spaceYStart += 1;
    spaceYStart += 2;
    
    // =======================================================================
    // 调整父高度
    // =======================================================================
    spaceYStart += kMarginV;
    
    inSize->height = spaceYStart;
}


- (void)tapView:(UITapGestureRecognizer *)tapGesture
{
    [self removeFromSuperview];
}

@end
