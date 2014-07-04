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

@synthesize sc;

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
    locationManager_.distanceFilter = 25.0f;//25m移動するごとに測位値を返却する
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    type = 0;
    
    NSArray *responseJSON = [venues_ valueForKeyPath:@"categories.name"];
    //NSLog(@"%@",responseJSON);
    
    NSArray *array = @[];
    
    //nsdictionaryを複数作る
    //nsarrayでまとめる。
    
    /*NSArrayが要素となっているNSArrayを分解してNSStringを抽出し、新しいNSArrayを生成*/
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
    
    
    NSArray *dataArray = [NSArray array];
    
    //dictinaryWithOptionsAndKeys
    for (int i = 0; i < limit ; i++) {
        NSDictionary *mdic = [NSDictionary dictionaryWithObjectsAndKeys:[array objectAtIndex:i]
                              ,@"GENRE"
                              ,[[venues_ objectAtIndex:i]objectForKey:@"name"]
                              ,@"SPOT"
                              ,[[venues_ objectAtIndex:i]objectForKey:@"id"]
                              ,@"ID"
                              ,[distance_ objectAtIndex:i]
                              ,@"DISTANCE"
                              , nil];
        dataArray = [dataArray arrayByAddingObject:mdic];
    }
    
    
    NSSortDescriptor *descriptor1=[[NSSortDescriptor alloc] initWithKey:@"GENRE" ascending:YES];
    
    NSSortDescriptor *descriptor2=[[NSSortDescriptor alloc] initWithKey:@"DISTANCE.intValue" ascending:YES];
    
    
    //NSArray *sortedArr = [dataArray sortedArrayUsingDescriptors:@[descriptor1]];
    NSArray *sortedArr = [dataArray sortedArrayUsingDescriptors:@[descriptor2]];
    
    
    //NSLog(@"%@",[sortedArr description]);
    
    /* 辞書を勉強しようとした残骸（そのうち消す）
    NSArray *keyDic = @[@"genre",@"name",@"id"];
    NSArray *vals = @[[array objectAtIndex:0],[[venues_ objectAtIndex:0] objectForKey:@"name"],[[venues_ objectAtIndex:0] objectForKey:@"id"]];
    NSArray *vals2 = @[[array objectAtIndex:0],[[venues_ objectAtIndex:1] objectForKey:@"name"],[[venues_ objectAtIndex:1] objectForKey:@"id"]];NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    [mdic setObject:vals forKey:keyDic];
    [mdic setObject:vals2 forKey:keyDic];
    
    NSLog(@"%@",[mdic description]);*/
    
    /*リスト表示の基本コード（バグったらここを戻すこと）
    cell.textLabel.text = [[[array objectAtIndex:indexPath.row] stringByAppendingString:@" / "] stringByAppendingString:[[venues_ objectAtIndex:indexPath.row]objectForKey:@"name"]];
     */
    
    NSString *cellVal = [[sortedArr objectAtIndex:indexPath.row] objectForKey:@"DISTANCE"];
    
    cell.textLabel.text = [[[[[sortedArr objectAtIndex:indexPath.row]objectForKey:@"SPOT"] stringByAppendingString:@" - "] stringByAppendingString:[NSString stringWithFormat:@"%@",cellVal]] stringByAppendingString:@"m"];
    
    cell.detailTextLabel.text = [[sortedArr objectAtIndex:indexPath.row]objectForKey:@"GENRE"];
    /*
    NSMutableArray *sortedDist = [[sortedArr objectAtIndex:indexPath.row] objectForKey:@"DISTANCE"];
    NSLog(@"%@",[sortedDist description]);
    
    NSString *cellVal = [[sortedArr objectAtIndex:indexPath.row] objectForKey:@"DISTANCE"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",cellVal];
    */
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
    limit = 30;
    
    CLLocation *Apoint = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    //CLLocationDistance distance = [Apoint distanceFromLocation:Bpoint];
    
    // APIからベニューリストを取得
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&limit=%d&client_id=ICIWPLPZATTTPYV0YBSVB4AQCF2PVXUWKHS3ZT1BURV0PS02&client_secret=T5SEMJSHYURT5UGERXLZNCUGI1QZ1JJHWBYN2XLDWK3FQUFN&v=20140627", latitude, longitude,limit];
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
        //NSLog(@"%@,%@",[responseLAT description],[responseLNG description]);
        
        NSArray *Bpoint = @[];
        //距離をコンソールに表示する
        for (int i = 0;i<limit;i++)
        {
            CLLocation *B = [[CLLocation alloc] initWithLatitude:[[responseLAT objectAtIndex:i] doubleValue] longitude:[[responseLNG objectAtIndex:i] doubleValue]];
            Bpoint = [Bpoint arrayByAddingObject:[NSNumber numberWithFloat:[Apoint distanceFromLocation:B]]];
            
        }
        //NSLog(@"distance = %@",[Bpoint description]);
        
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
                distance_ = [Bpoint mutableCopy];
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

- (IBAction)segChanged:(id)sender {
    switch (sc.selectedSegmentIndex) {
        case 0:
            type = 0;
            break;
            
        case 1:
            type = 1;
            break;
            
        default:
            break;
    }
}
@end
