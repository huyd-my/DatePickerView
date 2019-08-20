//
//  ZDBPickerColumnView.m
//  Thor
//
//  Created by 不明下落 on 2019/8/19.
//  Copyright © 2019 erongdu. All rights reserved.
//

#import "ZDBPickerColumnView.h"
#import "ZDBPickerCellView.h"
#import <Masonry.h>

@interface ZDBPickerColumnView ()<UITableViewDelegate, UITableViewDataSource>
{
    CGFloat _beginY;
    CGFloat _endY;
    NSArray *_columns;
}
@property(nonatomic, strong) UITableView *dateTableView;
@end

@implementation ZDBPickerColumnView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self createTableView];
    }
    return self;
}

- (void)createTableView {
    _dateTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _dateTableView.backgroundColor = [UIColor clearColor];
    _dateTableView.delegate = self;
    _dateTableView.dataSource = self;
    _dateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _dateTableView.showsVerticalScrollIndicator = NO;
    _dateTableView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_dateTableView];
    [_dateTableView registerClass:[ZDBPickerCellView class] forCellReuseIdentifier:@"cellId"];
    [_dateTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)setColumnArray:(NSArray *)columnArray {
    _columns = columnArray;
    [_dateTableView reloadData];
}

- (void)setScrollIndex:(NSInteger)scrollIndex {
    NSInteger itemWidth = 44;
    _dateTableView.contentOffset = CGPointMake(_dateTableView.contentOffset.x, (scrollIndex-1) * itemWidth);
}

- (NSString *)selectCellTitle {
    NSArray *visibleIndexPaths = [_dateTableView indexPathsForVisibleRows];
    NSIndexPath *indexPath = visibleIndexPaths[1];
    return _columns[indexPath.row];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _columns.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZDBPickerCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    [cell updateWithTitle:_columns[indexPath.row]];
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _beginY = scrollView.contentOffset.y;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _endY = scrollView.contentOffset.y;
    if (!decelerate) {

        NSInteger itemWidth = 44;
        if ((NSInteger)scrollView.contentOffset.y % itemWidth != 0) {

            NSInteger currentIndex;

            float indexF = _endY / itemWidth;
            currentIndex = (NSInteger)(indexF+0.5);
            [UIView animateWithDuration:0.8 animations:^{
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, currentIndex * itemWidth);
            }];
            [self notifyPickerViewScrollIndex:currentIndex];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _endY = scrollView.contentOffset.y;
    NSInteger itemWidth = 44;
    if (scrollView.contentOffset.y <= 0) {
        [self notifyPickerViewScrollIndex:-1];
        return;
    }

    if (scrollView.contentOffset.y >= (_columns.count-1)*itemWidth) {
        [self notifyPickerViewScrollIndex:_columns.count-1];
        return;
    }
    if ((NSInteger)scrollView.contentOffset.y % itemWidth != 0 || (NSInteger)scrollView.contentOffset.y < itemWidth*_columns.count) {

        NSInteger currentIndex;

        float indexF = _endY / itemWidth;
        currentIndex = (NSInteger)(indexF+0.5);
        [UIView animateWithDuration:0.8 animations:^{
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, currentIndex * itemWidth);
        }];
        [self notifyPickerViewScrollIndex:currentIndex];
    }
}

- (void)notifyPickerViewScrollIndex:(NSInteger)index {
    if (_viewDelegate && [_viewDelegate respondsToSelector:@selector(pickerColumnView:highlightIndex:)]) {
        [_viewDelegate pickerColumnView:self highlightIndex:index+1];
    }
}
@end
