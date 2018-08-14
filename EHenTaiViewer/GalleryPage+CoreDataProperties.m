//
//  GalleryPage+CoreDataProperties.m
//  EHenTaiViewer
//
//  Created by QinJ on 2018/8/13.
//  Copyright © 2018 kayanouriko. All rights reserved.
//
//

#import "GalleryPage+CoreDataProperties.h"

@implementation GalleryPage (CoreDataProperties)

+ (NSFetchRequest<GalleryPage *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"GalleryPage"];
}

@dynamic page;
@dynamic smallImageUrl;
@dynamic gallery;

@end
