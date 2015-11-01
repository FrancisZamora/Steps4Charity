/*
 * BUHACKS Gene/Francis
 */

#import "AccelerometerViewController.h"

@interface AccelerometerViewController ()<MSBClientManagerDelegate, UITextViewDelegate>
@property (nonatomic, weak) MSBClient *client;
@end

@implementation AccelerometerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Setup View
    [self markSampleReady:NO];
    self.txtOutput.delegate = self;
    UIEdgeInsets insets = [self.txtOutput textContainerInset];
    insets.top = 20;
    insets.bottom = 20;
    [self.txtOutput setTextContainerInset:insets];
    
    // Setup Band
    [MSBClientManager sharedManager].delegate = self;
    NSArray	*clients = [[MSBClientManager sharedManager] attachedClients];
    self.client = [clients firstObject];
    if (self.client == nil)
    {
        [self output:@"Failed! No Bands attached."];
        return;
    }
    
    [[MSBClientManager sharedManager] connectClient:self.client];
    [self output:[NSString stringWithFormat:@"Please wait. Connecting to Band <%@>", self.client.name]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didTapStartAccelerometerButton:(id)sender
{
    [self markSampleReady:NO];
    [self output:@"Starting Accelerometer updates..."];
    __weak typeof(self) weakSelf = self;
    void (^handler)(MSBSensorPedometerData *, NSError *) = ^(MSBSensorPedometerData *pedometerData, NSError *error)
    {
        weakSelf.accelLabel.text = [NSString stringWithFormat:@"Total Steps: %u",
                                    pedometerData.totalSteps
                                    
                                     ];
    };
    
    NSError *stateError;
    if (![self.client.sensorManager startPedometerUpdatesToQueue:nil errorRef:&stateError withHandler:handler])
    {
        [self sampleDidCompleteWithOutput:stateError.description];
        return;
    }
    
    //Stop Accel updates after 12 hours
    [self performSelector:@selector(stopAccelUpdates) withObject:0 afterDelay:43200];
    
    
    
    
         NSURL *url = [NSURL URLWithString:@"http://steps4charity.azurewebsites.net/chargeme"];
         NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data, NSError *connectionError)
         {
             if (data.length > 0 && connectionError == nil)
             {
                 NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:0
                                                                            error:NULL];
                 self.accelLabel.text = [[greeting objectForKey:@"id"] stringValue];
                 self.accelLabel.text = [greeting objectForKey:@"content"];
             }
         }];
    

    
    
    
    
}

- (void)stopAccelUpdates
{
    [self.client.sensorManager stopAccelerometerUpdatesErrorRef:nil];
    [self sampleDidCompleteWithOutput:@"Accelerometer updates stopped..."];
}

#pragma mark - Helper methods

- (void)sampleDidCompleteWithOutput:(NSString *)output
{
    [self output:output];
    [self markSampleReady:YES];
}

- (void)markSampleReady:(BOOL)ready
{
    self.startAccelerometerButton.enabled = ready;
    self.startAccelerometerButton.alpha = ready ? 1.0 : 0.2;
}

- (void)output:(NSString *)message
{
    if (message)
    {
        self.txtOutput.text = [NSString stringWithFormat:@"%@\n%@", self.txtOutput.text, message];
        [self.txtOutput layoutIfNeeded];
        if (self.txtOutput.text.length > 0)
        {
            [self.txtOutput scrollRangeToVisible:NSMakeRange(self.txtOutput.text.length - 1, 1)];
        }
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

#pragma mark - MSBClientManagerDelegate

- (void)clientManager:(MSBClientManager *)clientManager clientDidConnect:(MSBClient *)client
{
    [self markSampleReady:YES];
    [self output:[NSString stringWithFormat:@"Band <%@> connected.", client.name]];
}

- (void)clientManager:(MSBClientManager *)clientManager clientDidDisconnect:(MSBClient *)client
{
    [self markSampleReady:NO];
    [self output:[NSString stringWithFormat:@"Band <%@> disconnected.", client.name]];
}

- (void)clientManager:(MSBClientManager *)clientManager client:(MSBClient *)client didFailToConnectWithError:(NSError *)error
{
    [self output:[NSString stringWithFormat:@"Failed to connect to Band <%@>.", client.name]];
    [self output:error.description];
}

@end
