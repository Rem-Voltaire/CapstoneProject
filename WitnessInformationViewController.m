//
//  WitnessInformationViewController.m
//  Law Firm App
//
//  Created by Owner on 4/18/14.
//
//

#import "WitnessInformationViewController.h"
#import "ReviewInformationViewController.h"
#import "RespondingAgencyViewController.h"

@interface WitnessInformationViewController ()

@end

@implementation WitnessInformationViewController {
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
    if ([segue.identifier isEqualToString:@"segueToReviewInformation"]) {

        ReviewInformationViewController *newReviewController = [segue destinationViewController];
        
        if (backAccidentDate) {
            newReviewController.backAccidentDate = backAccidentDate;
        }
        if (backAccidentLocation) {
            newReviewController.backAccidentLocation = backAccidentLocation;
        }
        if (backOfficerName) {
            newReviewController.backOfficerName = backOfficerName;
        }
        if (backAgencyName) {
            newReviewController.backAgencyName = backAgencyName;
        }
        if (backUnitBadgeNumber) {
            newReviewController.backUnitBadgeNumber = backUnitBadgeNumber;
        }

            newReviewController.backWitness1FirstName = _witness1FirstName.text;


            newReviewController.backWitness1LastName = _witness1LastName.text;

            newReviewController.backWitness1PhoneNumber = _witness1PhoneNumber.text;

            newReviewController.backWitness2FirstName = _witness2FirstName.text;

            newReviewController.backWitness2LastName = _witness2LastName.text;

            newReviewController.backWitness2PhoneNumber = _witness2PhoneNumber.text;


    }
    else if ([segue.identifier isEqualToString:@"segueToRespondingAgency"])
    {
        RespondingAgencyViewController *newAgencyController = [segue destinationViewController];
        
        if (backAccidentDate) {
            newAgencyController.backAccidentDate = backAccidentDate;
        }
        if (backAccidentLocation) {
            newAgencyController.backAccidentLocation = backAccidentLocation;
        }
        if (backOfficerName) {
            newAgencyController.backOfficerName = backOfficerName;
        }
        if (backAgencyName) {
            newAgencyController.backAgencyName = backAgencyName;
        }
        if (backUnitBadgeNumber) {
            newAgencyController.backUnitBadgeNumber = backUnitBadgeNumber;
        }

            newAgencyController.backWitness1FirstName = _witness1FirstName.text;

            newAgencyController.backWitness1LastName = _witness1LastName.text;

            newAgencyController.backWitness1PhoneNumber = _witness1PhoneNumber.text;

            newAgencyController.backWitness2FirstName = _witness2FirstName.text;

            newAgencyController.backWitness2LastName = _witness2LastName.text;

            newAgencyController.backWitness2PhoneNumber = _witness2PhoneNumber.text;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_scroller setScrollEnabled:YES];
    [_scroller setContentSize:CGSizeMake(320, 700)];
    if (backWitness1FirstName) {
        _witness1FirstName.text = backWitness1FirstName;
    }
    if (backWitness1LastName) {
        _witness1LastName.text = backWitness1LastName;
    }
    if (backWitness1PhoneNumber) {
        _witness1PhoneNumber.text = backWitness1PhoneNumber;
    }
    if (backWitness2FirstName) {
        _witness2FirstName.text = backWitness2FirstName;
    }
    if (backWitness2LastName) {
        _witness2LastName.text = backWitness2LastName;
    }
    if (backWitness2PhoneNumber) {
        _witness2PhoneNumber.text = backWitness2PhoneNumber;
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

- (IBAction)nextButton:(id)sender {
}
@end
