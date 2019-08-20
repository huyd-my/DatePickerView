//
//  ZDBPickerColumnView.h
//  Thor
//
//  Created by 不明下落 on 2019/8/19.
//  Copyright © 2019 erongdu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZDBPickerColumnView;

@protocol ZDBPickerColumnViewDelegate <NSObject>

- (void)pickerColumnView:(ZDBPickerColumnView *)columnView highlightIndex:(NSInteger)index;

@end

@interface ZDBPickerColumnView : UIView

@property(nonatomic, weak) id<ZDBPickerColumnViewDelegate> viewDelegate;

@property(nonatomic, strong) NSArray *columnArray;

@property(nonatomic, assign) NSInteger scrollIndex;

@property(nonatomic, strong, readonly) NSString *selectCellTitle;

@end

NS_ASSUME_NONNULL_END
