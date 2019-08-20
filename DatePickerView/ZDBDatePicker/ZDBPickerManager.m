//
//  ZDBPickerManager.m
//  Thor
//
//  Created by 不明下落 on 2019/8/19.
//  Copyright © 2019 erongdu. All rights reserved.
//

#import "ZDBPickerManager.h"
#import <Masonry.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define WIDTHRADIUS (kScreenWidth/375.0)

@interface ZDBPickerManager ()

@property(nonatomic, strong) ZDBPickerView *pickerView ;
@property(nonatomic, strong) UIView *bgMaskView;

@property(nonatomic, strong) NSArray *yearArray;
@property(nonatomic, strong) NSArray *monthArray;
@property(nonatomic, strong) NSArray *normalMonthArray;
@property(nonatomic, strong) NSArray *dayArray;

@end

@implementation ZDBPickerManager

+ (ZDBPickerManager *)sharedInstance{
    static ZDBPickerManager *ZDBPickerManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        ZDBPickerManagerInstance = [[self alloc] init];
        [ZDBPickerManagerInstance createData];
        [ZDBPickerManagerInstance createDefaultPicker];
        
    });
    return ZDBPickerManagerInstance;
}

- (void)showPickerViewWith:(ZDBPickerType)type {
    [_pickerView updateWithType:type];
    [[UIApplication sharedApplication].keyWindow addSubview:_bgMaskView];
    [[UIApplication sharedApplication].keyWindow addSubview:_pickerView];
    [_pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_offset(0);
        make.height.equalTo(@(107*WIDTHRADIUS+132));
    }];
    [_bgMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)showPickerViewWithYMDTime:(NSString *)time {
    if (!time.length) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        time = [formatter stringFromDate:date];
    }
    if ([time containsString:@"-"]) {
        [self showPickerViewWith:ZDBPickerTypeYearMonthDay];
        NSArray *timeArr = [time componentsSeparatedByString:@"-"];
        NSString *selectMonth = timeArr[1];
        NSString *selectDay = timeArr[2];
        NSString *selectYear = timeArr[0];
        NSInteger selectMonthIndex = [_normalMonthArray indexOfObject:selectMonth];
        NSInteger selectDayIndex = [_dayArray indexOfObject:selectDay];
        NSInteger selectYearIndex = [_yearArray indexOfObject:selectYear];
        [_pickerView scrollIndexWithMonthIndex:selectMonthIndex dayIndex:selectDayIndex yearIndex:selectYearIndex];
    }
}

- (void)showPickerViewWithYMTime:(NSString *)time {
    if (!time.length) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM"];
        time = [formatter stringFromDate:date];
    }
    if ([time containsString:@"-"]) {
        [self showPickerViewWith:ZDBPickerTypeYearMonth];
        NSArray *timeArr = [time componentsSeparatedByString:@"-"];
        NSString *selectYear = timeArr[0];
        NSString *selectMonth = timeArr[1];
        NSInteger selectMonthIndex = [_normalMonthArray indexOfObject:selectMonth];
        NSInteger selectYearIndex = [_yearArray indexOfObject:selectYear];
        [_pickerView scrollIndexWithMonthIndex:selectMonthIndex yearIndex:selectYearIndex];
    }
}

- (void)createDefaultPicker {
    __weak typeof(self) weakSlef = self;
    
    _bgMaskView = [[UIView alloc] init];
    _bgMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    [_bgMaskView addGestureRecognizer:tap];
    
    _pickerView = [[ZDBPickerView alloc] initWithType:ZDBPickerTypeYearMonthDay];
    _pickerView.cancleAction = ^{
        [weakSlef.bgMaskView removeFromSuperview];
        [weakSlef.pickerView removeFromSuperview];
    };
    _pickerView.submitYMAction = ^(NSString * _Nonnull year, NSString * _Nonnull month) {
        [weakSlef submitInfoWithYear:year month:month];
    };
    _pickerView.submitMDYAction = ^(NSString * _Nonnull month, NSString * _Nonnull day, NSString * _Nonnull year) {
        [weakSlef submitInfoWith:month day:day year:year];
    };
    _pickerView.scrollMDYAction = ^(NSString * _Nonnull month, NSString * _Nonnull day, NSString * _Nonnull year) {
        ZDBPickerDateDay dayType = [weakSlef getDayTypeWith:month year:year];
        [weakSlef displayDay:dayType];
    };
    _pickerView.monthArray = _monthArray;
    _pickerView.dayArray = _dayArray;
    _pickerView.yearArray = _yearArray;
}

- (void)dismissView {
    [self.pickerView removeFromSuperview];
    [_bgMaskView removeFromSuperview];
}

