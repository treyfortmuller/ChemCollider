//
//  HelpController.m
//  BrickBreaker


#import "HelpController.h"

@implementation HelpController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"4back.png"]];
}

- (IBAction)buttonPressForRxnMech:(id)sender {
    NSString* messageString = [NSString stringWithFormat: @"N2O4 + CO → N2O3 + CO2\nN2O3 + CO → N2O2 + CO2\nN2O2 + CO → N2O + CO2"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reaction Mechanism" message:messageString delegate:self cancelButtonTitle:nil otherButtonTitles: @"OK", nil];
    alert.tag = 4;
    [alert show];
    [alert autorelease];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

@end
