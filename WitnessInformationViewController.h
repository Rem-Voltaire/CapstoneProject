//
//  WitnessInformationViewController.h
//  Law Firm App
//
//  Created by Owner on 4/18/14.
//
//

#import <UIKit/UIKit.h>

@interface WitnessInformationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *witness1FirstName;
@property (weak, nonatomic) IBOutlet UITextField *witness1LastName;
@property (weak, nonatomic) IBOutlet UITextField *witness1PhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *witness2FirstName;
@property (weak, nonatomic) IBOutlet UITextField *witness2LastName;
@property (weak, nonatomic) IBOutlet UITextField *witness2PhoneNumber;

- (IBAction)nextButton:(id)sender;

@property (strong, nonatomic) NSString *backAccidentDate;
@property (strong, nonatomic) NSString *backAccidentLocation;
@property (strong, nonatomic) NSString *backOfficerName;
@property (strong, nonatomic) NSString *backAgencyName;
@property (strong, nonatomic) NSString *backUnitBadgeNumber;
@property (strong, nonatomic) NSString *backWitness1FirstName;
@property (strong, nonatomic) NSString *backWitness1LastName;
@property (strong, nonatomic) NSString *backWitness1PhoneNumber;
@property (strong, nonatomic) NSString *backWitness2FirstName;
@property (strong, nonatomic) NSString *backWitness2LastName;
@property (strong, nonatomic) NSString *backWitness2PhoneNumber;

@end
