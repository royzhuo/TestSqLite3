//
//  FMDatabaseViewController.h
//  TestSqLite3
//
//  Created by Roy on 16/6/22.
//  Copyright © 2016年 Roy. All rights reserved.
//  使用fmdb第三方类库

#import "ViewController.h"
#import "FMDB.h"



@interface FMDatabaseViewController : UIViewController

@property(nonatomic,strong) FMDatabase *fdb;

- (IBAction)createTable:(id)sender;

- (IBAction)addPerson:(id)sender;

- (IBAction)deletePerson:(id)sender;

- (IBAction)editPerson:(id)sender;

- (IBAction)queryPerson:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *ageTextField;

@property (weak, nonatomic) IBOutlet UITextField *addressTextField;

@end
