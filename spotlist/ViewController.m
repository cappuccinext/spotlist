//
//  ViewController.m
//  spotlist
//
//  Created by cappuccinext on 2014/06/28.
//  Copyright (c) 2014年 cappmac. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.tv.dataSource = self;
    
    _pickerData = @[@"施設名称", @"ID", @"電話番号", @"緯度", @"経度", @"郵便番号",@"URL",@"ジャンル"];
    
    self.pv.delegate = self;
    self.pv.dataSource = self;
    
    
    // 現在地取得開始
    locationManager_ = [[CLLocationManager alloc] init];
    [locationManager_ setDelegate:self];
    locationManager_.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager_.distanceFilter = 100.0f;//100m移動するごとに測位値を返却する
    [locationManager_ startUpdatingLocation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [venues_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /*autoreleaseの必要がないため、従来のcellがnilだった場合の例外を適用*/
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSArray *responseJSON = [venues_ valueForKeyPath:@"categories.name"];
    //NSLog(@"%@",responseJSON);
    
    NSArray *array = @[];
    
    /*NSArrayが要素となっているNSArrayを分解して、新しいNSArrayを生成*/
    for (NSArray *data in responseJSON) {
        if ([data count] == 0) {
            array = [array arrayByAddingObject:@"NODATA"];
            //NSLog(@"NODATA");
        }else{
            array = [array arrayByAddingObject:[data objectAtIndex:0]];
            //NSLog(@"name = %@",[data objectAtIndex:0]);
        }
        
    }
    //検証用のNSLog
    //NSLog(@"array = %@", array);
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.textLabel.text = [[[array objectAtIndex:indexPath.row] stringByAppendingString:@" / "] stringByAppendingString:[[venues_ objectAtIndex:indexPath.row]objectForKey:@"name"]];
    
    

    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManager delegate

// GPSの位置情報が更新されたら呼ばれる
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSError *error;
    // 緯度・経度取得
    CLLocationDegrees latitude = newLocation.coordinate.latitude;
    CLLocationDegrees longitude = newLocation.coordinate.longitude;
    
    CLLocation *Apoint = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    //CLLocationDistance distance = [Apoint distanceFromLocation:Bpoint];
    
    // APIからベニューリストを取得
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&limit=10&client_id=ICIWPLPZATTTPYV0YBSVB4AQCF2PVXUWKHS3ZT1BURV0PS02&client_secret=T5SEMJSHYURT5UGERXLZNCUGI1QZ1JJHWBYN2XLDWK3FQUFN&v=20140627", latitude, longitude];
    //NSLog(@"urlString = %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    
    if (jsonData == nil) {
        NSLog(@"ERROR!");
    }else{
        NSDictionary *jsonDic = [NSJSONSerialization
                                 JSONObjectWithData:jsonData
                                 options:kNilOptions
                                 error:&error];
        
        NSArray *responseLAT = [jsonDic valueForKeyPath:@"response.venues.location.lat"];
        NSArray *responseLNG = [jsonDic valueForKeyPath:@"response.venues.location.lng"];
        NSLog(@"%@,%@",[responseLAT description],[responseLNG description]);
        
        NSArray *Bpoint = @[];
        //距離をコンソールに表示する
        for (int i = 0;i<10;i++)
        {
            CLLocation *B = [[CLLocation alloc] initWithLatitude:[[responseLAT objectAtIndex:i] doubleValue] longitude:[[responseLNG objectAtIndex:i] doubleValue]];
            NSLog(@"distance = %f",[Apoint distanceFromLocation:B]);
        }
        
        if (!error) {
            // エラーコードをログに出力
            if ([jsonDic count] == 0) {
                NSLog(@"don't access it as the index is out of bounds");
                return;
            }else{
                NSInteger errorCode = [[[jsonDic objectForKey:@"meta"] objectForKey:@"code"] integerValue];
                NSLog(@"errorCode = %ld", (long)errorCode);
                
                // 結果取得
                NSArray *venues = [[jsonDic objectForKey:@"response"] objectForKey:@"venues"];
                venues_ = [venues mutableCopy];
            }
        }else{
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        

    }
    
    [self.tv reloadData];
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (int)_pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

@end
