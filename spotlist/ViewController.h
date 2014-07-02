//
//  ViewController.h
//  spotlist
//
//  Created by cappuccinext on 2014/06/28.
//  Copyright (c) 2014年 cappmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <UITableViewDataSource,CLLocationManagerDelegate,UIPickerViewDataSource, UIPickerViewDelegate>

{
    NSMutableArray      *venues_;
    CLLocationManager	*locationManager_;
    NSTimer             *timer;
    NSArray *_pickerData;
}
@property (weak, nonatomic) IBOutlet UITableView *tv;

@property (weak, nonatomic) IBOutlet UIPickerView *pv;


@end
