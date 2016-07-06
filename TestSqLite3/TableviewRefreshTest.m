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
#import <sqlite3.h>
#import "Student.h"

#define tableCell @"tableviewCell"
#define DBNAME @"personalInfo.sqlite"

#define pageSize 10

@interface TableviewRefreshTest ()<UITableViewDelegate,UITableViewDataSource>
{

    //更新view
    YiRefreshFooter *footerView;
    YiRefreshHeader *headerView;
    int total;
    BOOL isReresh;
    NSMutableArray *students;
    NSMutableArray *loadMoreDatas;
    
    int currentIndex;
    
    sqlite3 *db;
}

@end

@implementation TableviewRefreshTest

#pragma mark 类加载
- (void)viewDidLoad {
    [super viewDidLoad];
    if (students==nil) {
        students=[[NSMutableArray alloc]init];
    }
    if(loadMoreDatas==nil) loadMoreDatas=[[NSMutableArray alloc]init];
    
    currentIndex=0;
    
    self.tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    
    //为tableview设置为观察者模式，keypath为contentoffset属性
//    [self.tableview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    total=0;
    isReresh=NO;
    int aa=[[UIScreen mainScreen]bounds].size.height;
    self.tableview.frame=CGRectMake(0, 164, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen]bounds].size.height-200);
    CGRect tableFrame=self.tableview.frame;
    
    self.tableview.backgroundColor=[UIColor greenColor];
    headerView=[[YiRefreshHeader alloc]init];
    headerView.scrollView=self.tableview;
    [headerView header];
    typeof(headerView) __weak weakRefreshHeader=headerView;
    headerView.beginRefreshingBlock=^(){
        //后台执行
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //睡眠2毫秒
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^{
                typeof(headerView) __strong strongRefreshHeader=weakRefreshHeader;
                [self queryStudent];
                [strongRefreshHeader endRefreshing];
            });
            
        });
    };
    // 是否在进入该界面的时候就开始进入刷新状态
    [headerView beginRefreshing];
    
    //底部view
    footerView=[[YiRefreshFooter alloc]init];
    footerView.scrollView=self.tableview;
    [footerView footer];
    typeof(footerView) __weak weakFootView=footerView;
    footerView.beginRefreshingBlock=^(){
    
        //后台执行
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^{
                typeof(footerView) __strong strongRefreshFootView=footerView;
                [self loadMore];
                [strongRefreshFootView endRefreshing];
            });
        });
    
    
    };
    
    [self createDataBase];
    //[self createTable];
    //[self addStudent];
    
}

#pragma mark 创建数据库
-(void) createDataBase
{

    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:DBNAME];
    //2.open数据库文件
    if(sqlite3_open([path UTF8String], &db) != SQLITE_OK){   //sqlite3_open()有数据库打开，无则创建数据库
        sqlite3_close(db);
        NSLog(@"打开数据库失败");
    }


}

-(void) createTable
{
//    NSString *createTableSql=@"create table if not exists personalInfo(id integer primary key,name text,age text, address text)";
    char *err;
     NSString *createTable=@"create table Student(id integer primary key,name text , sex integer )";
    if(sqlite3_exec(db,[createTable UTF8String],nil,nil,&err)!=SQLITE_OK)
    {
        NSLog(@"表格创建失败");
    
    }
   // sqlite3_exec(db,[createTable UTF8String],nil,nil,&err);

}

-(void) addStudent
{

    NSString *sql1=@"insert into student(name,sex) values(?,?)";
    NSArray *paramters=@[@"roy",@"1"];
 int result=   [self update:sql1 withParamters:paramters];
    if (result==1) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"添加成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [alertView show];
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"添加失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [alertView show];
    }
}

-(void) queryStudent
{
    [students removeAllObjects];
//    NSString *sql=@"select * from student  order by id desc limit 0,10 ";
    NSString *sql=[NSString stringWithFormat:@"select * from student order by id desc limit 0,%d",pageSize];
    NSArray *array=[self queryBySQL:sql withParamters:nil];
    for (NSDictionary *dic in array) {
        NSString *sId=[dic objectForKey:@"id"];
        NSString *name=[dic objectForKey:@"name"];
        NSString *sex=[dic objectForKey:@"sex"];
        
        Student *student=[[Student alloc]init];
        student.sId=sId;
        student.name=name;
        
        if ([sex isEqualToString:@"1"]) {
            student.sex=@"男";
        }else if([sex isEqualToString:@"0"]){
            student.sex=@"女";
        }
        
        [students addObject:student];
        
    }
    
    [self.tableview reloadData];

}

