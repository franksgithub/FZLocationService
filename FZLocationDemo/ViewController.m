//
//  ViewController.m
//  FZLocationDemo
//
//  Created by Frank on 16/6/30.
//  Copyright © 2016年 Frank. All rights reserved.
//

#import "ViewController.h"
#import "FZLocationService.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)showCurrentLocation:(id)sender {
    [FZLocationService locationWithCompleteBlock:^(CLLocation *location, NSError *error) {
        if (error) {
            _tipLabel.text = [NSString stringWithFormat:@"error : %@", error.localizedDescription];
        } else {
            _tipLabel.text = [NSString stringWithFormat:@"longitude : %f\nlatitude : %f", location.coordinate.longitude, location.coordinate.latitude];
        }
    }];
}

@end
