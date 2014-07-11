//
//  ViewController.h
//  spotlist
//
//  Created by cappuccinext on 2014/06/28.
//  Copyright (c) 2014年 cappmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ISRemoveNull.h"

@interface ViewController : UIViewController <UITableViewDataSource,CLLocationManagerDelegate,UIPickerViewDataSource, UIPickerViewDelegate>

{
    NSMutableArray      *venues_;
    NSMutableArray      *distance_;
    int                 limit;
    CLLocationManager	*locationManager_;
    NSArray *_pickerData;
    bool type;
}
@property (weak, nonatomic) IBOutlet UITableView *tv;

@property (weak, nonatomic) IBOutlet UIPickerView *pv;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sc;

- (IBAction)segChanged:(id)sender;

@end
