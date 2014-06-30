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
    NSArray *items;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /*autoreleaseの必要がないため、従来のcellがnilだった場合の例外を適用*/
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    /*
     if (cell == nil) {
     
     cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
     
     }*/
    
    // Configure the cell...
    //cell.textLabel.text = [[venues_ objectAtIndex:indexPath.row] objectForKey:@"name"];
    //cell.textLabel.text = [[[[venues_ objectAtIndex:indexPath.row] objectForKey:@"categories"] objectForKey:@"icon"] objectForKey:@"name"];
    //cell.textLabel.text = [[[venues_ objectAtIndex:indexPath.row] objectForKey:@"contact"] objectForKey:@"formattedPhone"];
    
    /* 配列の中の配列にアクセスするため、NSArrayに代入 */
    items = [[venues_ objectAtIndex:indexPath.row] objectForKey:@"categories"];
    
    //NSLog(@"items:\n%@",[items description]);
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = [[[[items objectAtIndex:0] objectForKey:@"name"] stringByAppendingString:@","] stringByAppendingString:[[venues_ objectAtIndex:indexPath.row]objectForKey:@"name"]];
    //NSLog(@"elements[0] = %@",[[items objectAtIndex:0] objectForKey:@"name"]);
    
    //NSLog(@"%f",[[[[venues_ objectAtIndex:indexPath.row] objectForKey:@"location"] objectForKey:@"lat"] doubleValue]);
    //NSLog(@"%f",[[[[venues_ objectAtIndex:indexPath.row] objectForKey:@"location"] objectForKey:@"lng"] doubleValue]);
    //NSLog(@"%@",[[[venues_ objectAtIndex:indexPath.row] objectForKey:@"categories"] objectForKey:@"id"]);
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
    
    // APIからベニューリストを取得
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&limit=30&client_id=ICIWPLPZATTTPYV0YBSVB4AQCF2PVXUWKHS3ZT1BURV0PS02&client_secret=T5SEMJSHYURT5UGERXLZNCUGI1QZ1JJHWBYN2XLDWK3FQUFN&v=20140627", latitude, longitude];
    //NSLog(@"urlString = %@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *response = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [response dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    
    
    NSDictionary *jsonDic = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                                        options:kNilOptions
                                          error:&error];
    
    if (!error) {
        // エラーコードをログに出力
        NSInteger errorCode = [[[jsonDic objectForKey:@"meta"] objectForKey:@"code"] integerValue];
        NSLog(@"errorCode = %ld", (long)errorCode);
        
        // 結果取得
        NSArray *venues = [[jsonDic objectForKey:@"response"] objectForKey:@"venues"];
        venues_ = [venues mutableCopy];
    }else{
        NSLog(@"Error: %@", [error localizedDescription]);
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
