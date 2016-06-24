//
//  TabBarController.m
//  TestSqLite3
//
//  Created by Roy on 16/6/23.
//  Copyright © 2016年 Roy. All rights reserved.
//

#import "TabBarController.h"
#import "ViewController.h"
#import "FMDatabaseViewController.h"

@interface TabBarController ()<UITabBarDelegate,UITabBarControllerDelegate>

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"选项卡控制器";
    
    ViewController *sqliteViewController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"sqliteView"];
    FMDatabaseViewController *fmbViewController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"fmdView"];
    
    self.viewControllers=@[sqliteViewController,fmbViewController];
    self.delegate=self;
    //self.tabBar.delegate=self;
    
    NSArray *titles=@[@"sqlite",@"fmdView"];
    for (int i=0; i<self.viewControllers.count; i++) {
        UIViewController *viewController=self.viewControllers[i];
        viewController.tabBarItem.title=titles[i];
    }
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
