//
//  Favorites+CoreDataProperties.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/11.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "Favorites+CoreDataProperties.h"

@implementation Favorites (CoreDataProperties)

+ (NSFetchRequest<Favorites *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Favorites"];
}

@dynamic title;
@dynamic uploader;
@dynamic posted;
@dynamic category;
@dynamic rating;
@dynamic language;
@dynamic thumb;
@dynamic url;
@dynamic title_jpn;
@dynamic filecount;
@dynamic filesize;

@end
