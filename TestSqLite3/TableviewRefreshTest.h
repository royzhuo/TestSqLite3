//
//  TableviewRefreshTest.h
//  TestSqLite3
//
//  Created by Roy on 16/6/28.
//  Copyright © 2016年 Roy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableviewRefreshTest : UIViewController




@property (weak, nonatomic) IBOutlet UITableView *tableview;



@property (weak, nonatomic) IBOutlet UITextField *nameTextField;


@property (weak, nonatomic) IBOutlet UITextField *sexTextField;

@property (weak, nonatomic) IBOutlet UIButton *addBtn;


- (IBAction)addStudent:(id)sender;

@end
