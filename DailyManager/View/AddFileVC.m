//
//  AddFileVC.m
//  DailyManager
//
//  Created by Girijesh Kumar on 18/04/13.
//  Copyright (c) 2013 Girijesh Kumar. All rights reserved.
//

#import "AddFileVC.h"
#import "AFNetworking.h"
#import "SBJSON.h"
#import "AdFileParsing.h"

@interface AddFileVC ()

@property(nonatomic,strong)IBOutlet UIView *errorView;
@property(nonatomic,strong)IBOutlet UILabel *errorLb;
@property(nonatomic,strong)IBOutlet UIActivityIndicatorView *activity;
@end

@implementation AddFileVC
@synthesize errorLb,errorView,activity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    errorLb.textColor=[UIColor whiteColor];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self callparsing];
}

-(void)callparsing
{
    NSString *urlString=@"http://www.nanoerasoft.com/And/AdsReq.aspx?pid=a500&ch=1&adsid=1&cid=111&imei=12222";
    AdFileParsing* parser=[[AdFileParsing alloc] init] ;
   // parser.errorDelegate = self;
    [parser startParsing:urlString];
    
    @try {
        NSMutableArray *eventDetailDictionary = [parser.recordsDictionaryArray objectAtIndex:0];
        
        NSLog(@"%@",eventDetailDictionary);
    }
    @catch (NSException *exception) {
        
        NSLog(@"%@",exception.description);
        //[self uTEventParsingFailedWithError:nil];
        return;
    }
    @finally {
        
    }
}
//-(void)GetAttendiesWebService:(int)Page
//{
//    
//    AFHTTPClient *client= [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://dsvr.utemporis.com"]];
//    NSString *url=[NSString stringWithFormat:@"/uT.svc/UserCalendar/GetAttendee?"];
//    
//    NSLog(@"%@",url);
//    
//    [self StartActivityIndicator];
//    
//    [client getPath:url parameters:nil success:
//     ^(AFHTTPRequestOperation *opration,id responseObject){
//         
//         [self StopActivityIndicator];
//         
//         NSString *response = [opration responseString];
//         
//        NSLog(@"Susess %@",response );
//         
//         SBJSON *parserJson = [[SBJSON alloc] init];
//         NSDictionary *CompletionDic = [parserJson objectWithString:response error:nil];
//         NSLog(@"Susess %@",CompletionDic );
//         // NSLog(@"Count==%d",[[CompletionDic objectForKey:@"users"] count]);
//         
//         if ([[CompletionDic objectForKey:@"response_string"]isEqualToString:@"Unexpected Error has occurred."])
//         {
//             self.errorLb.text=@"Unexpected Error has occurred.";
//             [self animationStep1];
//         }
//         else{
//             
//             
//         }
//     }
//     
//            failure:
//     ^(AFHTTPRequestOperation *opration,NSError *error){
//         
//         
//         [self StopActivityIndicator];
//         
//         if ([error localizedDescription]) {
//             
//             if ([[error localizedDescription]isEqualToString:@"The Internet connection appears to be offline."]) {
//                 
//                 self.errorLb.text=@"You are not connected to the Internet.";
//                 [self animationStep1];
//             }
//         }
//         NSLog(@"%@",error);
//     }];
//}


#pragma mark -
#pragma mark Animation Method
-(void)animationStep1{
    
    [self.errorView removeFromSuperview];
    self.errorView.frame=CGRectMake(0,44, self.errorView.frame.size.width, 0);
    [self.view addSubview:self.errorView];
    
    [UIView animateWithDuration:0.30 animations:^{
        
        errorView.frame=CGRectMake(0, 44, self.errorView.frame.size.width, 35);
	} completion:^(BOOL success) {
        
		[self animationStep2];
	}];
    
}
- (void) animationStep2{
    
    [UIView animateWithDuration:0.2 delay:1 options:UIViewAnimationOptionTransitionNone animations:^{
        
        errorView.frame=CGRectMake(0,44, self.errorView.frame.size.width,0);
    }
                     completion:^(BOOL flag){
                         
                         NSLog(@"Finished");
                     }];
}

-(void)StartActivityIndicator{
    
    self.view.userInteractionEnabled=NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.activity.hidden = NO;
}
-(void)StopActivityIndicator{
    
    self.view.userInteractionEnabled=YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.activity.hidden = YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
