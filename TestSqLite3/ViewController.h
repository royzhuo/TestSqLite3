//
//  ViewController.h
//  TestSqLite3
//
//  Created by Roy on 16/6/20.
//  Copyright © 2016年 Roy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *testView;


@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *ageTextField;

@property (weak, nonatomic) IBOutlet UITextField *addressTextField;


- (IBAction)addPersonal:(id)sender;

- (IBAction)deletePerson:(id)sender;
- (IBAction)queryPerson:(id)sender;

- (IBAction)editPerson:(id)sender;


@end

