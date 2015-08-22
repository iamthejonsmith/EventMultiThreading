//
//  ViewController.m
//  EventMultiThreading
//
//  Created by Jon Smith on 8/13/15.
//  Copyright (c) 2015 Jon Smith. All rights reserved.
//

#define EVENT @"event"
#define TITLE @"title"
#define VENUE_NAME @"venue_name"
#define START_TIME @"start_time"
#define VENUE_URL @"venue_url"


#import "EventListViewController.h"
#import "EventDetailViewController.h"
#import "Event.h"

@interface EventListViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, NSXMLParserDelegate>

@property (strong, nonatomic) IBOutlet UITableView *eventTableView;
@property (strong, nonatomic) NSString *searchString;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) Event *currentEvent;
@property (strong, nonatomic) NSMutableString *eventString;
@property (nonatomic)BOOL insideItem;

@end

@implementation EventListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.eventTableView.dataSource = self;
    
    [self displayAlert];
}

-(void)hideHUD
{
    [_hud hide:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark = NSXML ParserDelegate Methods

-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    // Initialize our Array
    _events = [NSMutableArray array];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:EVENT])
    {
        _insideItem = YES;
        _currentEvent = [[Event alloc]init];
    }
    
    else if([elementName isEqualToString:TITLE])
    {
         _eventString = [[NSMutableString alloc]init];
        
    }
    
    else if([elementName isEqualToString:START_TIME])
    {
        _eventString = [[NSMutableString alloc]init];
    }
    
    else if([elementName isEqualToString:VENUE_NAME])
    {
        _eventString = [[NSMutableString alloc]init];
    }
    
    else if([elementName isEqualToString:VENUE_URL])
    {
        _eventString = [[NSMutableString alloc]init];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(_eventString != nil)
    {
        [_eventString appendString:string];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    if([elementName isEqualToString:TITLE])
    {
        _currentEvent.title = _eventString;
    }
   
    else if([elementName isEqualToString:START_TIME])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        _currentEvent.startTime = [formatter dateFromString:_eventString];
    }
    
    else if([elementName isEqualToString:VENUE_NAME])
    {
        _currentEvent.venueName = _eventString;
    }
    
    else if([elementName isEqualToString:VENUE_URL])
    {
        _currentEvent.venueURL= _eventString;
    }
    
    else if([elementName isEqualToString:EVENT])
    {
        _insideItem = NO;
        [_events addObject:_currentEvent];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self.eventTableView reloadData];
    [self hideHUD];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Document was not parsed successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_events count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"EventCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    Event *event = _events[indexPath.row];
    
    cell.textLabel.text = event.venueName;
    cell.detailTextLabel.text = event.title;
    
    return cell;
}


-(void)loadRequest
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"http://api.eventful.com/rest/events/search?app_key=9JKSQMHbJxvZTDWB&location=%@&category=music&date=future&page_size=50", _searchString]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
        // Send a synchronous request. This url request will block the main thread and create an instance of NSData to assign to the variable, eventData.
    NSData *eventData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
 
    dispatch_async(dispatch_get_main_queue(), ^{
        NSXMLParser *parser = [[NSXMLParser alloc]initWithData:eventData];
        parser.delegate = self;
        [parser parse];
    });
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *alertField = [alertView textFieldAtIndex:0];
    
    _searchString =[alertField.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    [self loadingOverlay];
    
    // Create a background thread to download event data
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(globalQueue, ^{
        [self loadRequest];
    });

}

-(void)loadingOverlay
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = @"Loading Events";
}

-(void)displayAlert
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Enter a location" message:@"Please enter a location to search for events" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (IBAction)clickToAlert:(id)sender
{
    [self displayAlert];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.destinationViewController isKindOfClass:[EventDetailViewController class]])
    {
        EventDetailViewController *edvc = (EventDetailViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.eventTableView indexPathForSelectedRow];
        Event *selectedEvent = _events[indexPath.row];
        edvc.passedEvent = selectedEvent;
        edvc.passedString = _currentEvent.venueURL;
    }
}


@end
