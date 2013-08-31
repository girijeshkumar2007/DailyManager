//
//  utEventParser.m
//  TimeToEnjoy
//
//  Created by Lakshaya Chhabra on 12/12/11.
//  Copyright (c) 2011 TimeToEnjoy.com. All rights reserved.
//

#import "utEventParser.h"
#import "ASIHTTPRequest.h"
#import "uTemporisAppDelegate.h"
#import "FlurryAnalytics.h"

@implementation utEventParser

@synthesize recordsDictionaryArray;
@synthesize errorDelegate;
@synthesize dataDelegate;
@synthesize downloadedData;

NSString * tempString;
NSMutableDictionary * tempSingleRecord;


-(id)init
{
    if(self){
       self= [super init];
        self.errorDelegate = nil;
        self.dataDelegate = nil;
        self.downloadedData = nil;
    }
    return self;
}

#pragma Mark -
#pragma Mark NSURLConnection For Download

-(void) startParsingAsyncWithNSURLConnectionWithURLString:(NSString *)urlStr{
    
    NSURL * url=[[[NSURL alloc] initWithString:urlStr] autorelease];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;   
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:30];
    NSLog(@"startParsingAsyncWithNSURLConnectionWithURLString> %@",url);

    NSURLConnection *connection = nil;
    connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    [connection class];
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
//    NSString *resStr = [response responseString];
//    SBJSON *parser = [[SBJSON alloc] init];
//    NSDictionary *CompletionDic = [parser objectWithString:resStr error:nil];

    
    self.downloadedData = [NSMutableData data];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.downloadedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [dataDelegate uTEventParsingDidFailedWithError: error];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
   // NSLog(@"%@",self.downloadedData);
    
    NSXMLParser * parser=[[NSXMLParser alloc] initWithData:self.downloadedData] ;
    [parser setDelegate:self];
    [parser parse];
    
    NSLog(@"%@",self.recordsDictionaryArray);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [dataDelegate uTEventParsingDidFinishWithData:[[self.recordsDictionaryArray copy] autorelease]];

   
    
//    NSString *response =[[NSString alloc]initWithData:self.downloadedData encoding:NSASCIIStringEncoding];    
//    SBJSON *parser = [[SBJSON alloc] init];
//    NSMutableArray *CompletionArray = [parser objectWithString:response error:nil];
//    NSLog(@"data==%@",CompletionArray);
//    [dataDelegate uTEventParsingDidFinishWithData:[[CompletionArray copy] autorelease]];
}


#pragma Mark -
#pragma Mark ASIHttpRequest For Download

-(void) startParsingAsynchronouslyWithRequest: (NSString *)urlStr {
    
    NSURL * url=[[NSURL alloc] initWithString:urlStr];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSLog(@"startParsingAsynchronouslyWithRequest> %@",url);

     [request setCompletionBlock:^{
         
         __block BOOL parsing=NO;
         NSXMLParser * parser=[[NSXMLParser alloc] initWithData:[request responseData]] ;
         [parser setDelegate:self];
         parsing=[parser parse];
         [dataDelegate uTEventParsingDidFinishWithData:[[self.recordsDictionaryArray copy] autorelease]];
         if (request) {
             [request release];
         }
     }];
    [request setTimeOutSeconds:30];
    [request setFailedBlock:^{
        [dataDelegate uTEventParsingDidFailedWithError:[request error]];
        if (request) {
            [request release];
        }
    }];
    
    [request startAsynchronous];
    

    [url release];

    
}


#pragma Mark -
#pragma Mark SYNC CALL For Download


-(BOOL)startParsing:(NSString*)urlStr
{
    NSURL * url=[[NSURL alloc] initWithString:urlStr];
    NSLog(@"utEventParser >>%@",url);
    __block BOOL parsing=NO;
    //dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSXMLParser *parser=[[NSXMLParser alloc] initWithContentsOfURL:url];
    [url release];
    [parser setDelegate:self];
   
    parsing=[parser parse];
   // });
    return parsing;
}

#pragma Mark

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    uTemporisAppDelegate *appDelegate = (uTemporisAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (appDelegate.isDeviceOnLine == TRUE) {
        if([appDelegate.userDefaults boolForKey:@"ANONYMOUSUSAGE"])
            [FlurryAnalytics logError:@"Error in Parsing uTEventXML" message:[parseError localizedDescription] error:parseError];
        
    }

    [errorDelegate uTEventParsingFailedWithError:parseError];
    
}

