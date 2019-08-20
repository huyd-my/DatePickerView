//
//  ZDBPickerView.m
//  Thor
//
//  Created by 不明下落 on 2019/8/19.
//  Copyright © 2019 erongdu. All rights reserved.
//

#import "ZDBPickerView.h"
#import "ZDBPickerColumnView.h"
#import "UIColor+Palette.h"
#import <Masonry.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define WIDTHRADIUS (kScreenWidth/375.0)

@interface ZDBPickerView ()<ZDBPickerColumnViewDelegate>
{
    ZDBPickerType _type;
    NSArray *_years;
    NSArray *_months;
    NSArray *_days;
}

@property(nonatomic, strong) ZDBPickerColumnView     *yearColumn;
@property(nonatomic, strong) ZDBPickerColumnView     *monthColumn;
@property(nonatomic, strong) ZDBPickerColumnView     *dayColumn;

@end

@implementation ZDBPickerView

- (instancetype)initWithType:(ZDBPickerType)type {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
//        self.clipsToBounds = YES;
//        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
//        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//        maskLayer.frame = self.bounds;
//        maskLayer.path = maskPath.CGPath;
//        self.layer.mask = maskLayer;
        [self createSubview];
    }
    return self;
}

- (void)updateWithType:(ZDBPickerType)type {
    _type = type;
    __weak typeof(self) weakSelf = self;
    if (_type == ZDBPickerTypeYearMonthDay) {
        _dayColumn.hidden = NO;
        CGFloat columnWidth = kScreenWidth / 3;
        [_monthColumn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(63*WIDTHRADIUS);
            make.left.mas_equalTo(weakSelf);
            make.bottom.mas_offset(-44*WIDTHRADIUS);
            make.width.mas_equalTo(columnWidth);
        }];
        [_dayColumn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.width.equalTo(weakSelf.monthColumn);
            make.left.equalTo(weakSelf.monthColumn.mas_right);
        }];
        [_yearColumn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.width.equalTo(weakSelf.monthColumn);
            make.left.equalTo(weakSelf.dayColumn.mas_right);
        }];
    } else {
        _dayColumn.hidden = YES;
        CGFloat columnWidth = kScreenWidth / 2;
        [_yearColumn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(63*WIDTHRADIUS);
            make.left.mas_equalTo(weakSelf);
            make.bottom.mas_offset(-44*WIDTHRADIUS);
            make.width.mas_equalTo(columnWidth);
        }];
        [_monthColumn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(weakSelf.yearColumn);
            make.width.mas_equalTo(columnWidth);
            make.right.equalTo(weakSelf);
        }];
    }
}

- (void)scrollIndexWithMonthIndex:(NSInteger)monthIndex
                         dayIndex:(NSInteger)dayIndex
                        yearIndex:(NSInteger)yearIndex {
    _monthColumn.scrollIndex = monthIndex;
    _dayColumn.scrollIndex = dayIndex;
    _yearColumn.scrollIndex = yearIndex;
}

- (void)scrollIndexWithMonthIndex:(NSInteger)monthIndex
                        yearIndex:(NSInteger)yearIndex {
    _monthColumn.scrollIndex = monthIndex;
    _yearColumn.scrollIndex = yearIndex;
}

- (void)topCancleBtnClick {
    if (self.cancleAction) {
        self.cancleAction();
    }
}

- (void)topSubmitBtnClick {
    if (_type == ZDBPickerTypeYearMonthDay) {
        if (self.submitMDYAction) {
            NSString *dayString = _dayColumn.selectCellTitle;
            NSString *monthString = _monthColumn.selectCellTitle;
            NSString *yearString = _yearColumn.selectCellTitle;
            self.submitMDYAction(monthString, dayString, yearString);
        }
    } else {
        if (self.submitYMAction) {
            NSString *monthString = _monthColumn.selectCellTitle;
            NSString *yearString = _yearColumn.selectCellTitle;
            self.submitYMAction(yearString, monthString);
        }
    }
}

