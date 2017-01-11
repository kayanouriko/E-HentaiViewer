//
//  Favorites+CoreDataProperties.h
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/11.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "Favorites+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Favorites (CoreDataProperties)

+ (NSFetchRequest<Favorites *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *uploader;
@property (nullable, nonatomic, copy) NSString *posted;
@property (nullable, nonatomic, copy) NSString *category;
@property (nullable, nonatomic, copy) NSString *rating;
@property (nullable, nonatomic, copy) NSString *language;
@property (nullable, nonatomic, copy) NSString *thumb;
@property (nullable, nonatomic, copy) NSString *url;
@property (nullable, nonatomic, copy) NSString *title_jpn;
@property (nullable, nonatomic, copy) NSString *filecount;
@property (nullable, nonatomic, copy) NSString *filesize;

@end

NS_ASSUME_NONNULL_END