- (void)submitInfoWith:(NSString *)month day:(NSString *)day year:(NSString *)year {
    NSInteger monthIndex = [_monthArray indexOfObject:month];
    if (self.submitAction) {
        [self.pickerView removeFromSuperview];
        [self.bgMaskView removeFromSuperview];
        NSString *info = [NSString stringWithFormat:@"%@-%@-%@",year,_normalMonthArray[monthIndex],day];
        self.submitAction(info);
    }
}
- (void)submitInfoWithYear:(NSString *)year month:(NSString *)month {
    NSInteger monthIndex = [_monthArray indexOfObject:month];
    if (self.submitAction) {
        [self.pickerView removeFromSuperview];
        [self.bgMaskView removeFromSuperview];
        NSString *info = [NSString stringWithFormat:@"%@-%@",year,_normalMonthArray[monthIndex]];
        self.submitAction(info);
    }
}

- (ZDBPickerDateDay)getDayTypeWith:(NSString *)month year:(NSString *)year {
    ZDBPickerDateDay dayType;
    NSInteger monthIndex = [_monthArray indexOfObject:month];
    NSString *monthNormal = _normalMonthArray[monthIndex];
    if ([monthNormal isEqualToString:@"01"] ||
        [monthNormal isEqualToString:@"03"] ||
        [monthNormal isEqualToString:@"05"] ||
        [monthNormal isEqualToString:@"07"] ||
        [monthNormal isEqualToString:@"08"] ||
        [monthNormal isEqualToString:@"10"] ||
        [monthNormal isEqualToString:@"12"]) {
        dayType = ZDBPickerDateDayBig;
    } else if ([monthNormal isEqualToString:@"04"] ||
               [monthNormal isEqualToString:@"06"] ||
               [monthNormal isEqualToString:@"09"] ||
               [monthNormal isEqualToString:@"11"]) {
        dayType = ZDBPickerDateDaySmall;
    } else {
        if([year integerValue]%4==0 && [year integerValue]%100!=0) {
            //普通年份，非100整数倍
            dayType = ZDBPickerDateDayFebBig;
        } else if([year integerValue]%400 == 0) {
            //世纪年份
            dayType = ZDBPickerDateDayFebBig;
        } else {
            dayType = ZDBPickerDateDayFebSmall;
        }
        
    }
    return dayType;
}

- (void)displayDay:(ZDBPickerDateDay)dayType {
    NSInteger maxDay ;
    if (dayType == ZDBPickerDateDayFebSmall) {
        maxDay = 28;
    } else if (dayType == ZDBPickerDateDayFebBig) {
        maxDay = 29;
    } else if (dayType == ZDBPickerDateDaySmall) {
        maxDay = 30;
    } else {
        maxDay = 31;
    }
    NSMutableArray *mutaArr  = [NSMutableArray new];
    for (int i = 1; i <= maxDay; i ++) {
        if (i < 10) {
            [mutaArr addObject:[NSString stringWithFormat:@"0%d",i]];
        } else {
            [mutaArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    [mutaArr insertObject:@"" atIndex:0];
    [mutaArr addObject:@""];
    _dayArray = [mutaArr copy];
    _pickerView.dayArray = _dayArray;
}

- (void)createData {
    NSMutableArray *mutaArr = [NSMutableArray new];
    for (int i = 1500; i<=5000; i++) {
        [mutaArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [mutaArr insertObject:@"" atIndex:0];
    [mutaArr addObject:@""];
    _yearArray = [mutaArr copy];
    
    NSString *monthStr = @"January,February,March,April,May,June,July,August,September,October,November,December";
    NSArray *originArray = [monthStr componentsSeparatedByString:@","];
    NSMutableArray *mutaArr2 = [[NSMutableArray alloc] initWithArray:originArray];
    [mutaArr2 insertObject:@"" atIndex:0];
    [mutaArr2 addObject:@""];
    _monthArray = [mutaArr2 copy];
    
    NSMutableArray *mutaArr21 = [NSMutableArray new];
    for (int i = 1; i<=12; i++) {
        if (i < 10) {
            [mutaArr21 addObject:[NSString stringWithFormat:@"0%d",i]];
        } else {
            [mutaArr21 addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    [mutaArr21 insertObject:@"" atIndex:0];
    [mutaArr21 addObject:@""];
    _normalMonthArray = [mutaArr21 copy];
    
    NSMutableArray *mutaArr3 = [NSMutableArray new];
    for (int i = 1; i<=30; i++) {
        if (i < 10) {
            [mutaArr3 addObject:[NSString stringWithFormat:@"0%d",i]];
        } else {
            [mutaArr3 addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    [mutaArr3 insertObject:@"" atIndex:0];
    [mutaArr3 addObject:@""];
    _dayArray = [mutaArr3 copy];
}

@end
