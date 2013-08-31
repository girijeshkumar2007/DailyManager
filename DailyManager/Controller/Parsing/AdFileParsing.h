//
//  AdFileParsing.h
//  DailyManager
//
//  Created by Girijesh Kumar on 18/04/13.
//  Copyright (c) 2013 Girijesh Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdFileParsing : NSObject<NSXMLParserDelegate>{
    
}
@property (nonatomic, retain) NSMutableArray* recordsDictionaryArray;
@property (nonatomic, retain) NSMutableData *downloadedData;
-(BOOL)startParsing:(NSString*)urlStr;

@end
