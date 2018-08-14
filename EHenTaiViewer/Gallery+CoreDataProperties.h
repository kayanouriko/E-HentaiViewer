//
//  Gallery+CoreDataProperties.h
//  EHenTaiViewer
//
//  Created by QinJ on 2018/8/13.
//  Copyright © 2018 kayanouriko. All rights reserved.
//
//

#import "Gallery+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Gallery (CoreDataProperties)

+ (NSFetchRequest<Gallery *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *galleryid;
@property (nullable, nonatomic, retain) NSSet<GalleryPage *> *galleryPage;

@end

@interface Gallery (CoreDataGeneratedAccessors)

- (void)addGalleryPageObject:(GalleryPage *)value;
- (void)removeGalleryPageObject:(GalleryPage *)value;
- (void)addGalleryPage:(NSSet<GalleryPage *> *)values;
- (void)removeGalleryPage:(NSSet<GalleryPage *> *)values;

@end

NS_ASSUME_NONNULL_END
