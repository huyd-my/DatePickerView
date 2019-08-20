//
//  ViewController.m
//  DatePickerView
//
//  Created by 不明下落 on 2019/8/20.
//  Copyright © 2019 不明下落. All rights reserved.
//

#import "ViewController.h"
#import "ZDBPickerManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *YearMonthDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *YearMonthLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(YMDTapAction)];
    _YearMonthDayLabel.userInteractionEnabled = YES;
    [_YearMonthDayLabel addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(YMTapAction)];
    _YearMonthLabel.userInteractionEnabled = YES;
    [_YearMonthLabel addGestureRecognizer:tap2];
}

- (void)YMDTapAction {
    __weak typeof(self) weakSelf = self;
    NSString *defaultTime ;
    if (self.YearMonthDayLabel.text.length>4) {
        defaultTime = [self.YearMonthDayLabel.text substringWithRange:NSMakeRange(4, self.YearMonthDayLabel.text.length-4)];
    }
    [[ZDBPickerManager sharedInstance] showPickerViewWithYMDTime:defaultTime];
    [ZDBPickerManager sharedInstance].submitAction = ^(NSString * _Nonnull timeString) {
        weakSelf.YearMonthDayLabel.text = [NSString stringWithFormat:@"年月日：%@",timeString];
    };
}

- (void)YMTapAction {
    __weak typeof(self) weakSelf = self;
    NSString *defaultTime ;
    if (self.YearMonthLabel.text.length>3) {
        defaultTime = [self.YearMonthLabel.text substringWithRange:NSMakeRange(3, self.YearMonthLabel.text.length-3)];
    }
    [[ZDBPickerManager sharedInstance] showPickerViewWithYMTime:defaultTime];
    [ZDBPickerManager sharedInstance].submitAction = ^(NSString * _Nonnull timeString) {
        weakSelf.YearMonthLabel.text = [NSString stringWithFormat:@"年月：%@",timeString];
    };
}

@end
