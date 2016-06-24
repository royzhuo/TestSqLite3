//
//  FMDatabaseViewController.m
//  TestSqLite3
//
//  Created by Roy on 16/6/22.
//  Copyright © 2016年 Roy. All rights reserved.
//

#import "FMDatabaseViewController.h"
#import "Person.h"

#define tableViewCell @"tableViewCell"
#define DBNAME @"fmPerson.sqlite"
@interface FMDatabaseViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    UITextField *tableTextField;
    NSMutableArray *persons;
    NSMutableArray *selectValues;
}

@end

@implementation FMDatabaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    persons=[[NSMutableArray alloc]init];
    selectValues=[[NSMutableArray alloc]init];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
   
    //打开数据库
    [self createDataBase];
    
    //查询
   FMResultSet *resultSet= [self queryBySQL:@"select * from persons" withParamters:nil];
    if(resultSet==nil){
        UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"查询失败了" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [view show];
        return;
    }else {
        [self showData:resultSet];
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIView *topview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.frame=CGRectMake(0, topview.frame.size.height/2, topview.frame.size.width, topview.frame.size.height/2);
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.text=@"FMDB第三方库";
    [topview addSubview:titleLabel];
    [self.view addSubview:topview];
    topview.backgroundColor=[UIColor yellowColor];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
#pragma mark 展现数据
-(void) showData:(FMResultSet *)resultSet
{

    [persons removeAllObjects];
    NSDictionary *dic=[[NSDictionary alloc]init];
    while ([resultSet next]) {
       NSString *name=[resultSet stringForColumn:@"name"];
        NSString *age=[resultSet stringForColumn:@"age"];
        NSString *address=[resultSet stringForColumn:@"address"];
        int pid=[resultSet intForColumn:@"id"];
        Person *p=[[Person alloc]initWithId:[NSString stringWithFormat:@"%d",pid] name:name age:age address:address];
        [persons addObject:p];
    }
    
    [self.tableView reloadData];

}


#pragma mark tableview协议
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return persons.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:tableViewCell];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewCell];
    }
    Person *person=persons[indexPath.row];
    cell.tag=indexPath;
    //id
    UILabel *idLabel=[cell viewWithTag:1000];
    idLabel.text=person.id;
    //name
    UILabel *nameLabel=[cell viewWithTag:2000];
    nameLabel.text=person.name;
    //age
    UILabel *ageLabel=[cell viewWithTag:3000];
    ageLabel.text=person.age;
    //address
    UILabel *addressLabel=[cell viewWithTag:4000];
    addressLabel.text=person.address;
    
    if ([selectValues containsObject:person]) {
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }else cell.accessoryType=UITableViewCellAccessoryNone;
   
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"选中");
  //  UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    Person *p=persons[indexPath.row];
    if ([selectValues containsObject:p]==YES) {
        [selectValues removeObject:p];
        self.nameTextField.text=@"";
        self.ageTextField.text=@"";
        self.addressTextField.text=@"";
    }else{
        [selectValues addObject:p];
        self.nameTextField.text=p.name;
        self.ageTextField.text=p.age;
        self.addressTextField.text=p.address;
    }
    
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];

}

#pragma mark 按钮点击事件
- (IBAction)createTable:(id)sender {
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"表名" message:nil preferredStyle:UIAlertControllerStyleAlert];
   // UITextField *tableNameTextField=[[UITextField alloc]init];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSLog(@"输出:%@",textField.text);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTextFieldValue:) name:UITextFieldTextDidChangeNotification object:textField];
        
    }];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sureAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self createTableByName:tableTextField.text];
    }];
    sureAction.enabled=NO;
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)addPerson:(id)sender {
    NSString *name=[self.nameTextField.text isEqualToString:@""]? nil:self.nameTextField.text;
    NSString *age=self.ageTextField.text;
    NSString *address=self.addressTextField.text;
    if (name==nil) {
        UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"姓名不能为空" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [view show];
        return;
    }
    NSArray *array=@[name,age,address];
    NSString *sql=@"insert into persons(name,age,address) values(?,?,?) ";
    BOOL isSuccess=[self excuteUpdateWithSql:sql withParamters:array];
    if(isSuccess==true) {
        UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"添加成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [view show];
     self.nameTextField.text=@"";
        self.ageTextField.text=@"";
        self.addressTextField.text=@"";
      FMResultSet *resultSet=  [self queryBySQL:@"select * from persons" withParamters:nil];
        [self showData:resultSet];
        [selectValues removeAllObjects];
        
    }else {
        UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"添加失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [view show];
        return;
    }
    
}

- (IBAction)deletePerson:(id)sender {
    
    if (selectValues.count==0) {
        UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"请选择对象" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [view show];
        return;
    }else {
        BOOL isSuccess = false;
        NSMutableArray *indexPaths=[[NSMutableArray alloc]init];
        for (Person *person in selectValues) {
            int pid=[person.id intValue];
          //isSuccess=[self.fdb executeUpdateWithFormat:@"delete from persons where id=(?)",pid];
            isSuccess=[self excuteUpdateWithSql:@"delete from persons where id=?" withParamters:@[person.id]];
            if(isSuccess==true){
            int  index=[persons indexOfObject:person];
                NSIndexPath *indexPath=[NSIndexPath indexPathForItem:index inSection:0];
                [indexPaths addObject:indexPath];
            }
            
        }
        
        [persons removeObjectsInArray:selectValues];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
        
        [selectValues removeAllObjects];
        
        
    }
    
}

