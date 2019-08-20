# DatePickerView
自定义日期选择器（使用tableView实现）
# 背景
我太难了... 放张图片吐槽一下

![吐槽吐槽.png](https://upload-images.jianshu.io/upload_images/1918401-e68c168b5e54d1e2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/375)

由于系统没有提供底色修改的方法和属性。我尝试通过一层层subview拿到子视图，根据kvc修改他的属性，发现不能直接修改选中行的颜色。我修改的是所有行的颜色。网上查询也没有找到有效的解决方案。于是决定放弃使用系统提供的pickerView，自己实现一个
# 思路
这个选择器可分为：
1. 上面的关闭+确定按钮+分割线
2. 中间的浅蓝色选中行
3. 三个可滑动的选择控件
这个滑动的视图我们可以使用系统提供的tableView实现。

tableView实现的注意点：
1. 首先控制它的滑动事件。让他的cell能够居中的显示在选中行里面（滑动偏移量为行高的整数倍）。
2. 其次，我们要关联他们之间的联动。1、3、5、7、8、10、12月有31天。4、6、9、11月有30天。闰年2月29天，平年2月28天。
3. 然后提供一个默认事件选中方法。在没有时间传入的时候，默认选中的是当天的时间。有时间传入的时候，选中的是传入的时间。
4. 最后，点击submit按钮的时候，需要告诉外部它当前选中的时间是多少。

还有一些小细节需要注意。
tableView的visibleCell是三行，我们可以通过布局实现它；
tableView的第0行和最后一行不能显示在选中行上面，我们需要在最上面和最下面给加一行。如图：

![分析图.png](https://upload-images.jianshu.io/upload_images/1918401-4f6a856a863248cd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/375)


# 实现
简单的说一下。

![文件层级.png](https://upload-images.jianshu.io/upload_images/1918401-ece44d41a6bd568c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- ZDBPickerManager：全局单例，方便使用者调用。
- ZDBPickerView：整个picker弹框，包括按钮
- ZDBPickerColumnView：上文中提及的tableView，也就是picker中的联动行。
- ZDBPickerCellView：cell

我们从下到上一一捋一遍。
### ZDBPickerCellView
ZDBPickerCellView部分就是简单的一个titleLabel。文字的对齐方式是居中。用来显示数据。

### ZDBPickerColumnView
由于数据源是可变的（每月的天数不固定），所以我们要提供一个属性columnArray，让外部可以通过给这个属性赋值来刷新table。
还有，还需要提供一个integer类型的属性scrollIndex来改变table的偏移量，让指定日期高亮的显示在选中区域。
此外，我们的picker要向外传递当前用户选中的时间，所以需要有一个只读 的变量selectCellTitle来指向当前picker列选中行的文案，便于向外传递信息。
所有变量整理如下：

```
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
```
当中ZDBPickerColumnViewDelegate这个代理，是用来向ZDBPickerView传递信息，处理年月日之间的联动关系的。当tableView停止滚动的时候，他会告诉pikerView：“我已经选中了这一行，你可以刷新其他行的数据了”。
比如：

tableView：“我停止已经选好一行了，快来看看”

pikerView：“你选中了2016年，2月，所以天数的范围是[1-29]”


还有一个 偏移问题，让tableView的偏移是行高的整数倍。实现方式类似于banner的轮播。方法我们之前说过[banner+自定义pageControl](https://www.jianshu.com/p/944f9d75b5d2)。
```
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _endY = scrollView.contentOffset.y;
    if (!decelerate) {

        NSInteger itemWidth = 44;
        if ((NSInteger)_endY % itemWidth != 0) {

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
    if (_endY <= 0) {
        [self notifyPickerViewScrollIndex:-1];
        return;
    }
    if (_endY >= (_columns.count-1)*itemWidth) {
        [self notifyPickerViewScrollIndex:_columns.count-1];
        return;
    }
    if ((NSInteger)_endY % itemWidth != 0 || (NSInteger)_endY < itemWidth*_columns.count) {

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
```
通过滚动结束之后的y轴位置/偏移量 ，四舍五入，计算出滚动的index，然后再对scrollView的contentOffset属性的赋值来修改偏移，实现类似系统picker滑动的效果。

### ZDBPickerView
现在我们可以组装picker了。
背景图：点击背景可以隐藏弹框。
关闭按钮：点击按钮可以隐藏弹框。
确认按钮：点击按钮可以隐藏弹框，并且触发submit的block事件，传递选中时间。
弹框主体：有两种类型
- 年月日 ZDBPickerTypeYearMonthDay，年月日三列联动。
- 年月     ZDBPickerTypeYearMonth，年月两级。

以下是.h文件：
```
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
```
由于弹框的样式有两种，所以我们需要提供一个更新弹框样式的方法。
另外，我们的数据源处理放在了manager，所以需要scrollMDYAction来告诉manager需要更新数据源，然后提供yearArray，monthArray，dayArray来接收数据源。
emm,还有实现tableView的代理。由于我们只有天数是可变的，所以我们只要处理ZDBPickerTypeYearMonthDay样式的picker联动就好了。天数的变化是根据年份和月份来的，所以我们需要选中的年和月（highlightIndex我们并没有用到，可以使用.selectCellTitle直接拿到）。
```
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
```
### ZDBPickerManager
这是一个方便我们使用picker的单例。使用它在picker外面包一层，这将会让我们使用picker变得简单。它只需要做两件事：
1. 显示pickerView；
2. 传递选中时间。

 所以他的.h文件比较简单：
```
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
```

他要做的事情有：
1. 创建和改变tableView的数据源。
由于月份我们显示的是英文的选择框，回显和保存的是数值，所以我们创建了两个数组用来存放。monthArray存放显示，normalMonthArray存放回显。
2. 创建pickerView。
3. 处理时间及时间格式。
外部没有时间传入的时候，我们需要默认选中当前时间。时间格式为2019-08-20这种接口能够保存的格式。

这里说一下怎么处理tableView最后一行和第0行不能选中的问题。我们在数据源数组的第0位置和最后位置插入空字符串就可以了。这个是创建默认数据的方法
```
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
```

判断润2月和平2月
```
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
```

# 使用
```
[[ZDBPickerManager sharedInstance] showPickerViewWithYMTime:defaultTime];
    [ZDBPickerManager sharedInstance].submitAction = ^(NSString * _Nonnull timeString) {
        weakSelf.YearMonthLabel.text = [NSString stringWithFormat:@"年月：%@",timeString];
    };
```

# 写在最后
感觉实现一个稍微复杂点的视图最重要的是思路+实现这个思路的方法和途径。重要的是这个过程。很多东西不是一蹴而就的，是慢慢的堆叠上去然后再仔细修剪的过程。看手下的东西从模模糊糊，通过自己的修修剪剪变得轮廓清晰，有一种成就感。
如果对你有帮助，点个star吧。谢谢🙏
