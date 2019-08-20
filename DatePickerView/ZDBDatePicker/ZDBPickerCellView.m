//
//  ZDBPickerCellView.m
//  Thor
//
//  Created by 不明下落 on 2019/8/19.
//  Copyright © 2019 erongdu. All rights reserved.
//

#import "ZDBPickerCellView.h"
#import <Masonry.h>

@interface ZDBPickerCellView ()

@property(nonatomic, strong) UILabel *title;

@end

@implementation ZDBPickerCellView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createCellSubview];
    }
    return self;
}

- (void)updateWithTitle:(NSString *)title {
    _title.text = title;
}

- (void)createCellSubview {
    _title = [[UILabel alloc] init];
    _title.font = [UIFont systemFontOfSize:16];
    _title.textColor = [UIColor blackColor];
    [self.contentView addSubview:_title];
    _title.text = @"--";
    _title.textAlignment = NSTextAlignmentCenter;
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
