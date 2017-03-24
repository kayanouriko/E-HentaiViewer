//
//  Entity+CoreDataProperties.m
//  ExReadViewer
//
//  Created by QinJ on 2017/3/10.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "Entity+CoreDataProperties.h"

@implementation Entity (CoreDataProperties)

+ (NSFetchRequest<Entity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
}

@dynamic testName;

@end