- (IBAction)editPerson:(id)sender {
    if (selectValues.count>1) {
        UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"最多只能选择一条" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [view show];
        return;
    }else if (selectValues.count==0){
        UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"请选择数据" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
        [view show];
        return;
    }else{
        Person *person=selectValues[0];
        int personIndex=[persons indexOfObject:person];
        NSString *sql=@"update persons set name=? , age =? , address=? where id=?";
        NSArray *parameters=@[self.nameTextField.text,self.ageTextField.text,self.addressTextField.text,person.id];
        BOOL isSuccess=[self excuteUpdateWithSql:sql withParamters:parameters];
        Person *person2=[[Person alloc]init];
        if (isSuccess==YES) {
            NSString *sql=@"select * from persons where id=?";
            NSArray *array=@[person.id];
            FMResultSet *resultSet=[self queryBySQL:sql withParamters:array];
            if(resultSet!= nil ){
                while ([resultSet next]) {
                    NSString *name=[resultSet stringForColumn:@"name"];
                    NSString *age=[resultSet stringForColumn:@"age"];
                    NSString *address=[resultSet stringForColumn:@"address"];
                    int pid=[resultSet intForColumn:@"id"];
                    person2.id=[NSString stringWithFormat:@"%d",pid];
                    person2.name=name;
                    person2.age=age;
                    person2.address=address;
                }
            }
             [persons replaceObjectAtIndex:personIndex withObject:person2];
            NSIndexPath *indexPath=[NSIndexPath indexPathForItem:personIndex inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            
            self.nameTextField.text=@"";
            self.ageTextField.text=@"";
            self.addressTextField.text=@"";
            [selectValues removeAllObjects];
        }
        

    }
}

- (IBAction)queryPerson:(id)sender {
    NSString *name=[self.nameTextField.text isEqualToString:@""]? nil:self.nameTextField.text;
    NSString *age=[self.ageTextField.text isEqualToString:@""]? nil:self.ageTextField.text;
    NSString *address=[self.addressTextField.text isEqualToString:@""]? nil:self.addressTextField.text;
    
    NSMutableArray *paramters=[NSMutableArray array];
    NSString *sql=[[NSString alloc]init];
    if(name!=nil&&age!=nil &&address!=nil){
        sql=@"select * from persons where name=? and age=? and address=?";
        paramters=@[name,age,address];
    }else if (name!=nil && age!=nil){
        sql=@"select * from persons where name=? and age=?";
        paramters=@[name,age];
    }else if (name != nil && address!=NULL){
        sql=@"select * from persons where name=? and address=?";
        paramters=@[name,address];
    }else if (address!=nil && name==nil && age==nil){
        sql=@"select * from persons where address=?";
        paramters=@[address];
    }else if (name!=nil && age==nil && age==nil){
        sql=@"select * from persons where name=?";
        paramters=@[name];
    }else if (name==nil&& age==nil&&age==nil){
        sql=@"select * from persons ";
        paramters=nil;
    }else{
        if (sql==nil) {
            UIAlertView *view=[[UIAlertView alloc]initWithTitle:@"数据不全" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
            [view show];
            return;
        }
        
    }
    
    FMResultSet *result=[self queryBySQL:sql withParamters:paramters];
    [self showData:result];
}

#pragma mark 消息中心
//获取文本框的数据
-(void) getTextFieldValue:(NSNotificationCenter *) notificationCenter
{
    UIAlertController *alertController=(UIAlertController *)self.presentedViewController;
    if(alertController){
        UIAlertAction *sureAction=[alertController.actions lastObject];
        UITextField *textField=[alertController.textFields firstObject];
        sureAction.enabled=textField.text.length>0;
        if (sureAction.enabled==true) {
            tableTextField=textField;
        }
    
    }
    
}

#pragma mark FMDB
-(void) createDataBase
{
    //获取数据库路径
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=[paths firstObject];
    NSString *dataPath=[path stringByAppendingPathComponent:DBNAME];
    //获取数据库
    self.fdb=[FMDatabase databaseWithPath:dataPath];
    //打开数据库
    if([self.fdb open]){
        NSLog(@"数据库打开成功");
    }

}

-(void) createTableByName:(NSString *) tableName
{
    NSString *sql=[NSString stringWithFormat:@"create table %@ (id integer primary key autoincrement,name text not null ,age text,address text)",tableName];
    if(  [self.fdb executeUpdate:sql]==true){
        NSLog(@"table create successs");
    }else {
        NSLog(@"table create fial");
        [self.fdb close];
    }
}

//封装更新操作
-(BOOL) excuteUpdateWithSql:(NSString *) sql withParamters:(NSArray*) array
{
    BOOL isSUCEESS=NO;
    
   if(array!=nil) isSUCEESS=[self.fdb executeUpdate:sql withArgumentsInArray:array];
   else if(array == nil) isSUCEESS=[self.fdb executeUpdate:sql];
    
    return isSUCEESS;
    }
//封装查询
-(FMResultSet *) queryBySQL:(NSString *) sql withParamters:(NSArray *) array
{
    FMResultSet *resultSet;
    if(array==nil){
     resultSet=  [self.fdb executeQuery:sql];
    }else {
        resultSet=[self.fdb executeQuery:sql withArgumentsInArray:array];
    }
    return resultSet;
}
@end