-(void) loadMore
{
    int countStudents=0;
    NSString *sql=@"select count(0) from Student";
    NSArray *array=[self queryBySQL:sql withParamters:nil];
    for (NSDictionary *dic in array) {
        NSString *countStr=[dic objectForKey:@"countStr"];
        countStudents=[countStr integerValue];
    }
    //下一页
    int pageCount=countStudents/pageSize;
    
    NSString *sql1=[NSString stringWithFormat:@"select * from student order by id desc limit %d,%d",currentIndex,pageSize];
    NSArray *array1=[self queryBySQL:sql1 withParamters:nil];
    for (NSDictionary *dic in array1) {
        NSString *sId=[dic objectForKey:@"id"];
        NSString *name=[dic objectForKey:@"name"];
        NSString *sex=[dic objectForKey:@"sex"];
        
        Student *student=[[Student alloc]init];
        student.sId=sId;
        student.name=name;
        
        if ([sex isEqualToString:@"1"]) {
            student.sex=@"男";
        }else if([sex isEqualToString:@"0"]){
            student.sex=@"女";
        }
        
        [loadMoreDatas addObject:student];
    }
    
    [students addObjectsFromArray:loadMoreDatas];
    
    NSMutableArray *indexPaths=[[NSMutableArray alloc]init];
    for (Student *student in loadMoreDatas) {
        int index=[students indexOfObject:student];
     NSIndexPath *indexPath=   [NSIndexPath indexPathForRow:index inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    
    [self.tableview insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
    [loadMoreDatas removeAllObjects];



}

#pragma mark dao层crud
-(int) update:(NSString *) sql withParamters:(NSArray *) paramters
{
    sqlite3_stmt *stmt;
    int callResult=0;
    int result= sqlite3_prepare_v2(db, [sql UTF8String] , -1, &stmt, nil);
    if (result==SQLITE_OK) {
        if (paramters!=NULL&& paramters.count>0) {
            for (int i=0; i<paramters.count; i++) {
                //1.表示预编译语句 2.插入序号 3. 插入的数据 4数据长度（－1表示全部）5.是否回调
                sqlite3_bind_text(stmt,i+1,[paramters[i] UTF8String],-1,nil);
            }
        }
        
        //执行预编译语句
        if(sqlite3_step(stmt)== SQLITE_DONE){
            NSLog(@"sql更新成功");
            callResult=1;
            //关闭资源
            sqlite3_finalize(stmt);
            
        }else NSLog(@"sql更新失败");
    }
    //关闭数据库
    //sqlite3_close(db);
    
    return callResult;
}

-(NSArray *) queryBySQL:(NSString *) sql withParamters:(NSArray *) paramters
{
    
    NSMutableArray *results=[NSMutableArray array];
    sqlite3_stmt *stmt;
    if( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil)==SQLITE_OK){
        if (paramters!=NULL || paramters.count>0) {
            for (int i=0; i<paramters.count; i++) {
                sqlite3_bind_text(stmt, i+1, [paramters[i] UTF8String], -1, nil);
            }
        }
        
        while(sqlite3_step(stmt)==SQLITE_ROW){
            
            int count=sqlite3_column_count(stmt);  //返回语句句柄相关的字段数；
            NSLog(@"循环里面查询有%d条",count);
            //新建字典存放值
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            for (int i=0; i<count; i++) {
              int count=  sqlite3_column_int(stmt,0);
                NSString *countStr=[NSString stringWithFormat:@"%d",count];
                char *cCN=sqlite3_column_name(stmt,i); //字段名称
                char *cCV=sqlite3_column_text(stmt,i);//字段值
                NSLog(@"字段名称:%@,字段值:%@",[NSString stringWithUTF8String:cCN],[NSString stringWithUTF8String:cCV]);
                [dic setObject:[NSString stringWithUTF8String:cCV] forKey:[NSString stringWithUTF8String:cCN]];
                [dic setObject:countStr forKey:@"countStr"];
                NSLog(@"count:%d",count);
            }
            [results addObject:dic];
            continue;
            
        }
    }
    //释放资源
    sqlite3_finalize(stmt);
    
    return results;
    
}

#pragma mark 页面即将出现
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

#pragma mark 观察者模式
/**
 *  当属性的值发生变化时，自动调用此方法
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    //NSLog(@"keyPath:%@  object:%@  change:%@   context:%@",keyPath,object,change,context);
    //判断属性是不是contentoffset
    if(![keyPath isEqualToString:@"contentOffset"]) return;
    //判断是否滑动
    if (self.tableview.dragging ) {
        NSLog(@"滑动了");
        //scrollview滑动的位移点y值
        int currentPoint=self.tableview.contentOffset.y;
        NSLog(@"当前y偏移的值是:%d",currentPoint);
        //判断是否刷新，否则不做任何操作
        BOOL isRe=!isReresh;
        if (!isReresh) {
            NSLog(@"没有刷新");
            [UIView animateWithDuration:0.3 animations:^{
                if (currentPoint<-35*1.5) {
                    NSLog(@"松开即可刷新");
                }else{
                    NSLog(@"下拉可刷新");
                }
            }];
            
        }else{
            NSLog(@"刷新");
        }
    }
    


}

#pragma mark 协议
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return students.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:tableCell];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCell];
    }
    Student *student=students[indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"id:%@   name:%@   sex:%@",student.sId,student.name,student.sex];
    
    cell.tag=student.sId;
    
    
    if (students.count==indexPath.row+1) {
        Student *s=students[indexPath.row];
        NSLog(@"最后一行:%@",s.sId);
       // currentIndex=[s.sId integerValue];
        currentIndex=indexPath.row+1;
    }
    
    return cell;

}


#pragma mark 增删查操作
- (IBAction)addStudent:(id)sender {
    NSString *name=self.nameTextField.text;
    NSString *sex=nil;
    if ([self.sexTextField.text isEqualToString:@"man"]) {
        sex=@"1";
    }else if([self.sexTextField.text isEqualToString:@"women"]){
    sex=@"0";
    }
    
    NSString *sql=@"insert into student(name,sex) values(?,?)";
    NSArray *paraments=@[name,sex];
    
    int result=[self update:sql withParamters:paraments];
    if (result==1) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"添加成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [alertView show];
        self.nameTextField.text=nil;
        self.sexTextField.text=nil;
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"添加失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [alertView show];
    }

    
}
@end
