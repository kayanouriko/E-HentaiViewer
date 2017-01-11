//
//  QJDataManager.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/11.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJDataManager.h"

@interface QJDataManager ()

/**
 *  数据模型对象
 */
@property (nonatomic,strong) NSManagedObjectModel *model;
/**
 *  上下文
 */
@property (nonatomic,strong) NSManagedObjectContext *context;
/**
 *  持久性存储区
 */
@property (nonatomic,strong) NSPersistentStoreCoordinator *persistent;

@end

@implementation QJDataManager

- (instancetype)initWithCoreData:(NSString *)entityName modelName:(NSString *)modelName sqlPath:(NSString *)sqlPath success:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
    if (self = [super init]) {
        // 断言(实体名称和存储路径是否为nil)
        // ...
        
        _entityName = entityName;
        _modelName = modelName;
        _sqlPath = sqlPath;
        // 初始化上下文
        self.context = [[NSManagedObjectContext alloc] init];
        if (modelName) {
            //获取模型路径
            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
            //根据模型文件创建模型对象
            self.model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        } else { // 从应用程序包中加载模型文件
            self.model = [NSManagedObjectModel mergedModelFromBundles:nil];
        }
        
        // 以传入模型方式初始化持久化存储库
        self.persistent = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
        /*
         持久化存储库的类型：
         NSSQLiteStoreType  SQLite数据库
         NSBinaryStoreType  二进制平面文件
         NSInMemoryStoreType 内存库，无法永久保存数据
         虽然这3种类型的性能从速度上来说都差不多，但从数据模型中保留下来的信息却不一样
         在几乎所有的情景中，都应该采用默认设置，使用SQLite作为持久化存储库
         */
        // 添加一个持久化存储库并设置类型和路径，NSSQLiteStoreType：SQLite作为存储库
        NSError *error = nil;
        [self.persistent addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlPath] options:nil error:&error];
        if (error) {
            NSLog(@"添加数据库失败:%@",error);
            if (fail) {
                fail(error);
            }
        } else {
            NSLog(@"添加数据库成功");
            // 设置上下文所要关联的持久化存储库
            self.context.persistentStoreCoordinator = self.persistent;
            if (success) {
                success();
            }
        }
    }
    
    return self;
}

// 添加数据
- (void)insertNewEntity:(NSDictionary *)dict success:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
    if (!dict||dict.allKeys.count == 0) return;
    // 通过传入上下文和实体名称，创建一个名称对应的实体对象（相当于数据库一组数据，其中含有多个字段）
    NSManagedObject *newEntity = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:self.context];
    // 实体对象存储属性值（相当于数据库中将一个值存入对应字段)
    for (NSString *key in [dict allKeys]) {
        [newEntity setValue:[dict objectForKey:key] forKey:key];
    }
    // 保存信息，同步数据
    NSError *error = nil;
    BOOL result = [self.context save:&error];
    if (!result) {
        NSLog(@"添加数据失败：%@",error);
        if (fail) {
            fail(error);
        }
    } else {
        NSLog(@"添加数据成功");
        if (success) {
            success();
        }
    }
}

// 查询数据
- (void)readEntity:(NSArray *)sequenceKeys ascending:(BOOL)isAscending filterStr:(NSString *)filterStr success:(void(^)(NSArray *results))success fail:(void(^)(NSError *error))fail
{
    // 1.初始化一个查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 2.设置要查询的实体
    NSEntityDescription *desc = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.context];
    request.entity = desc;
    // 3.设置查询结果排序
    if (sequenceKeys&&sequenceKeys.count>0) { // 如果进行了设置排序
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *key in sequenceKeys) {
            /**
             *  设置查询结果排序
             *  sequenceKey:根据某个属性（相当于数据库某个字段）来排序
             *  isAscending:是否升序
             */
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:isAscending];
            [array addObject:sort];
        }
        if (array.count>0) {
            request.sortDescriptors = array;// 可以添加多个排序描述器，然后按顺序放进数组即可
        }
    }
    // 4.设置条件过滤
    if (filterStr) { // 如果设置了过滤语句
        NSPredicate *predicate = [NSPredicate predicateWithFormat:filterStr];
        request.predicate = predicate;
    }
    // 5.执行请求
    NSError *error = nil;
    NSArray *objs = [self.context executeFetchRequest:request error:&error]; // 获得查询数据数据集合
    if (error) {
        if (fail) {
            fail(error);
        }
    } else{
        if (success) {
            success(objs);
        }
    }
}

// 更新数据
- (void)updateEntity:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
    NSError *error = nil;
    [self.context save:&error];
    if (error) {
        NSLog(@"删除失败：%@",error);
        if (fail) {
            fail(error);
        }
    } else {
        if (success) {
            success();
        }
    }
    
}

// 删除数据
- (void)deleteEntity:(NSManagedObject *)entity success:(void(^)(void))success fail:(void(^)(NSError *error))fail
{
    // 传入需要删除的实体对象
    [self.context deleteObject:entity];
    // 同步到数据库
    NSError *error = nil;
    [self.context save:&error];
    if (error) {
        NSLog(@"删除失败：%@",error);
        if (fail) {
            fail(error);
        }
    } else {
        if (success) {
            success();
        }
    }
}

@end