- (void)createSubview {
    UIButton *topCancleBtn = [[UIButton alloc] init];
    topCancleBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:topCancleBtn];
    [topCancleBtn setTitle:@"Cancle" forState:UIControlStateNormal];
    [topCancleBtn setTitleColor:[UIColor colorFromHexString:@"#333333"] forState:UIControlStateNormal];
    [topCancleBtn addTarget:self action:@selector(topCancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *topSubmitBtn = [[UIButton alloc] init];
    topSubmitBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:topSubmitBtn];
    [topSubmitBtn setTitle:@"Submit" forState:UIControlStateNormal];
    [topSubmitBtn setTitleColor:[UIColor colorFromHexString:@"#007aff"] forState:UIControlStateNormal];
    [topSubmitBtn addTarget:self action:@selector(topSubmitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = [UIColor colorFromHexString:@"#cccccc"];
    [self addSubview:topLine];
    
    
    UIView *selectBg = [[UIView alloc] init];
    selectBg.backgroundColor = [UIColor colorFromHexString:@"#f3f9fa"];
    [self addSubview:selectBg];
    
    [topCancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(30);
        make.height.mas_equalTo(50);
        make.top.mas_offset(0);
    }];
    [topSubmitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-30);
        make.height.mas_equalTo(50);
        make.top.mas_offset(0);
    }];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_offset(0);
        make.top.equalTo(topCancleBtn.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    [selectBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topLine.mas_bottom).offset(63*WIDTHRADIUS-50+44);
        make.left.right.mas_offset(0);
        make.height.mas_equalTo(44);
    }];
    
    _yearColumn = [[ZDBPickerColumnView alloc] init];
    _yearColumn.viewDelegate = self;
    [self addSubview:_yearColumn];
    
    _monthColumn = [[ZDBPickerColumnView alloc] init];
    _monthColumn.viewDelegate = self;
    [self addSubview:_monthColumn];
    
    _dayColumn = [[ZDBPickerColumnView alloc] init];
    _dayColumn.viewDelegate = self;
    [self addSubview:_dayColumn];
    
    if (_type == ZDBPickerTypeYearMonthDay) {
        __weak typeof(self) weakSelf = self;
        _dayColumn.hidden = NO;
        CGFloat columnWidth = kScreenWidth / 3;
        [_monthColumn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(63*WIDTHRADIUS);
            make.left.mas_equalTo(weakSelf);
            make.bottom.mas_offset(-44*WIDTHRADIUS);
            make.width.mas_equalTo(columnWidth);
        }];
        [_dayColumn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.width.equalTo(weakSelf.monthColumn);
            make.left.equalTo(weakSelf.monthColumn.mas_right);
        }];
        [_yearColumn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.width.equalTo(weakSelf.monthColumn);
            make.left.equalTo(weakSelf.dayColumn.mas_right);
        }];
    } else {
        __weak typeof(self) weakSelf = self;
        _dayColumn.hidden = YES;
        CGFloat columnWidth = kScreenWidth / 2;
        [_yearColumn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(63*WIDTHRADIUS);
            make.left.mas_equalTo(weakSelf);
            make.bottom.mas_offset(-44*WIDTHRADIUS);
            make.width.mas_equalTo(columnWidth);
        }];
        [_monthColumn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.width.equalTo(weakSelf.monthColumn);
            make.left.equalTo(weakSelf.yearColumn.mas_right);
        }];
    }
}

- (void)setYearArray:(NSArray *)yearArray {
    _years = yearArray;
    _yearColumn.columnArray = _years;
}

- (void)setMonthArray:(NSArray *)monthArray {
    _months = monthArray;
    _monthColumn.columnArray = _months;
}

- (void)setDayArray:(NSArray *)dayArray {
    if (_days.count && _days.count==dayArray.count) {
        return;
    }
    _days = dayArray;
    _dayColumn.columnArray = _days;
}

#pragma mark - ZDBPickerColumnViewDelegate
- (void)pickerColumnView:(ZDBPickerColumnView *)columnView highlightIndex:(NSInteger)index {
    if (columnView == _yearColumn || columnView == _monthColumn) {
        if (_type == ZDBPickerTypeYearMonthDay) {
            if (self.scrollMDYAction) {
                self.scrollMDYAction(_monthColumn.selectCellTitle, _dayColumn.selectCellTitle, _yearColumn.selectCellTitle);
            }
        }
        
    }
    
}

@end
