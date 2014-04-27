//
//  RespondingAgencyViewController.h
//  Law Firm App
//
//  Created by Owner on 4/20/14.
//
//

#import <UIKit/UIKit.h>

@interface RespondingAgencyViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *officerName;
@property (weak, nonatomic) IBOutlet UITextField *agencyName;
@property (weak, nonatomic) IBOutlet UITextField *unitBadgeNumber;

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
