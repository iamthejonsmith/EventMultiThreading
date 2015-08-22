//
//  EventDetailViewController.m
//  EventMultiThreading
//
//  Created by Jon Smith on 8/13/15.
//  Copyright (c) 2015 Jon Smith. All rights reserved.
//

#import "EventDetailViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface EventDetailViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) MBProgressHUD *hud;

@end

@implementation EventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _passedEvent.venueName;
    _webView.delegate = self;
    [self loadEventList];
    [self loadingOverlay];
}

-(void)loadEventList
{
    if(_passedEvent == nil)
    {
        return;
    }
    NSString *urlString = _passedString;  //is your str
    
    NSArray *urlItems = [urlString componentsSeparatedByString:@"?"];
    
    NSString *eventPath =[urlItems objectAtIndex:0];
    
    //create a URL object
    NSURL *url = [NSURL URLWithString:eventPath];
    
    //create a url request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    dispatch_queue_t detailQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(detailQueue, ^{
        
        //load the request in webview
        [_webView loadRequest:request];
        
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadingOverlay
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = @"Loading Events";
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud hide:YES];
    });
}

@end

