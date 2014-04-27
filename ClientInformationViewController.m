//
//  ClientInformationViewController.m
//  Law Firm App
//
//  Created by Owner on 4/18/14.
//
//

#import "ClientInformationViewController.h"
#import "AccidentInformationViewController.h"

@interface ClientInformationViewController ()

@end

@implementation ClientInformationViewController {
    UIAlertView *alert;
}

@synthesize backAccidentDate, backAccidentLocation, backOfficerName, backAgencyName, backUnitBadgeNumber, backWitness1FirstName, backWitness1LastName, backWitness1PhoneNumber, backWitness2FirstName, backWitness2LastName, backWitness2PhoneNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"segueToAccidentInformation"]) {
    AccidentInformationViewController *newAccidentController = [segue destinationViewController];

        if (backAccidentDate) {
            newAccidentController.backAccidentDate = backAccidentDate;
        }
        if (backAccidentLocation) {
            newAccidentController.backAccidentLocation = backAccidentLocation;
        }
        if (backOfficerName) {
            newAccidentController.backOfficerName = backOfficerName;
        }
        if (backAgencyName) {
            newAccidentController.backAgencyName = backAgencyName;
        }
        if (backUnitBadgeNumber) {
            newAccidentController.backUnitBadgeNumber = backUnitBadgeNumber;
        }
        if (backWitness1FirstName) {
            newAccidentController.backWitness1FirstName = backWitness1FirstName;
        }
        if (backWitness1LastName) {
            newAccidentController.backWitness1LastName = backWitness1LastName;
        }
        if (backWitness1PhoneNumber) {
            newAccidentController.backWitness1PhoneNumber = backWitness1PhoneNumber;
        }
        if (backWitness2FirstName) {
            newAccidentController.backWitness2FirstName = backWitness2FirstName;
        }
        if (backWitness2LastName) {
            newAccidentController.backWitness2LastName = backWitness2LastName;
        }
        if (backWitness2PhoneNumber) {
            newAccidentController.backWitness2PhoneNumber = backWitness2PhoneNumber;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextButton:(id)sender {

}

- (IBAction)backButton:(id)sender {

    alert = [[UIAlertView alloc] initWithTitle:@"Canceling Report..." message:@"Discard report?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    [alert show];
    
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        
    }
    else
    {
        [self performSegueWithIdentifier:@"segueToHome" sender:self];
    }
}
@end
