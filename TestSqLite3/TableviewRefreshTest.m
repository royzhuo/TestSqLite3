//
//  TableviewRefreshTest.m
//  TestSqLite3
//
//  Created by Roy on 16/6/28.
//  Copyright © 2016年 Roy. All rights reserved.
//  tableview下拉刷新

#import "TableviewRefreshTest.h"
#import "YiRefreshFooter.h"
#import "YiRefreshHeader.h"

#define tableCell @"tableviewCell"
@interface TableviewRefreshTest ()<UITableViewDelegate,UITableViewDataSource>
{

    //更新view
    YiRefreshFooter *footerView;
    YiRefreshHeader *headerView;
    int total;
}

@end

@implementation TableviewRefreshTest

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    
    total=0;
    //头部
    headerView=[[YiRefreshHeader alloc]init];
    headerView.scrollView=self.tableview;
    [headerView header];
    typeof(headerView) __weak weakRefreshHeader=headerView;
    headerView.beginRefreshingBlock=^(){
        // 后台执行：
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^{
                typeof(weakRefreshHeader) __strong strongRefreshHeader = weakRefreshHeader;
                // 主线程刷新视图
                total=16;
                [self.tableview reloadData];
                [strongRefreshHeader endRefreshing];
            });
        });
    };
    [headerView endRefreshing];
    
    footerView=[[YiRefreshFooter alloc] init];
    footerView.scrollView=self.tableview;
    [footerView footer];
    typeof(footerView) __weak weakRefreshFooter = footerView;
    
    footerView.beginRefreshingBlock=^(){
        // 后台执行：
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^{
                typeof(weakRefreshFooter) __strong strongRefreshFooter = weakRefreshFooter;
                // 主线程刷新视图
                total=total+16;
                [self.tableview reloadData];
                [strongRefreshFooter endRefreshing];
            });
        });
    };

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIView *topview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.frame=CGRectMake(0, topview.frame.size.height/2, topview.frame.size.width, topview.frame.size.height/2);
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.text=@"下拉刷新测试";
    //[titleLabel setTextColor:[UIColor whiteColor]];
    topview.backgroundColor=[UIColor yellowColor];
    [topview addSubview:titleLabel];
    
    [self.view addSubview:topview];

}


#pragma mark 协议
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return total;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:tableCell];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCell];
    }
    cell.textLabel.text=[NSString stringWithFormat:@"%daaaa",indexPath.row];
    
    return cell;

}



@end
