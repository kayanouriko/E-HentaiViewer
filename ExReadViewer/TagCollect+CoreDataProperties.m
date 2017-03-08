//
//  TagCollect+CoreDataProperties.m
//  
//
//  Created by QinJ on 2017/3/8.
//
//

#import "TagCollect+CoreDataProperties.h"

@implementation TagCollect (CoreDataProperties)

+ (NSFetchRequest<TagCollect *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"TagCollect"];
}

@dynamic tagName;
@dynamic tagUrl;

@end
