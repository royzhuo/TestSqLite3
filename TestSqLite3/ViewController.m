//
//  ViewController.m
//  TestSqLite3
//
//  Created by Roy on 16/6/20.
//  Copyright © 2016年 Roy. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title=@"aaa";
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(100, 100, 200, 100)];
    label.text=@"test sqlite3";
    
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
