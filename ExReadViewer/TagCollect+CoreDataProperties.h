//
//  TagCollect+CoreDataProperties.h
//  
//
//  Created by QinJ on 2017/3/8.
//
//

#import "TagCollect+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TagCollect (CoreDataProperties)

+ (NSFetchRequest<TagCollect *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *tagName;
@property (nullable, nonatomic, copy) NSString *tagUrl;

@end

NS_ASSUME_NONNULL_END
