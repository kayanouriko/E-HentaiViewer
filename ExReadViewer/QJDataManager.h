//
//  QJDataManager.h
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/11.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//
// 来源:http://www.jianshu.com/p/113047a478c5

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface QJDataManager : NSObject

/**
 *  获取数据库存储的路径
 */
@property (nonatomic,copy,readonly) NSString *sqlPath;
/**
 *  获取.xcdatamodeld文件的名称
 */
@property (nonatomic,copy,readonly) NSString *modelName;
/**
 *  获取.xcdatamodeld文件中创建的实体的名称
 */
@property (nonatomic,copy,readonly) NSString *entityName;

/**
 *  创建CoreData数据库
 *
 *  @param entityName 实体名称
 *  @param modelName  .xcdatamodeld文件名称(为nil则主动从程序包加载模型文件)
 *  @param sqlPath    数据库存储的路径
 *  @param success    成功回调
 *  @param fail       失败回调
 *
 *  @return 返回CoreDataAPI对象
 */
- (instancetype)initWithCoreData:(NSString *)entityName modelName:(NSString *)modelName sqlPath:(NSString *)sqlPath success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/**
 *  插入数据
 *
 *  @param dict 字典中的键值对必须要与实体中的每个名字一一对应
 *  @param success    成功回调
 *  @param fail       失败回调
 */
- (void)insertNewEntity:(NSDictionary *)dict success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/**
 *  查询数据
 *
 *  @param sequenceKeys 数组高级排序（数组里存放实体中的key，顺序按自己需要的先后存放即可），实体key来排序
 *  @param isAscending  是否上升排序
 *  @param filterStr    过滤语句
 *  @param success      成功后结果回调
 *  @param fail         失败回调
 */
- (void)readEntity:(NSArray *)sequenceKeys ascending:(BOOL)isAscending filterStr:(NSString *)filterStr success:(void(^)(NSArray *results))success fail:(void(^)(NSError *error))fail;

/**
 *  删除数据
 *
 *  @param entity  NSManagedObject
 *  @param success 成功回调
 *  @param fail    失败回调
 */
- (void)deleteEntity:(NSManagedObject *)entity success:(void(^)(void))success fail:(void(^)(NSError *error))fail;

/**
 *  更新数据
 *
 *  @param success 成功回调
 *  @param fail    失败回调
 */
- (void)updateEntity:(void(^)(void))success fail:(void(^)(NSError *error))fail;

@end
