//
//  Reflect-Bridging.h
//  ReflectFramework
//
//  Created by Bruno Fernandes on 18/03/16.
//  Copyright © 2016 BFS. All rights reserved.
//

@import Foundation;

#import "sqlite3.h"

typedef struct SQLiteHandle SQLiteHandle; // CocoaPods workaround

NS_ASSUME_NONNULL_BEGIN
typedef NSString * _Nullable (^_SQLiteTokenizerNextCallback)(const char * input, int * inputOffset, int * inputLength);
int _SQLiteRegisterTokenizer(SQLiteHandle * db, const char * module, const char * tokenizer, _Nullable _SQLiteTokenizerNextCallback callback);
NS_ASSUME_NONNULL_END
