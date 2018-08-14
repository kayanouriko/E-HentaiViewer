//
//  QJBrowerCollectManager.m
//  EHenTaiViewer
//
//  Created by QinJ on 2018/8/13.
//  Copyright © 2018 kayanouriko. All rights reserved.
//

#import "QJBrowerCollectManager.h"
// coredata
#import "Gallery+CoreDataClass.h"
#import "Gallery+CoreDataProperties.h"
#import "GalleryPage+CoreDataClass.h"
#import "GalleryPage+CoreDataProperties.h"

@implementation QJBrowerCollectManager

+ (NSArray<GalleryPage *> *)getAllCollectPagesWithGid:(NSString *)gid {
    Gallery *gallery = [Gallery MR_findByAttribute:@"galleryid" withValue:gid].firstObject;
    if (nil == gallery) {
        return @[];
    }
    NSSet *galleryPage = gallery.galleryPage;
    NSSortDescriptor *pageDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"page" ascending:YES];
    return [galleryPage sortedArrayUsingDescriptors:@[pageDescriptor]];
}

+ (void)saveOnePageWithGid:(NSString *)gid pageIndex:(NSInteger)pageIndex smallImageUrl:(NSString *)smallImageUrl {
    // 添加
    Gallery *gallery = [Gallery MR_findByAttribute:@"galleryid" withValue:gid].firstObject;
    // 如果不存在,则创建一个
    if (nil == gallery) {
        gallery = [Gallery MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        gallery.galleryid = gid;
    }
    // 获取当前页的对象
    NSArray *array = [GalleryPage MR_findByAttribute:@"gallery" withValue:gallery];
    if (array.count) {
        // 查找是否存在
        NSPredicate *pagePredicate = [NSPredicate predicateWithFormat:@"page = %ld", pageIndex];
        NSArray *selectArray = [array filteredArrayUsingPredicate:pagePredicate];
        if (selectArray.count) {
            GalleryPage *galleryPage = selectArray.firstObject;
            galleryPage.page = pageIndex;
            galleryPage.smallImageUrl = smallImageUrl;
        }
        else {
            GalleryPage *galleryPage = [GalleryPage MR_createEntity];
            galleryPage.page = pageIndex;
            galleryPage.smallImageUrl = smallImageUrl;
            [gallery addGalleryPageObject:galleryPage];
        }
    }
    else {
        GalleryPage *galleryPage = [GalleryPage MR_createEntity];
        galleryPage.page = pageIndex;
        galleryPage.smallImageUrl = smallImageUrl;
        [gallery addGalleryPageObject:galleryPage];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+ (void)deleteOnePageWithGid:(NSString *)gid pageIndex:(NSInteger)pageIndex smallImageUrl:(NSString *)smallImageUrl {
    Gallery *gallery = [Gallery MR_findByAttribute:@"galleryid" withValue:gid].firstObject;
    if (gallery) {
        NSArray *array = [GalleryPage MR_findByAttribute:@"gallery" withValue:gallery];
        if (array.count) {
            NSPredicate *pagePredicate = [NSPredicate predicateWithFormat:@"page = %ld", pageIndex];
            NSArray *selectArray = [array filteredArrayUsingPredicate:pagePredicate];
            for (GalleryPage *page in selectArray) {
                [page MR_deleteEntity];
            }
            if (array.count <= 1) {
                // 如果没有书签了删除本身
                [gallery MR_deleteEntity];
            }
        }
        else {
            // 如果没有书签了删除本身
            [gallery MR_deleteEntity];
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}

@end