- (void)parserDidStartDocument:(NSXMLParser *)parser{
    recordsDictionaryArray=[[NSMutableArray alloc] init];
}
// sent when the parser begins parsing of the document.
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    [parser release];
    
}
// sent when the parser has completed parsing. If this is encountered, the parse was successful.


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([[elementName uppercaseString] isEqualToString:@"UTEVENTS_RESULT"]||
        [[elementName uppercaseString] isEqualToString:@"UTEVENT_RESULT"]||
        [[elementName uppercaseString] isEqualToString:@"EVENTSREV1"]||
        [[elementName uppercaseString] isEqualToString:@"EVENTID"] ||
        [[elementName uppercaseString] isEqualToString:@"UTEVENTSBYNAME_RESULT"] ||
        [[elementName uppercaseString] isEqualToString:[@"uTEventsByName1_Result" uppercaseString]]||
        [[elementName uppercaseString] isEqualToString:[@"EventsResult" uppercaseString]]||
        [[elementName uppercaseString] isEqualToString:[@"uTEvent_V2_Result" uppercaseString]]) {
        
        tempSingleRecord=[[[NSMutableDictionary alloc] init] autorelease] ;
        return;
    }
    tempString = [[[NSString alloc] init] autorelease];
    
    
}
// sent when the parser finds an element start tag.
// In the case of the cvslog tag, the following is what the delegate receives:
//   elementName == cvslog, namespaceURI == http://xml.apple.com/cvslog, qualifiedName == cvslog
// In the case of the radar tag, the following is what's passed in:
//    elementName == radar, namespaceURI == http://xml.apple.com/radar, qualifiedName == radar:radar
// If namespace processing >isn't< on, the xmlns:radar="http://xml.apple.com/radar" is returned as an attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if([[elementName uppercaseString] isEqualToString:@"ADDRESS"])
    {
        [tempSingleRecord setValue:tempString forKey:@"address"];
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"ALLDAY"])
    {
        [tempSingleRecord setValue:tempString forKey:@"AllDay"];
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"CITY"])
    {
        [tempSingleRecord setValue:tempString forKey:@"city"];
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"COUNTRYNAME"])
    {
        [tempSingleRecord setValue:tempString forKey:@"CountryName"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"EVENTDESCRIPTION"])
    {
        [tempSingleRecord setValue:tempString forKey:@"EventDescription"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"EVENTEND"])
    {
        [tempSingleRecord setValue:tempString forKey:@"EventEnd"];
        
        return;
    }
    if ([[elementName uppercaseString] isEqualToString:[@"msg" uppercaseString]]) {
        [tempSingleRecord setValue:tempString forKey:@"ErrorCode"];
    }
    if([[elementName uppercaseString] isEqualToString:@"EVENTNAME"])
    {
        [tempSingleRecord setValue:tempString forKey:@"eventname"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"EVENTSTART"])
    {
        [tempSingleRecord setValue:tempString forKey:@"EventStart"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"EVENTURL"])
    {
        [tempSingleRecord setValue:tempString forKey:@"eventurl"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"DISTANCE"])
    {
        [tempSingleRecord setValue:tempString forKey:@"Distance"];
        
        return;
    }

    
    if([[elementName uppercaseString] isEqualToString:@"FREE"])
    {
        [tempSingleRecord setValue:tempString forKey:@"Free"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"IMAGEURL"])
    {
        [tempSingleRecord setValue:tempString forKey:@"ImageUrl"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"LATITUDE"])
    {
        [tempSingleRecord setValue:tempString forKey:@"latitude"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"LONGITUDE"])
    {
        [tempSingleRecord setValue:tempString forKey:@"longitude"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"MOVIECLIPURL"])
    {
        [tempSingleRecord setValue:tempString forKey:@"MovieClipUrl"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"NOTIFY"])
    {
        [tempSingleRecord setValue:tempString forKey:@"Notify"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"PERFORMERURL"])
    {
        [tempSingleRecord setValue:tempString forKey:@"PerformerUrl"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"POSTALCODE"])
    {
        [tempSingleRecord setValue:tempString forKey:@"postalcode"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"PRICE"])
    {
        [tempSingleRecord setValue:tempString forKey:@"price"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"PRICECURRENCY"])
    {
        [tempSingleRecord setValue:tempString forKey:@"PriceCurrency"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"PRICEHIGH"])
    {
        [tempSingleRecord setValue:tempString forKey:@"PriceHigh"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"PRICELOW"])
    {
        [tempSingleRecord setValue:tempString forKey:@"PriceLow"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"RECURSTRING"])
    {
        [tempSingleRecord setValue:tempString forKey:@"RecurString"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"REGION"])
    {
        [tempSingleRecord setValue:tempString forKey:@"region"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"TICKETSURL"])
    {
        [tempSingleRecord setValue:tempString forKey:@"TicketsUrl"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"UPDATEDATE"])
    {
        [tempSingleRecord setValue:tempString forKey:@"UpdateDate"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"VENUEID"])
    {
        [tempSingleRecord setValue:tempString forKey:@"VenueId"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"VENUENAME"])
    {
        [tempSingleRecord setValue:tempString forKey:@"VenueName"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"VENUEURL"])
    {
        [tempSingleRecord setValue:tempString forKey:@"VenueUrl"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"EVENTSOURCE"])
    {
        [tempSingleRecord setValue:tempString forKey:@"eventsource"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"UTURL"])
    {
        [tempSingleRecord setValue:tempString forKey:@"uTUrl"];
        
        return;
    }
    
    
    if([[elementName uppercaseString] isEqualToString:@"AD"])
    {
        [tempSingleRecord setValue:tempString forKey:@"ad"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"CATEGORY"])
    {
        [tempSingleRecord setValue:tempString forKey:@"category"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"MULTI"])
    {
        [tempSingleRecord setValue:tempString forKey:@"multi"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"PAGE"])
    {
        [tempSingleRecord setValue:tempString forKey:@"page"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"PAGESIZE"])
    {
        [tempSingleRecord setValue:tempString forKey:@"pagesize"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"TOTALRESULTS"])
    {
        [tempSingleRecord setValue:tempString forKey:@"totalresults"];
        
        return;
    }
    
    if([[elementName uppercaseString] isEqualToString:@"UTEMPORISID"])
    {
        [tempSingleRecord setValue:tempString forKey:@"uTemporisID"];
        
        return;
    }
    
    if ([[elementName uppercaseString] isEqualToString:@"EVENTSOURCEURL"]) {
        [tempSingleRecord setValue:tempString forKey:@"eventSourceUrl"];
        return;
    }
    
    
    if ([[elementName uppercaseString] isEqualToString:[@"LikeCount" uppercaseString]]) {
        [tempSingleRecord setValue:tempString forKey:@"LikeCount"]; 
        return;
    }
    
    if ([[elementName uppercaseString] isEqualToString:[@"IsUserLiked" uppercaseString]]) {
        [tempSingleRecord setValue:tempString forKey:@"IsUserLiked"];
        return;
    }
    if ([[elementName uppercaseString] isEqualToString:[@"AttendeeCount" uppercaseString]]) {
        [tempSingleRecord setValue:tempString forKey:@"AttendeeCount"];
        return;
    }
    if ([[elementName uppercaseString] isEqualToString:[@"IsUserSaved" uppercaseString]]) {
        [tempSingleRecord setValue:tempString forKey:@"IsUserSaved"];
        return;
    }
    if ([[elementName uppercaseString] isEqualToString:[@"Phone" uppercaseString]]) {
        
        [tempSingleRecord setValue:tempString forKey:@"Phone"];
        return;
    }
    
    
    if ([[elementName uppercaseString] isEqualToString:@"UTEVENTS_RESULT"]||
        [[elementName uppercaseString] isEqualToString:@"UTEVENT_RESULT"]||
        [[elementName uppercaseString] isEqualToString:@"EVENTSREV1"]||
        [[elementName uppercaseString] isEqualToString:@"EVENTID"] ||
        [[elementName uppercaseString] isEqualToString:@"UTEVENTSBYNAME_RESULT"] ||
        [[elementName uppercaseString] isEqualToString:[@"uTEventsByName1_Result" uppercaseString]]||
        [[elementName uppercaseString] isEqualToString:[@"EventsResult" uppercaseString]]||
        [[elementName uppercaseString] isEqualToString:[@"uTEvent_V2_Result" uppercaseString]]){
        
        
        [recordsDictionaryArray addObject:tempSingleRecord];
        return;
    }

}
// sent when an end tag is encountered. The various parameters are supplied as above.


-(void)dealloc {
    
    self.dataDelegate = nil;
    self.errorDelegate = nil;
    if (self.recordsDictionaryArray) {
        [recordsDictionaryArray release];
    }
    [super dealloc];
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
   tempString = [tempString stringByAppendingString:string];
    
}
// This returns the string of the characters encountered thus far. You may not necessarily get the longest character run. The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:


@end
