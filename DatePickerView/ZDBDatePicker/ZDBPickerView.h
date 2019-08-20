//
//  ZDBPickerView.h
//  Thor
//
//  Created by 不明下落 on 2019/8/19.
//  Copyright © 2019 erongdu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZDBPickerType) {
    ZDBPickerTypeYearMonth = 1,
    ZDBPickerTypeYearMonthDay,
};

/**
 天数显示

 - ZDBPickerDateDayFebSmall: 二月28天
 - ZDBPickerDateDayFebBig: 二月29天
 - ZDBPickerDateDaySmall: 2|3|6|9|11 30天
 - ZDBPickerDateDayBig: 1|3|5|7|8|10|12 31天
 */
typedef NS_ENUM(NSUInteger, ZDBPickerDateDay) {
    ZDBPickerDateDayFebSmall,
    ZDBPickerDateDayFebBig,
    ZDBPickerDateDaySmall,
    ZDBPickerDateDayBig,
};

typedef void(^MDYSubmitAction)(NSString *month, NSString *day, NSString *year);

typedef void(^YMSubmitAction)(NSString *year, NSString *month);

typedef void(^ZDBDayChangeAction)(ZDBPickerDateDay dayType);

@interface ZDBPickerView : UIView

- (instancetype)initWithType:(ZDBPickerType)type;

- (void)updateWithType:(ZDBPickerType)type;

/**
 tableview默认选中的下标

 @param monthIndex 月数组下标
 @param dayIndex 日数组下标
 @param yearIndex 年数组下标
 */
- (void)scrollIndexWithMonthIndex:(NSInteger)monthIndex
                         dayIndex:(NSInteger)dayIndex
                        yearIndex:(NSInteger)yearIndex;

/**
 tableview默认选中的下标

 @param monthIndex 月数组下标
 @param yearIndex 年数组下标
 */
- (void)scrollIndexWithMonthIndex:(NSInteger)monthIndex
                        yearIndex:(NSInteger)yearIndex;

/**
 关闭弹框
 */
@property(nonatomic, copy) dispatch_block_t cancleAction;
/**
 年月日提交
 */
@property(nonatomic, copy) MDYSubmitAction submitMDYAction;
/**
 年月的table滑动，引起的日table数据源的变化
 */
@property(nonatomic, copy) MDYSubmitAction scrollMDYAction;
/**
 年月提交
 */
@property(nonatomic, copy) YMSubmitAction submitYMAction;

@property(nonatomic, strong) NSArray *yearArray;
@property(nonatomic, strong) NSArray *monthArray;
@property(nonatomic, strong) NSArray *dayArray;

@end

NS_ASSUME_NONNULL_END
