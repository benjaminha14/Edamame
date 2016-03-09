

/* Set this to YES to reproduce the playback issue */
#define IMPEDE_PLAYBACK NO

#import "ViewController.h"
#import <AVFoundation/AVAudioSession.h>
#include <sys/types.h>
#include <sys/sysctl.h>
@interface ViewController ()<CLLocationManagerDelegate>{
    int avg;
    int highDeci;
    float decibel;
    int count;
    double average;
    double actualDecibel;
    int smallestDecibel;
    //  AVAudioSession *session;
    NSTimer *averageTimer;
    NSTimer *lowTimer;
    NSTimer *highTimer;
    NSTimer *labelTimer;
    NSTimer *uploadTimer;
     CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    NSString *response;
    int hertz;
    BOOL isRunningLoop;
    NSTimer *timeLoop;
    NSTimer *measureDecibel;
   
    NSMutableArray *recordedDecibalOutput;
    NSString *hertzString;
    
}

@property (nonatomic)     AVAudioPlayer       *player;
@property (nonatomic)     AVAudioRecorder     *recorder;
@property (nonatomic)     NSString            *recordedAudioFileName;
@property (nonatomic)     NSURL               *recordedAudioURL;
@property(nonatomic, strong) AVAudioPlayer *backgroundMusic;




@end

@implementation ViewController

@synthesize player, recorder, recordedAudioFileName, recordedAudioURL;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    hertz = 100;
    recordedDecibalOutput = [NSMutableArray array];
    NSURL *musicFile = [[NSBundle mainBundle] URLForResource:@"music"
                                               withExtension:@"mp3"];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    /*
        [audioSession setCategory:AVAudioSessionCategoryPlayback
                      withOptions:AVAudioSessionCategoryOptionMixWithOthers
                            error:&setCategoryError];
        [audioSession setActive:YES error:nil];
    
        NSError *err = nil;
    
        [session setCategory:AVAudioSessionCategoryPlayAndRecord  withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
        [session setActive:YES error:&err];
    */
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile
                                                                  error:nil];
    self.backgroundMusic.numberOfLoops = -1;
    
    smallestDecibel = 100;
    isRunningLoop = YES;
    

    

    
    
   
}


#pragma mark Playback


#pragma mark Recording

-(int)averageDecibel{
    [recorder updateMeters];
   return[recorder averagePowerForChannel:0];
}
-(float)actualDecibal{
    [recorder updateMeters];
    return[recorder averagePowerForChannel:0];
}

- (IBAction)record:(id)sender {
    [self setupAndPrepareToRecord];
    [recorder record];
    
   // [self.backgroundMusic play];
    
    averageTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(runningAverage)
                                           userInfo:nil
                                            repeats:YES];
    highTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(highestDecible)
                                   userInfo:nil
                                    repeats:YES];
    lowTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(lowestDecible)
                                   userInfo:nil
                                    repeats:YES];
    labelTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(labelText)
                                   userInfo:nil
                                    repeats:YES];
    
    
    
    
    
    
    
}



/*
 Button that play 300 hz
 */
- (IBAction)play300Hz:(id)sender {
    
    NSURL *musicFile = [[NSBundle mainBundle] URLForResource:@"300"
                                               withExtension:@"wav"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile
                                                                        error:nil];
    [self.backgroundMusic play];
}


- (IBAction)play400Hz:(id)sender {
    [self setupAndPrepareToRecord];
    [recorder record];
   
    timeLoop = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                              selector:@selector(loopThrough)
                                              userInfo:nil
                                              repeats:isRunningLoop];
    measureDecibel = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                     selector:@selector(measureDecibel)
                                                     userInfo:nil
                                                      repeats:true];
    NSURL *musicFile = [[NSBundle mainBundle] URLForResource:@"frequency_sweep"
                                               withExtension:@"wav"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile
                                                                  error:nil];
    [self.backgroundMusic play];
    
   


    
   
    
}
-(void)loopThrough{
    
    if (hertz <=225) {
        //hertz = hertz + 25;
    }else{
       // hertz = 400;
        isRunningLoop = NO;
        [timeLoop invalidate];
        [measureDecibel invalidate];
        NSLog(@"Loop needs to stop");
        PFObject *testData = [PFObject objectWithClassName:@"TestData"];
        testData[@"DecibelArray"] = recordedDecibalOutput;
        [testData saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                //it worked
                 [recordedDecibalOutput removeAllObjects];
            }else{
                //catch error
            }
        }];
       
    }
    
    // add decibal output
    
    
    
    
}
-(void)measureDecibel{
    NSNumber *num = [NSNumber numberWithFloat:[self actualDecibal]];
    NSString *actualOutput = [NSString stringWithFormat:@"%@ %@",hertzString,num];
   [recordedDecibalOutput addObject:actualOutput];
    hertz = hertz + 25;

}





