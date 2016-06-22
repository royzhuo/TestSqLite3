//
//  Person.h
//  TestSqLite3
//
//  Created by Roy on 16/6/22.
//  Copyright © 2016年 Roy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property(assign,nonatomic) NSString *id;
@property(assign,nonatomic) NSString *name;
@property(assign,nonatomic) NSString *age;
@property(assign,nonatomic) NSString *address;

-(id) initWithId:(NSString *)id name:(NSString *) name age:(NSString *) age address:(NSString *)address;

@end
