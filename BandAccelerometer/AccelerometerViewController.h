/*
 * BUHACKS Gene/Francis
 */


#import <UIKit/UIKit.h>
#import <MicrosoftBandKit_iOS/MicrosoftBandKit_iOS.h>

@interface AccelerometerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *txtOutput;
@property (weak, nonatomic) IBOutlet UILabel *accelLabel;
@property (weak, nonatomic) IBOutlet UIButton *startAccelerometerButton;

- (IBAction)didTapStartAccelerometerButton:(id)sender;

@end

