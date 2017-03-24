//
//  Entity+CoreDataProperties.h
//  ExReadViewer
//
//  Created by QinJ on 2017/3/10.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "Entity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Entity (CoreDataProperties)

+ (NSFetchRequest<Entity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *testName;

@end

NS_ASSUME_NONNULL_END
