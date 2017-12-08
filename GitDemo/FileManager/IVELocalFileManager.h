
#import <Foundation/Foundation.h>

@interface IVELocalFileManager : NSObject

/**
 项目根目录路径
 
 @return 项目根目录路径的绝对路径
 */
+ (NSString *)directoryPath;

/**
 创建文件夹

 @param relativePath 相对路径
 @return 绝对路径
 */
+ (NSString *)createDirectoryWithRelativePath:(NSString *)relativePath;

/**
 保存文件

 @param data 要保存的数据
 @param relativePath 相对路径
 @param fileName 文件名
 @return 是否保存成功
 */
+ (BOOL)saveData:(NSData *)data relativePath:(NSString *)relativePath fileName:(NSString *)fileName;


/**
 读取文件内容

 @param relativePath 相对路径
 @return 文件内容
 */
+ (NSData *)readDataWithRelativePath:(NSString *)relativePath;


/**
 获取文件目录下的所有文件属性

 @param dirPath 文件夹相对路径
 @return 所有文件列表
 */
+ (NSDictionary *)subItemWithDirPath:(NSString *)dirPath;


+ (NSDictionary *)itemAttributesWithItemPath:(NSString *)itemPath;
/**
 删除缓存数据

 @param relativePath 相对路径
 @return 是否删除成功
 */
+ (BOOL)deleteDataWithRelativePath:(NSString *)relativePath;

/**
 删除旧版本的数据

 @return 是否删除成功
 */
+ (BOOL)deleteOldLocaData;

/**
 清除所有本地数据

 @return 是否清除成功
 */
+ (BOOL)clearAllLocalData;
@end
