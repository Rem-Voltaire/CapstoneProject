//
//  AccidentInformationViewController.m
//  Law Firm App
//
//  Created by Owner on 4/18/14.
//
//

#import "AccidentInformationViewController.h"
#import "RespondingAgencyViewController.h"
#import "ClientInformationViewController.h"

@interface AccidentInformationViewController ()

@end

@implementation AccidentInformationViewController {
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
    if ([segue.identifier isEqualToString:@"segueToRespondingAgency"]) {

        RespondingAgencyViewController *newAgencyController = [segue destinationViewController];


        newAgencyController.backAccidentDate = _accidentDate.text;


        newAgencyController.backAccidentLocation = _accidentLocation.text;

        if (backOfficerName) {
            newAgencyController.backOfficerName = backOfficerName;
        }
        if (backAgencyName) {
            newAgencyController.backAgencyName = backAgencyName;
        }
        if (backUnitBadgeNumber) {
            newAgencyController.backUnitBadgeNumber = backUnitBadgeNumber;
        }
        if (backWitness1FirstName) {
            newAgencyController.backWitness1FirstName = backWitness1FirstName;
        }
        if (backWitness1LastName) {
            newAgencyController.backWitness1LastName = backWitness1LastName;
        }
        if (backWitness1PhoneNumber) {
            newAgencyController.backWitness1PhoneNumber = backWitness1PhoneNumber;
        }
        if (backWitness2FirstName) {
            newAgencyController.backWitness2FirstName = backWitness2FirstName;
        }
        if (backWitness2LastName) {
            newAgencyController.backWitness2LastName = backWitness2LastName;
        }
        if (backWitness2PhoneNumber) {
            newAgencyController.backWitness2PhoneNumber = backWitness2PhoneNumber;
        }
    }
    else if ([segue.identifier isEqualToString:@"segueToClientInformation"])
    {
        ClientInformationViewController *newClientController = [segue destinationViewController];

            newClientController.backAccidentDate = _accidentDate.text;

            newClientController.backAccidentLocation = _accidentLocation.text;

        if (backOfficerName) {
            newClientController.backOfficerName = backOfficerName;
        }
        if (backAgencyName) {
            newClientController.backAgencyName = backAgencyName;
        }
        if (backUnitBadgeNumber) {
            newClientController.backUnitBadgeNumber = backUnitBadgeNumber;
        }
        if (backWitness1FirstName) {
            newClientController.backWitness1FirstName = backWitness1FirstName;
        }
        if (backWitness1LastName) {
            newClientController.backWitness1LastName = backWitness1LastName;
        }
        if (backWitness1PhoneNumber) {
            newClientController.backWitness1PhoneNumber = backWitness1PhoneNumber;
        }
        if (backWitness2FirstName) {
            newClientController.backWitness2FirstName = backWitness2FirstName;
        }
        if (backWitness2LastName) {
            newClientController.backWitness2LastName = backWitness2LastName;
        }
        if (backWitness2PhoneNumber) {
            newClientController.backWitness2PhoneNumber = backWitness2PhoneNumber;
        }

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (backAccidentDate) {
        _accidentDate.text = backAccidentDate;
    }
    if (backAccidentLocation) {
        _accidentLocation.text = backAccidentLocation;
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return NO;
}

- (IBAction)accidentNextButton:(id)sender {
}
@end
