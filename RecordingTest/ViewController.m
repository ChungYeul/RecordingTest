//
//  ViewController.m
//  RecordingTest
//
//  Created by SDT-1 on 2014. 1. 16..
//  Copyright (c) 2014년 T. All rights reserved.
//

#import "ViewController.h"
#define CELL_ID @"CELL_ID"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btn;

@end

@implementation ViewController {
    AVAudioRecorder *_recorder;
    NSMutableArray *_recordingFiles;
}
//
- (NSString *)getPullPath:(NSString *)fileName {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentPath stringByAppendingPathComponent:fileName];
}

//
- (void)startRecording {
    NSDate *date = [NSDate date];
    NSString *filePath = [self getPullPath:[NSString stringWithFormat:@"%@.caf", [date description]]];
    NSLog(@"recording path : %@", filePath);
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    [setting setValue:[NSNumber numberWithFloat:44100.0f] forKey:AVSampleRateKey];
    [setting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    __autoreleasing NSError *error;
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
    _recorder.delegate = self;
    if ([_recorder prepareToRecord]) {
        self.status.text = [NSString stringWithFormat:@"Recording : %@", [[url path] lastPathComponent]];
        
        [_recorder recordForDuration:10];
    }
}

- (void)updateRecordedFiles {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    __autoreleasing NSError *error = nil;
    
    _recordingFiles = [[NSMutableArray alloc] initWithArray:[fm contentsOfDirectoryAtPath:documentPath error:&error]];
    [self.table reloadData];
}

- (void)stopRecording {
    [_recorder stop];
    [self updateRecordedFiles];
}

- (IBAction)toggleRecording:(id)sender {
    if ([_recorder isRecording]) {
        [self stopRecording];
        ((UIBarButtonItem *)sender).title = @"Record";
    }
    else {
        [self startRecording];
        ((UIBarButtonItem *)sender).title = @"Stop";
    }
}

// AVAudioRecorder Delegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    self.status.text = @"녹음 완료";
    self.btn.title = @"Record";
    [self updateRecordedFiles];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    self.status.text = [NSString stringWithFormat:@"녹음 중 오류 : %@", [error description]];
}

// TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_recordingFiles count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    cell.textLabel.text = [_recordingFiles objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fileName = [_recordingFiles objectAtIndex:indexPath.row];
    NSString *fullPath = [self getPullPath:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    __autoreleasing NSError *error = nil;
    BOOL ret = [fm removeItemAtPath:fullPath error:&error];
    if (NO == ret) {
        NSLog(@"Error : %@", [error localizedDescription]);
    }
    
    [_recordingFiles removeObjectAtIndex:indexPath.row];
    [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateRecordedFiles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