- (IBAction)play500hz:(id)sender {
    NSURL *musicFile = [[NSBundle mainBundle] URLForResource:@"500"
                                               withExtension:@"wav"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile
                                                                  error:nil];
    [self.backgroundMusic play];
}




/*
    Button to log test data
 */
double testDecible;
- (IBAction)logTestData:(id)sender {
    [recorder updateMeters];
    decibel = [recorder averagePowerForChannel:0];
    PFObject *testData = [PFObject objectWithClassName:@"TestData"];
    testData[@"Decibel"] = @(decibel);
    [testData saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            //it worked
        }else{
            //catch error
        }
    }];
    _output.text = [NSString stringWithFormat: @"%f", decibel];

}

-(void)uploadData{
    PFObject *waterData = [PFObject objectWithClassName:@"WaterData"];
    waterData[@"average"] = @(avg);
    if(smallestDecibel != 0){
        waterData[@"lowest"] = @(smallestDecibel);
    }
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
            // do something with the new geoPoint
            waterData[@"location"] = geoPoint;
        
    }];

    
    waterData[@"highest"] = @((abs)(highDeci));
    [waterData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
        } else {
            // There was a problem, check error.description
        }
    }];
    
    

}

//Dont touch
- (IBAction)stop:(id)sender {
    [self resetRunningAverage];
    [averageTimer invalidate];
    [highTimer invalidate];
    [lowTimer invalidate];
    [labelTimer invalidate];
    [self.backgroundMusic pause];
}
-(void)resetRunningAverage{
    average = 0;
    count = 0;
    avg = 0;
    
    
}
-(void) runningAverage{
    average += (abs)([self averageDecibel]);
    count++;
    avg = (int)( average/count);
     _average.title = [NSString stringWithFormat: @"Average: %d", avg];
    
}
-(void) highestDecible{
    int normalDeci = [self averageDecibel];
    highDeci = (int)[recorder peakPowerForChannel:0];
    if((abs)(highDeci) < (abs)(normalDeci)){
        highDeci = normalDeci;
    }
    _high.title = [NSString stringWithFormat: @"Highest: %d", (abs)(highDeci)];
    
}
-(void)lowestDecible{
    if([recorder peakPowerForChannel:0] < smallestDecibel){
        smallestDecibel = decibel;
    }
    _low.title = [NSString stringWithFormat: @"Lowest: %d", (abs)(smallestDecibel)];
}
/*
-(int) convertPercentage{
 
}*/
-(void)labelText{
    if((abs)([self averageDecibel]) > 60){
        response = @"Dry";
    }else if ((abs)([self averageDecibel]) <= 60 && (abs)([self averageDecibel])>=43)
    {
        response = @"Moist";
    }else{
        response = @"Wet";
    }
   // _output.text = [NSString stringWithFormat: @"%@", response];
    
}

- (void)setupAndPrepareToRecord
{
    if (!IMPEDE_PLAYBACK) {
        [AudioSessionManager setAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
    }
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:1];
    recordedAudioFileName = [NSString stringWithFormat:@"%@", date];
    
    // sets the path for audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [NSString stringWithFormat:@"%@.m4a", [self recordedAudioFileName]],
                               nil];
    recordedAudioURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // settings for the recorder
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    // initiate recorder
    NSError *error;
    recorder = [[AVAudioRecorder alloc] initWithURL:[self recordedAudioURL] settings:recordSetting error:&error];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[self player] stop];
}

@end
