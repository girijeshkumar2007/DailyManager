//
//  AdFileParsing.m
//  DailyManager
//
//  Created by Girijesh Kumar on 18/04/13.
//  Copyright (c) 2013 Girijesh Kumar. All rights reserved.
//

#import "AdFileParsing.h"
#import "AppDelegate.h"


@implementation AdFileParsing
@synthesize recordsDictionaryArray;
@synthesize downloadedData;

NSString * tempString;
NSMutableDictionary * tempSingleRecord;

-(id)init
{
    if(self){
        self= [super init];
       // self.errorDelegate = nil;
       // self.dataDelegate = nil;
        self.downloadedData = nil;
    }
    return self;
}


-(BOOL)startParsing:(NSString*)urlStr
{
    NSURL * url=[[NSURL alloc] initWithString:urlStr];
    NSLog(@"utEventParser >>%@",url);
    __block BOOL parsing=NO;
    //dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSXMLParser *parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
    //[url release];
    
    [parser setDelegate:self];
    parsing=[parser parse];
    return parsing;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
 //   AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    if (appDelegate.isDeviceOnLine == TRUE) {
//        
//        if([appDelegate.userDefaults boolForKey:@"ANONYMOUSUSAGE"])
//           // [FlurryAnalytics logError:@"Error in Parsing uTEventXML" message:[parseError localizedDescription] error:parseError];
//        
//    }
    
    //[errorDelegate uTEventParsingFailedWithError:parseError];
    
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{
    
    recordsDictionaryArray=[[NSMutableArray alloc] init];
}
// sent when the parser begins parsing of the document.
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    
    //[parser release];
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"%@",elementName);
    if ([[elementName uppercaseString] isEqualToString:[@"ImgSrc" uppercaseString]]) {
        
        tempSingleRecord=[[NSMutableDictionary alloc] init] ;
        return;
    }
    tempString = [[NSString alloc] init];
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if([[elementName uppercaseString] isEqualToString:@"Link"])
    {
        [tempSingleRecord setValue:tempString forKey:@"Link"];
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"Src"])
    {
        [tempSingleRecord setValue:tempString forKey:@"Src"];
        return;
    }

    if ([[elementName uppercaseString] isEqualToString:[@"ImgSrc" uppercaseString]]){
        
        
        [recordsDictionaryArray addObject:tempSingleRecord];
        return;
    }
    
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    tempString = [tempString stringByAppendingString:string];
    
}
@end
