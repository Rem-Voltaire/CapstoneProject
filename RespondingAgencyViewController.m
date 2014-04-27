//
//  RespondingAgencyViewController.m
//  Law Firm App
//
//  Created by Owner on 4/20/14.
//
//

#import "RespondingAgencyViewController.h"
#import "AccidentInformationViewController.h"
#import "WitnessInformationViewController.h"

@interface RespondingAgencyViewController ()

@end

@implementation RespondingAgencyViewController

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
    if ([segue.identifier isEqualToString:@"segueToWitnessInformation"]) {
        
        WitnessInformationViewController *newWitnessController = [segue destinationViewController];
        
        if (backAccidentDate) {
            newWitnessController.backAccidentDate = backAccidentDate;
        }
        if (backAccidentLocation) {
            newWitnessController.backAccidentLocation = backAccidentLocation;
        }
            newWitnessController.backOfficerName = _officerName.text;

            newWitnessController.backAgencyName = _agencyName.text;

            newWitnessController.backUnitBadgeNumber = _unitBadgeNumber.text;

        if (backWitness1FirstName) {
            newWitnessController.backWitness1FirstName = backWitness1FirstName;
        }
        if (backWitness1LastName) {
            newWitnessController.backWitness1LastName = backWitness1LastName;
        }
        if (backWitness1PhoneNumber) {
            newWitnessController.backWitness1PhoneNumber = backWitness1PhoneNumber;
        }
        if (backWitness2FirstName) {
            newWitnessController.backWitness2FirstName = backWitness2FirstName;
        }
        if (backWitness2LastName) {
            newWitnessController.backWitness2LastName = backWitness2LastName;
        }
        if (backWitness2PhoneNumber) {
            newWitnessController.backWitness2PhoneNumber = backWitness2PhoneNumber;
        }
    }
    else if ([segue.identifier isEqualToString:@"segueToAccidentInformation"])
    {
        AccidentInformationViewController *newAccidentController = [segue destinationViewController];
        if (backAccidentDate) {
            newAccidentController.backAccidentDate = backAccidentDate;
        }
        if (backAccidentLocation) {
            newAccidentController.backAccidentLocation = backAccidentLocation;
        }

            newAccidentController.backOfficerName = _officerName.text;

            newAccidentController.backAgencyName = _agencyName.text;

            newAccidentController.backUnitBadgeNumber = _unitBadgeNumber.text;

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
    if (backOfficerName) {
        _officerName.text = backOfficerName;
    }
    if (backAgencyName) {
        _agencyName.text = backAgencyName;
    }
    if (backUnitBadgeNumber) {
        _unitBadgeNumber.text = backUnitBadgeNumber;
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

@end
