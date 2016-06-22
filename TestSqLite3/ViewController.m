//
//  ViewController.m
//  TestSqLite3
//
//  Created by Roy on 16/6/20.
//  Copyright © 2016年 Roy. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#import "Person.h"

#define DBNAME @"personalInfo.sqlite"
//const NSString *DBNAME=@"personalInfo.sqlite";
#define NAME @"name"
#define AGE @"age"
#define ADDRESS @"address"
#define TABLENAME @"personalInfo"


@interface ViewController ()
{
    sqlite3 *db;
    
    NSMutableArray *personalArray;
    
    

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    personalArray=[[NSMutableArray alloc]init];
    
    UIView *topview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.frame=CGRectMake(0, topview.frame.size.height/2, topview.frame.size.width, topview.frame.size.height/2);
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.text=@"sqlite3";
    //[titleLabel setTextColor:[UIColor whiteColor]];
    topview.backgroundColor=[UIColor yellowColor];
    [topview addSubview:titleLabel];
    
    [self.view addSubview:topview];
    
    
   
    
    //1.sqlite3的数据库文件的地址
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory=[paths firstObject];
//    NSString *path = [documentDirectory stringByAppendingPathComponent:DBNAME];
    
//    //2.open数据库文件
//    if(sqlite3_open([path UTF8String], &db) != SQLITE_OK){   //sqlite3_open()有数据库打开，无则创建数据库
//        sqlite3_close(db);
//        NSLog(@"打开数据库失败");
//    }
    
    [self createdataBase];
    
    //创建表
//    NSString *createTableSql=@"create table if not exists personalInfo(id integer primary key,name text,age text, address text)";
//    [self executeSql:createTableSql];
    
    
    //插入数据
//    NSString *personalSql1=[NSString stringWithFormat:@"insert into %@(%@,%@,%@) values('%@','%@','%@')",TABLENAME,NAME,AGE,ADDRESS,@"roy",@"28",@"xiamen"];
//    NSString *personalSql2=[NSString stringWithFormat:@"insert into %@(%@,%@,%@) values('%@','%@','%@')",TABLENAME,NAME,AGE,ADDRESS,@"alan",@"20",@"xiamen"];
    
//    [self executeSql:personalSql1];
//    [self executeSql:personalSql2];
   
    
    //查询数据
    NSString *searchPersonalSQL=[NSString stringWithFormat:@"select * from %@",TABLENAME];
   // [self query:searchPersonalSQL];
    
    [personalArray removeAllObjects];
    NSArray *persons=[self queryBySQL:searchPersonalSQL withParamters:nil];
    for (Person *person in persons) {
        NSString *value=[NSString stringWithFormat:@"name:%@,age:%@,address:%@",person.name,person.age,person.address];
        [personalArray addObject:value];
    }
    [self showPersonInfo];
    
}

#pragma mark 创建数据库
-(void) createdataBase{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:DBNAME];
    //2.open数据库文件
    if(sqlite3_open([path UTF8String], &db) != SQLITE_OK){   //sqlite3_open()有数据库打开，无则创建数据库
        sqlite3_close(db);
        NSLog(@"打开数据库失败");
    }


}

#pragma mark 创建表
-(void) createTable
{
        NSString *createTableSql=@"create table if not exists personalInfo(id integer primary key,name text,age text, address text)";
        [self executeSql:createTableSql];

}

#pragma mark 执行非查询的sql语句
-(void) executeSql:(NSString *) sql
{
    char *err;
    if(sqlite3_exec(db,[sql UTF8String],nil,nil,&err) != SQLITE_OK){
        NSLog(@"数据库操作数据失败!");
        sqlite3_close(db);
    }
    
}

