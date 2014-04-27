//
//  ReviewInformationViewController.m
//  Law Firm App
//
//  Created by Owner on 4/20/14.
//
//

#import "ReviewInformationViewController.h"
#import "WitnessInformationViewController.h"

@interface ReviewInformationViewController ()
-(void)sendAMail;
-(void)checkEmail;
@end

@implementation ReviewInformationViewController{
    NSString *userEmailAddress;
    UITextField *alertTextField;
    UIAlertView *emailAlert;
    UIAlertView *emailValidate;
}

@synthesize backAccidentDate, backAccidentLocation, backAgencyName, backOfficerName, backUnitBadgeNumber, backWitness1FirstName, backWitness1LastName, backWitness1PhoneNumber, backWitness2FirstName, backWitness2LastName, backWitness2PhoneNumber;

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
        
        if (backOfficerName) {
            
            newWitnessController.backOfficerName = backOfficerName;
            
        }
        
        if (backAgencyName) {
            
            newWitnessController.backAgencyName = backAgencyName;
            
        }
        
        if (backUnitBadgeNumber) {
            
            newWitnessController.backUnitBadgeNumber = backUnitBadgeNumber;
            
        }
        
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *witness1Name = [NSString stringWithFormat:@"%@ %@", backWitness1FirstName, backWitness1LastName];
    
    NSString *witness2Name = [NSString stringWithFormat:@"%@ %@", backWitness2FirstName, backWitness2LastName];
    
    _accidentDate.text = backAccidentDate;
    _accidentLocation.text = backAccidentLocation;
    _officerName.text = backOfficerName;
    _agencyName.text = backAgencyName;
    _unitBadgeNumber.text = backUnitBadgeNumber;
    _witness1Name.text = witness1Name;
    _witness1Phone.text = backWitness1PhoneNumber;
    _witness2Name.text = witness2Name;
    _witness2Phone.text = backWitness2PhoneNumber;
    
    
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendAccidentNotes:(id)sender {
    
    
    emailAlert = [[UIAlertView alloc] initWithTitle:@"Send Accident Notes" message:@"Enter your email address:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    emailAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [emailAlert setTag:1];
    alertTextField = [emailAlert textFieldAtIndex:0];
    alertTextField.placeholder = @"Enter your email";
    [emailAlert show];
    //[emailAlert release];
}

-(BOOL)validateEmail:(NSString *)emailStr {
    NSString * emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

-(void)checkEmail {
    
    if(![self validateEmail:[[emailAlert textFieldAtIndex:0] text]] || [alertTextField.text length] <= 0)
    {
        emailValidate = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a valid email address" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Try Again", nil];
        [emailValidate setTag:2];
        [emailValidate show];
    }
    else if([self validateEmail:[[emailAlert textFieldAtIndex:0] text]])
    {
        userEmailAddress = alertTextField.text;
        [self sendAMail];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView.tag == 1)
    {
        if (buttonIndex == 1) {
            [self checkEmail];
        }
    }
//    else if([alertTextField.text length] <= 0)
//    {
//        return;
//    }
    else
    {
        [self sendAccidentNotes:self];
    }
}




-(void)sendAMail{

    NSLog(@"Start Sending");
    
    
    
    SKPSMTPMessage *emailMessage = [[SKPSMTPMessage alloc] init];
    
    
    
    emailMessage.fromEmail = userEmailAddress; //sender email address
    
    
    
    emailMessage.toEmail = userEmailAddress;  //receiver email address
    
    
    
    emailMessage.relayHost = @"smtp.gmail.com";
    
    
    
    emailMessage.ccEmail =@"silverfreezez@gmail.com";
    
    
    
    //emailMessage.bccEmail =clientEmail;
    
    
    
    emailMessage.requiresAuth = YES;
    
    
    
    emailMessage.login = @"wbrelayhost@gmail.com";//sender email address
    
    
    
    emailMessage.pass = @"wardandbarnesftw"; //sender email password
    
    
    
    emailMessage.subject =@"Auto Accident Report";
    
    
    
    emailMessage.wantsSecure = YES;
    
    
    
    emailMessage.delegate = self; // you must include <SKPSMTPMessageDelegate> to your class
    
    
    
    //NSString *messageBody = _MessageTextView.text;
    
    
    
    NSString *messageBody = [NSString stringWithFormat:@"Accident Information\nAccident Date(MMDDYY): %@\nAccident Location: %@\n\n Responding Agency Information\nOfficer Name: %@\nAgency Name: %@\nUnit/Badge Number: %@\n\nWitness Information\nWitness 1 Name: %@ %@\nWitness 1 Contact No.: %@\nWitness 2 Name: %@ %@\nWitness 2 Contact No.: %@",backAccidentDate, backAccidentLocation,backOfficerName,backAgencyName,backUnitBadgeNumber, backWitness1FirstName, backWitness1LastName, backWitness1PhoneNumber, backWitness2FirstName, backWitness2LastName, backWitness2PhoneNumber];
     
     
     
     // Now creating plain text email message
     
     
     
     NSDictionary *plainMsg = [NSDictionary
     
     
     
     dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
     
     
     
     messageBody,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
     
     
     
     emailMessage.parts = [NSArray arrayWithObjects:plainMsg,nil];
    
    
    
    //in addition : Logic for attaching file with email message.
    
    
    
    /*
     
     
     
     NSString *filePath = [[NSBundle mainBundle] pathForResource:@"filename" ofType:@"JPG"];
     
     
     
     NSData *fileData = [NSData dataWithContentsOfFile:filePath];
     
     
     
     NSDictionary *fileMsg = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-
     
     
     
     unix-mode=0644;\r\n\tname=\"filename.JPG\"",kSKPSMTPPartContentTypeKey,@"attachment;\r\n\tfilename=\"filename.JPG\"",kSKPSMTPPartContentDispositionKey,[fileData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
     
     
     
     emailMessage.parts = [NSArray arrayWithObjects:plainMsg,fileMsg,nil]; //including plain msg and attached file msg
     
     
     
     */
    
    
    
    [emailMessage send];
    
    
    
    // sending email- will take little time to send so its better to use indicator with message showing sending...
}

//Now, handling delegate methods :

// On success



-(void)messageSent:(SKPSMTPMessage *)message{
    
    NSLog(@"delegate - message sent");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message sent." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [alert show];
    
}



// On Failure

-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error{
    
    // open an alert with just an OK button
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [alert show];
    
    NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
    
}

@end
