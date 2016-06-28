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

/*
 
 1.UITabBar
 
 下方的工具条称为UITabBar ，如果UITabBarController有N个子控制器,那么UITabBar内部就会有N 个UITabBarButton作为子控件与之对应。
 
 注意：UITabBarButton在UITabBar中得位置是均分的，UITabBar的高度为49。
 
 UITabBarButton⾥面显⽰什么内容,由对应子控制器的tabBarItem属性来决定 
 
 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"选项卡控制器";
    
    ViewController *sqliteViewController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"sqliteView"];
    FMDatabaseViewController *fmbViewController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"fmdView"];
    UIViewController *tableviewRefreshTestController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"tableviewRefresh"];
    
    
    self.viewControllers=@[sqliteViewController,fmbViewController,tableviewRefreshTestController];
    self.delegate=self;
    //self.tabBar.delegate=self;
    
    NSArray *titles=@[@"sqlite",@"fmdView",@"tableview下拉刷新"];
    for (int i=0; i<self.viewControllers.count; i++) {
        UIViewController *viewController=self.viewControllers[i];
        viewController.tabBarItem.title=titles[i];
        //显示消息数量
        if(i==0)viewController.tabBarItem.badgeValue=@"11";
        
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
