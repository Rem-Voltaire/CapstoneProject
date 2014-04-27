//
//  ConsultationViewController.h
//  Law Firm App
//
//  Created by Owner on 4/10/14.
//
//

#import <UIKit/UIKit.h>
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"

@interface ConsultationViewController : UIViewController <SKPSMTPMessageDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *firstName;
@property (strong, nonatomic) IBOutlet UITextField *lastName;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumber;
@property (strong, nonatomic) IBOutlet UITextView *comments;
- (IBAction)sendConsultationButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIScrollView *scroller;

@end
