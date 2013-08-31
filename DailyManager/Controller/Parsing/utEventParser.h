//
//  utEventParser.h
//  TimeToEnjoy
//
//  Created by Lakshaya Chhabra on 12/12/11.
//  Copyright (c) 2011 TimeToEnjoy.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol uTEventDetailParsingFailedWithErrorDelegate <NSObject>

@optional


-(void) uTEventParsingFailedWithError :(NSError *)error;

@end

@protocol uTEventDetailDidCompleteAsync <NSObject>

@optional

-(void) uTEventParsingDidFinishWithData :(NSMutableArray *)data;
-(void) uTEventParsingDidFailedWithError :(NSError *)error;


@end


@interface utEventParser : NSObject<NSXMLParserDelegate, NSURLConnectionDelegate>
{
    NSMutableArray* recordsDictionaryArray;
}

@property (nonatomic, retain) NSMutableArray* recordsDictionaryArray;
@property (nonatomic, assign) id <uTEventDetailParsingFailedWithErrorDelegate> errorDelegate;
@property (nonatomic, assign) id <uTEventDetailDidCompleteAsync> dataDelegate;
@property (nonatomic, retain) NSMutableData *downloadedData;
-(BOOL)startParsing:(NSString*)urlStr;
-(void) startParsingAsynchronouslyWithRequest: (NSString *)urlStr;
-(id)init;
-(void) startParsingAsyncWithNSURLConnectionWithURLString:(NSString *)urlStr;
@end
