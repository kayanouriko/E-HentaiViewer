//
//  GalleryPage+CoreDataProperties.h
//  EHenTaiViewer
//
//  Created by QinJ on 2018/8/13.
//  Copyright © 2018 kayanouriko. All rights reserved.
//
//

#import "GalleryPage+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface GalleryPage (CoreDataProperties)

+ (NSFetchRequest<GalleryPage *> *)fetchRequest;

@property (nonatomic) int64_t page;
@property (nullable, nonatomic, copy) NSString *smallImageUrl;
@property (nullable, nonatomic, retain) Gallery *gallery;

@end

NS_ASSUME_NONNULL_END