#pragma mark 执行查询语句
-(void) query:(NSString *) sql
{
    sqlite3_stmt *stmt;
    NSLog(@"sql:%@",sql);
    
   [personalArray removeAllObjects];
    
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil)== SQLITE_OK) {             //准备sql语句，包含sqlite3_exec();
        NSLog(@"查询结果集的值:%d",sqlite3_step(stmt));
        //执行预编译
        while(sqlite3_step(stmt)==SQLITE_ROW){
           char *name= sqlite3_column_text(stmt,1);
            NSString *nametr=[[NSString alloc]initWithUTF8String:name];
            
            char *age=sqlite3_column_text(stmt, 2);
            NSString *ageStr=[[NSString alloc]initWithUTF8String:age];
            
            char *address=sqlite3_column_text(stmt, 3);
            NSString *addressStr=[[NSString alloc]initWithUTF8String:address];
            
            NSLog(@"name:%@,age:%@,address:%@",nametr,ageStr,addressStr);
            NSString *value=[NSString stringWithFormat:@"name:%@,age:%@,address:%@",nametr,ageStr,addressStr];
            [personalArray addObject:value];
        }
        //释放资源
        sqlite3_finalize(stmt);
    }
   // sqlite3_close(db);
    [self showPersonInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark view层
-(void) showPersonInfo{


    if(personalArray.count>0){
        NSMutableString *resuts=[[NSMutableString alloc]init];
        int i=1;
        for (NSString *value in personalArray) {
            [ resuts appendFormat:@"第%d条:%@ \n ",i,value ];
            i++;
        }
        self.testView.text=resuts;
    }else self.testView.text=@"没有数据";

}

#pragma mark service增删查改
- (IBAction)addPersonal:(id)sender {
    NSString *name=[self.nameTextField.text isEqualToString:@""]? @"":self.nameTextField.text;
    NSString *age=[self.ageTextField.text isEqualToString:@""]? @"":self.ageTextField.text;
    NSString *address=[self.addressTextField.text isEqualToString:@""]? @"":self.addressTextField.text;
    
    if(([name isEqualToString:@""]) && ([age isEqualToString:@""]) && ([address isEqualToString:@""]) ){
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"内容不能为空" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [alertView show];
        return ;
    }
    
    NSString *sql=[NSString stringWithFormat:@"insert or replace into %@(%@,%@,%@) values(?,?,?)",TABLENAME,NAME,AGE,ADDRESS];
    NSMutableArray *params=@[name,age,address];
    int result=[self update:sql withParamters:params];
    if(result==0){
        NSLog(@"添加失败");
        result;
    }else if(result==1){
        NSLog(@"添加成功");
        self.nameTextField.text=NULL;
        self.ageTextField.text=@"";
        self.addressTextField.text=@"";
        
        //更新列表
        [self query:[NSString stringWithFormat:@"select * from %@",TABLENAME]];
    }
}

- (IBAction)deletePerson:(id)sender {
    NSString *name=self.nameTextField.text;
    NSString *age=[self.ageTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *address=[self.ageTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *array=@[name];
    NSMutableArray *persons=[NSMutableArray array];
    //查询个人信息
    NSString *querySql=NULL;
    if([name isEqualToString:@""] || name==nil){
        UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"请输入姓名" message:@"仅通过名字删除" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [view show];
        return;
    }
    
   querySql=[NSString stringWithFormat:@"select * from %@ where %@=?",TABLENAME,NAME];
    
    persons=[self queryBySQL:querySql withParamters:array];
    if(persons.count<1){
        UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"数据库中没有相关数据" message:@"请输入正确信息" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [view show];

        return;
    }
    for (Person *person in persons) {
        
         NSString *sql=[NSString stringWithFormat:@"delete from %@ where id=?",TABLENAME];
        NSArray *parameters=@[person.id];
      int result=  [self update:sql withParamters:parameters];
        if (result==0) {
            NSLog(@"删除失败");
            return;
        }else if (result==1){
             NSLog(@"删除成功");
            self.nameTextField.text=NULL;
            self.ageTextField.text=@"";
            self.addressTextField.text=@"";
        }
        
    }
    //更新列表
    //[self query:[NSString stringWithFormat:@"select * from %@",TABLENAME]];
    NSArray *personList=  [self queryBySQL:[NSString stringWithFormat:@"select * from %@",TABLENAME] withParamters:nil];
    [personalArray removeAllObjects];
    for (Person *person in personList) {
        NSString *value=[NSString stringWithFormat:@"name:%@,age:%@,address:%@",person.name,person.age,person.address];
        [personalArray addObject:value];
    }
    [self showPersonInfo];
   
    
    
}

- (IBAction)queryPerson:(id)sender {
    NSString *name=[self.nameTextField.text isEqualToString:@""]? nil:self.nameTextField.text;
    NSString *age=[self.ageTextField.text isEqualToString:@""]? nil:self.ageTextField.text;
    NSString *address=[self.addressTextField.text isEqualToString:@""]? nil:self.addressTextField.text;
    
    NSMutableArray *paramters=[NSMutableArray array];
    NSString *sql=[[NSString alloc]init];
    if(name!=nil&&age!=nil &&address!=nil){
        sql=[NSString stringWithFormat:@"select * from %@ where %@=? and %@=? and %@=?",TABLENAME,NAME,AGE,ADDRESS];
        paramters=@[name,age,address];
    }else if (name!=nil && age!=nil){
        sql=[NSString stringWithFormat:@"select * from %@ where %@=? and %@=? ",TABLENAME,NAME,AGE];
        paramters=@[name,age];
    }else if (name != nil && address!=NULL){
        sql=[NSString stringWithFormat:@"select * from %@ where %@=? and %@=? ",TABLENAME,NAME,ADDRESS];
        paramters=@[name,address];
    }else if (address!=nil && name==nil && age==nil){
        sql=[NSString stringWithFormat:@"select * from %@ where %@=? ",TABLENAME,ADDRESS];
        paramters=@[address];
    }else if (name!=nil && age==nil && age==nil){
        sql=[NSString stringWithFormat:@"select * from %@ where %@=? ",TABLENAME,NAME];
        paramters=@[name];
    }else if (name==nil&& age==nil&&age==nil){
        sql=[NSString stringWithFormat:@"select * from %@  ",TABLENAME];
        paramters=nil;
    }else{
        if (sql==nil) {
            UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"数据不全" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
            [view show];
            return;
        }
    
    }
    
    NSArray *persons=[self queryBySQL:sql withParamters:paramters];
    if(persons.count<1){
        UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"数据库中没有相关数据" message:@"请输入正确信息" delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [view show];
        
        return;
    }
    [personalArray removeAllObjects];
    for (Person *person in persons) {
    
        self.nameTextField.text=@"";
        self.ageTextField.text=@"";
        self.addressTextField.text=@"";
        NSString *value=[NSString stringWithFormat:@"name:%@,age:%@,address:%@",person.name,person.age,person.address];
            [personalArray addObject:value];
            [self showPersonInfo];
            
      
        
    }

    
    
}

- (IBAction)editPerson:(id)sender {
    
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
    
    NSMutableArray *persons=[NSMutableArray array];
    sqlite3_stmt *stmt;
    if( sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil)==SQLITE_OK){
        if (paramters!=NULL || paramters.count>0) {
            for (int i=0; i<paramters.count; i++) {
                sqlite3_bind_text(stmt, i+1, [paramters[i] UTF8String], -1, nil);
            }
        }
        
        
        while(sqlite3_step(stmt)==SQLITE_ROW){
            int pId=sqlite3_column_int(stmt,0);
            char *pName=sqlite3_column_text(stmt, 1);
            char *pAge=sqlite3_column_text(stmt,2);
            char *pAddress=sqlite3_column_text(stmt,3);
            
            
            
            Person *p=[[Person alloc]initWithId:[ NSString stringWithFormat:@"%d",pId ] name:[[NSString alloc]initWithUTF8String:pName] age:[[NSString alloc]initWithUTF8String:pAge] address:[[NSString alloc]initWithUTF8String:pAddress]];
            
            [persons addObject:p];
        
        }
    }
    
    return persons;

}
@end
