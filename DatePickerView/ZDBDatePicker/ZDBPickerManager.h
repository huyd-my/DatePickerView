//
//  ZDBPickerManager.h
//  Thor
//
//  Created by 不明下落 on 2019/8/19.
//  Copyright © 2019 erongdu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZDBPickerView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SubmitAction)(NSString *timeString);

@interface ZDBPickerManager : NSObject

@property(nonatomic, copy) SubmitAction submitAction;

+ (ZDBPickerManager *)sharedInstance;

/**
 显示年月日选择器

 @param time 时间
 */
- (void)showPickerViewWithYMDTime:(NSString *)time ;

/**
 显示年月选择器

 @param time 时间
 */
- (void)showPickerViewWithYMTime:(NSString *)time ;
@end

NS_ASSUME_NONNULL_END
