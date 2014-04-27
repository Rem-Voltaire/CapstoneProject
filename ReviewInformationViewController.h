//
//  ReviewInformationViewController.h
//  Law Firm App
//
//  Created by Owner on 4/20/14.
//
//

#import <UIKit/UIKit.h>
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"

@interface ReviewInformationViewController : UIViewController <SKPSMTPMessageDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *accidentDate;
@property (weak, nonatomic) IBOutlet UILabel *accidentLocation;
@property (weak, nonatomic) IBOutlet UILabel *officerName;
@property (weak, nonatomic) IBOutlet UILabel *agencyName;
@property (weak, nonatomic) IBOutlet UILabel *unitBadgeNumber;
@property (weak, nonatomic) IBOutlet UILabel *witness1Name;
@property (weak, nonatomic) IBOutlet UILabel *witness1Phone;
@property (weak, nonatomic) IBOutlet UILabel *witness2Name;
@property (weak, nonatomic) IBOutlet UILabel *witness2Phone;
- (IBAction)sendAccidentNotes:(id)sender;
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
