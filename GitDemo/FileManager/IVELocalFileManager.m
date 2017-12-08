

#import "IVELocalFileManager.h"

static NSInteger const k_file_version = 1;
static NSString *const k_DIRECTORY_PREFIX = @"IVE_";

@implementation IVELocalFileManager
#pragma mark - 创建文件夹
+ (NSString *)createDirectoryWithRelativePath:(NSString *)relativePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *createPath = [NSString stringWithFormat:@"%@/%@",[self directoryPath],relativePath];
    
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        BOOL success = [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (success) {
            return createPath;
        } else {
            return nil;
        }
    }
    return createPath;
}
#pragma mark - 保存文件
+ (BOOL)saveData:(NSData *)data relativePath:(NSString *)relativePath fileName:(NSString *)fileName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self directoryPath],relativePath];
    
    BOOL success = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        success = [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (success) {
        BOOL result = [fileManager createFileAtPath:[NSString stringWithFormat:@"%@/%@",filePath,fileName] contents:data attributes:nil];
        return result;
    }
    return NO;
}

#pragma mark - 读取文件
+ (NSData *)readDataWithRelativePath:(NSString *)relativePath {
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self directoryPath],relativePath];
    return  [NSData dataWithContentsOfFile:filePath];
}


+ (NSDictionary *)subItemWithDirPath:(NSString *)dirPath {
    dirPath = [NSString stringWithFormat:@"%@/%@",[self directoryPath],dirPath];
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    NSMutableDictionary *filesAttributes = [NSMutableDictionary dictionary];
    for (NSInteger index = 0; index < files.count; index ++) {
        NSString *subPath = files[index];
        NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",dirPath,subPath] error:nil];
        [filesAttributes setValue:attributes forKey:subPath];
    }
    return filesAttributes;
}

+ (NSDictionary *)itemAttributesWithItemPath:(NSString *)itemPath {
    NSString *fullPath  = [NSString stringWithFormat:@"%@/%@",[self directoryPath],itemPath];
    NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:nil];
    return attributes;
}
#pragma mark - 删除

+ (BOOL)deleteDataWithRelativePath:(NSString *)relativePath {
    return  [[NSFileManager defaultManager] removeItemAtPath:relativePath error:nil];
}
#pragma mark ----删除非当前版本
+ (BOOL)deleteOldLocaData {
    NSString *documentDirectoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectoryPath error:nil];
    for (NSString *p in files) {
        NSError *error;
        if ([self isOldVersionDirectory:p]) {
            NSString *Path = [documentDirectoryPath stringByAppendingPathComponent:p];
            if ([[NSFileManager defaultManager] fileExistsAtPath:Path]) {
                [[NSFileManager defaultManager] removeItemAtPath:Path error:&error];
            }
        }
    }
    return YES;
}

#pragma mark ----清除所有数据
+ (BOOL)clearAllLocalData {
    NSString *documentDirectoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:documentDirectoryPath];
    for (NSString *p in files) {
        NSError *error;
        NSString *Path = [documentDirectoryPath stringByAppendingPathComponent:p];
        if ([[NSFileManager defaultManager] fileExistsAtPath:Path]) {
            [[NSFileManager defaultManager] removeItemAtPath:Path error:&error];
        }
    }
    return YES;
}

#pragma mark - private method
+ (BOOL)isOldVersionDirectory:(NSString *)directoryPath {
    NSError *error = NULL;
    NSString *regexString = [NSString stringWithFormat:@"^(%@)[0-9]+",k_DIRECTORY_PREFIX];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:directoryPath options:0 range:NSMakeRange(0, [directoryPath length])];
    if (result.range.length > 0 ) {
        NSString *appVersion = [directoryPath substringWithRange:NSMakeRange(k_DIRECTORY_PREFIX.length , directoryPath.length - k_DIRECTORY_PREFIX.length)];
        return [appVersion integerValue] < k_file_version;
    }
    return  NO;
}

+ (NSString *)directoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *createPath = [NSString stringWithFormat:@"%@/%@%td",pathDocuments,k_DIRECTORY_PREFIX,k_file_version];
    
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        BOOL success = [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (success) {
            return createPath;
        } else {
            return pathDocuments;
        }
    }
    return createPath;
}

@end
