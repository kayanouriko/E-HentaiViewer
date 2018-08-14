//
//  Gallery+CoreDataProperties.m
//  EHenTaiViewer
//
//  Created by QinJ on 2018/8/13.
//  Copyright © 2018 kayanouriko. All rights reserved.
//
//

#import "Gallery+CoreDataProperties.h"

@implementation Gallery (CoreDataProperties)

+ (NSFetchRequest<Gallery *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Gallery"];
}

@dynamic galleryid;
@dynamic galleryPage;

@end
