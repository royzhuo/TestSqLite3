//
//  Person.m
//  TestSqLite3
//
//  Created by Roy on 16/6/22.
//  Copyright © 2016年 Roy. All rights reserved.
//

#import "Person.h"

@implementation Person


-(id)initWithId:(NSString *)id name:(NSString *)name age:(NSString *)age address:(NSString *)address
{
    Person *p=[[Person alloc]init];
    p.name=name;
    p.age=age;
    p.address=address;
    p.id=id;
    return p;

}

@end
