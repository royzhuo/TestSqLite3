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

@interface TabBarController ()<UITabBarControllerDelegate>

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
        //显示消息数量
        viewController.tabBarItem.badgeValue=@"11";
    }
    NSArray *array= self.tabBar.items;
    NSLog(@"ar:%@",array);
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark 协议
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSLog(@"shouldSelected");
    return true;
}
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"didSelected");
}



@end
