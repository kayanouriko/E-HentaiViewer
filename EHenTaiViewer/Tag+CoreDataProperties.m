//
//  Tag+CoreDataProperties.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "Tag+CoreDataProperties.h"

@implementation Tag (CoreDataProperties)

+ (NSFetchRequest<Tag *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Tag"];
}

@dynamic cname;
@dynamic info;
@dynamic name;

@end
