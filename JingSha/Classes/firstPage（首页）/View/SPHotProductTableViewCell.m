//
//  SPHotProductTableViewCell.m
//  JingSha
//
//  Created by 苹果电脑 on 5/26/16.
//  Copyright © 2016 bocweb. All rights reserved.
//

#import "SPHotProductTableViewCell.h"
#import "NewProModel.h"
#define KCellWith kUIScreenWidth
#define KCellHeight (200 * KProportionHeight)

@interface SPHotProductTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIView *cntView;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation SPHotProductTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.cntView.layer.cornerRadius = 5;
    self.cntView.layer.borderWidth = 0.001;
    self.cntView.layer.masksToBounds = YES;
    [self loadData];
}

#define mark - Lazyloading
- (NSMutableArray *)dataArr {
    if (!_dataArr ) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}

/**
 *  加载数据
 */
- (void)loadData {
    @WeakObj(self);
    [[HttpClient sharedClient] getFirstPageInfoComplecion:^(id resoutObj, NSError *error) {
        @StrongObj(self)
        if (error) {
            MyLog(@"首页数据请求错误%@", error);
        } else {
            MyLog(@"首页热门推荐数据%@\n", resoutObj);
            [Strongself getDataFromResponseObj:resoutObj];
            [Strongself setupSubViews];
        }
    }];
}

/**
 *  分解数据
 */
- (void)getDataFromResponseObj:(id)responseObj {
    //供应信息条数
    self.countLabel.text = [NSString stringWithFormat:@"%@",responseObj[@"prolistcount"]];

    NSDictionary * dict  = responseObj[@"data"];
    for (NSDictionary * smallDict in dict[@"newpro"]) {
        NewProModel * model = [NewProModel objectWithKeyValues:smallDict];
        [self.dataArr addObject:model];
    }
}

- (void)setupSubViews {
    NSMutableArray * titleAry = [NSMutableArray array];
    NSMutableArray * imageAry = [NSMutableArray array];
    NSInteger lineCount;
    for (int i = 0; i < self.dataArr.count; i++) {
        [titleAry addObject:[self.dataArr[i] title]];
        [imageAry addObject:[self.dataArr[i] photo]];
    }
    if (self.dataArr.count <= 3) {
        lineCount = 1;
    }else if (self.dataArr.count > 3 && self.dataArr.count <= 6){
        lineCount = 2;
    }else if (self.dataArr.count > 6 && self.dataArr.count <= 9){
        lineCount = 3;
    }
    for (int i = 0 ; i < lineCount; i++) {
        for (int j = 0; j < 3 ; j++) {
            CGFloat viewX = j * (KCellWith / 3);
            CGFloat viewY = i * (KCellHeight / 2) + 39;
            CGFloat viewW = KCellWith / 3;
            CGFloat viewH = KCellHeight / 2 ;
            
            UIView *view = [[UIView alloc] init];//
            view.frame = CGRectMake(viewX, viewY, viewW, viewH);
            view.tag = 1000 + i * 3 + j;
            [self.cntView addSubview:view];
            
            if (i * 3 + j == self.dataArr.count) {
                return;
            }
            
            //加线(横线 竖线)
            if (i == 0) {
                UIView * view1 = [[UIView alloc] initWithFrame:CGRectMake(0, (i + 1) *viewH + 39, kUIScreenWidth, 1)];
                view1.backgroundColor = RGBColor(218, 218, 218);
                [self.cntView addSubview:view1];
            }
            //
            UIView * view2 = [[UIView alloc] initWithFrame:CGRectMake(KCellWith/3 - 1, 15, 1, viewH - 30)];
            view2.backgroundColor = RGBColor(218, 218, 218);
            [view addSubview:view2];
            
            
            
            //titleLabel
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5,viewH - 20, viewW - 10, 15)];
            label.font = [UIFont systemFontOfSize:12];
            label.userInteractionEnabled = YES;
            //            label.backgroundColor = [UIColor blueColor];(viewH - viewH/3*2 -20)/2 + viewH/3*2 + 5    viewH - 20
            label.text = titleAry[i*3+j];
            label.textAlignment = NSTextAlignmentCenter;
            //            CGRect rect = [label.text boundingRectWithSize: CGSizeMake(viewW/5*4, 0)  options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil];
            
            //            label.frame = CGRectMake(5, 5, viewW/5*4, rect.size.height);
            label.textColor = RGBColor(159, 159, 159);
            label.numberOfLines = 0;
            [view addSubview:label];
            
            //imageView
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5 , 5, viewW- 10, viewH/3*2)];
            imageView.backgroundColor = [UIColor whiteColor];
            imageView.userInteractionEnabled = YES;
            [imageView sd_setImageWithURL:[NSURL URLWithString:[self.dataArr[i * 3 + j] photo]] placeholderImage:[UIImage imageNamed:@"NetBusy"] completed:nil];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [view addSubview:imageView];
            
            //给headerView加手势 条
            UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTapAction:)];
            [self.headerView addGestureRecognizer:headerTap];
            
            //给每个视图加上手势，以便对应跳转
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
            
            [view addGestureRecognizer:tap];
        }
    }
}

- (void)tapClick:(UITapGestureRecognizer *)gesture{
    UIView *selectView = gesture.view;
    NSInteger index =selectView.tag - 1000;
    NewProModel * model = _dataArr[index];
    NSString * ID = model.Id;
    if (_delegate && [_delegate respondsToSelector:@selector(pushToDetailVCFromCell:)]) {
        [_delegate pushToDetailVCFromCell:ID];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)headerViewTapAction:(UITapGestureRecognizer *)gesture {
    [self moreBtnClick:nil];
}

- (IBAction)moreBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(HotProductMoreBtnClick:)]) {
        [self.delegate HotProductMoreBtnClick:sender];
    }
}

@end
