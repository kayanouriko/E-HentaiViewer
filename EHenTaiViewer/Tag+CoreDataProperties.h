//
//  Tag+CoreDataProperties.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "Tag+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Tag (CoreDataProperties)

+ (NSFetchRequest<Tag *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *cname;
@property (nullable, nonatomic, copy) NSString *info;
@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
