// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "LocationBasedARViewController.h"
//#import "SphereMenu.h"
#import "myapi.h"
#import "AppDelegate.h"
#import "ASImageSharingViewController.h"

@interface LocationBasedARViewController ()<NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession * session;
@property (nonatomic, strong) NSURLSessionDownloadTask * task;
@end

@implementation LocationBasedARViewController

@synthesize readvalue;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    downloadTest=1;
    
    [self loading];
    
    [self testNetwork];
    
    
    NSString *value;
    
    NSString* textID=@"firstTime";
    NSString* textValue=@"01";
    NSString *str = textValue;
    NSString *string = [NSString stringWithString: str];
    
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
    value = [data objectForKey:textID];
    
    const char *cString = [value cStringUsingEncoding:NSASCIIStringEncoding];
    
    if(cString!=NULL){
        NSLog(@"this is test:%@",value);
        testFirstTime=1;
    }
    else{
        [data setObject:string forKey:textID];
        NSLog(@"first time");
        testFirstTime=0;
    }
    
    //test screen
    if(([[UIScreen mainScreen] bounds].size.width)>900)
        testScreen=1;
    else
        testScreen=0;
    
    
    enable = 0;
    
    [self getJson];
    //[self getCount];

}

-(void) loading
{
    NSString* background_model = [[NSBundle mainBundle] pathForResource:@"ARbackground"
                                                                 ofType:@"png"
                                                            inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    if (background_model)
    {
        const char *utf8Path = [background_model UTF8String];
        background = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        background->setCoordinateSystemID(0);
        NSLog(@"test:%d",testScreen);
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
            background->setScale(5.0f);
        else
            background->setScale(4.0f);
        background->setRelativeToScreen(48,8);
        background->setRenderOrder(51);
        background->setVisible(true);
    }
    NSString* backgroundWord_model = [[NSBundle mainBundle] pathForResource:@"ARword"
                                                                 ofType:@"png"
                                                            inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    if (backgroundWord_model)
    {
        const char *utf8Path = [backgroundWord_model UTF8String];
        backgroundWord = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        backgroundWord->setCoordinateSystemID(0);
        backgroundWord->setScale(0.8f);
        backgroundWord->setRelativeToScreen(48,8);
        backgroundWord->setTranslation(metaio::Vector3d(0.0f, -20.0f, 5.0f));
        backgroundWord->setRenderOrder(51);
        backgroundWord->setVisible(true);
    }
    
}

//load check track
-(void) loadCheckTrack
{
    NSString* blackBack_model = [[NSBundle mainBundle] pathForResource:@"bg"
                                                              ofType:@"png"
                                                         inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    if (blackBack_model)
    {
        const char *utf8Path = [blackBack_model UTF8String];
        blackBack = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        blackBack->setCoordinateSystemID(0);
        blackBack->setScale(5.0f);
        blackBack->setRelativeToScreen(48,8);
        blackBack->setTransparency(0.2);
        blackBack->setRenderOrder(18);
        blackBack->setTranslation(metaio::Vector3d(0.0f, 0.0f, 0.0f));
        blackBack->setVisible(true);
    }
    
    
    
    NSString* checkPanelPath = [[NSBundle mainBundle] pathForResource:@"trackBg"
                                                               ofType:@"png"
                                                          inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    
    
    
    if (checkPanelPath)
    {
        const char *utf8Path = [checkPanelPath UTF8String];
        checkPanel = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        checkPanel->setScale(2.0f);
        checkPanel->setVisible(true);
        checkPanel->setRenderOrder(20);
        checkPanel->setRelativeToScreen(48,8);
        checkPanel->setTranslation(metaio::Vector3d(0.0f, 0.0f,1.0f));
    }
    NSString* trackEnterPath = [[NSBundle mainBundle] pathForResource:@"trackEnter"
                                                           ofType:@"png"
                                                      inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    
    
    
    if (trackEnterPath)
    {
        const char *utf8Path = [trackEnterPath UTF8String];
        trackEnter = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        trackEnter->setScale(0.35f);
        trackEnter->setVisible(true);
        trackEnter->setRelativeToScreen(48,8);
        trackEnter->setRenderOrder(21);
        trackEnter->setTranslation(metaio::Vector3d(-80.0f, -60.0f, 2.0f));
    }
    NSString* trackDownloadPath = [[NSBundle mainBundle] pathForResource:@"trackDownload"
                                                          ofType:@"png"
                                                     inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    
    
    
    if (trackDownloadPath)
    {
        const char *utf8Path = [trackDownloadPath UTF8String];
        trackDownload = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        trackDownload->setScale(0.35f);
        trackDownload->setVisible(true);
        trackDownload->setRenderOrder(21);
        trackDownload->setRelativeToScreen(48,8);
        trackDownload->setTranslation(metaio::Vector3d(80.0f, -60.0f, 2.0f));
    }
    [self loadingView];
}

//load image
-(void) loadingView
{
    NSString* shutterSound_model = [[NSBundle mainBundle] pathForResource:@"shutter"
                                                                   ofType:@"3g2"
                                                              inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    if(shutterSound_model)
    {
        const char *utf8Path = [shutterSound_model UTF8String];
        shutterSound =  m_pMetaioSDK->createGeometryFromMovie(metaio::Path::fromUTF8(utf8Path), true); // true for transparent movie
    }
    
    
    const char *utf8PathConf = [modelPath[3] UTF8String];
    NSLog(@"load:%s ",utf8PathConf);
    bool success = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8(utf8PathConf));
    if( !success)
        NSLog(@"No success loading the tracking configuration");
    
    
    NSString* finder_model = [[NSBundle mainBundle] pathForResource:@"xk"
                                                             ofType:@"png"
                                                        inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    
    if (finder_model)
    {
        const char *utf8Path = [finder_model UTF8String];
        finder = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        finder->setCoordinateSystemID(0);
        finder->setScale(2.3f);
        finder->setRelativeToScreen(48,8);
        if(testFirstTime==1){
            finder->setVisible(true);
        }
        else{
            finder->setVisible(false);
        }
    }
    
    NSString* downloadTicket_model = [[NSBundle mainBundle] pathForResource:@"downloadTicket"
                                                             ofType:@"jpg"
                                                        inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    if (downloadTicket_model)
    {
        const char *utf8Path = [downloadTicket_model UTF8String];
        downloadTicket = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        downloadTicket->setCoordinateSystemID(0);
        downloadTicket->setScale(0.40f);
        downloadTicket->setRenderOrder(4);
        downloadTicket->setRelativeToScreen(10,8);
        downloadTicket->setVisible(true);
        downloadTicket->setTranslation(metaio::Vector3d(0.0f, 0.0f, 1.0f));
        if(downloadTicket) NSLog(@"yes");
        else NSLog(@"no");
    }
    
    //load guide
    NSString* tangshengSound_model = [[NSBundle mainBundle] pathForResource:@"guide0"
                                                                     ofType:@"mp3"
                                                                inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    if(tangshengSound_model)
    {
        const char *utf8Path = [tangshengSound_model UTF8String];
        tangshengSound =  m_pMetaioSDK->createGeometryFromMovie(metaio::Path::fromUTF8(utf8Path), false,false);;
        tangshengSound->setCoordinateSystemID(0);
    }
    
    NSString* playBtn_model = [[NSBundle mainBundle] pathForResource:@"playBtn1"
                                                              ofType:@"png"
                                                         inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    if (playBtn_model)
    {
        const char *utf8Path = [playBtn_model UTF8String];
        playBtn = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        playBtn->setCoordinateSystemID(0);
        playBtn->setScale(0.5f);
        playBtn->setRelativeToScreen(5,8);
        playBtn->setRenderOrder(51);
        playBtn->setTranslation(metaio::Vector3d(15.0f, 55.0f, 5.0f));
        playBtn->setVisible(false);
    }
    NSString* pauseBtn_model = [[NSBundle mainBundle] pathForResource:@"pause1"
                                                               ofType:@"png"
                                                          inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    if (pauseBtn_model)
    {
        const char *utf8Path = [pauseBtn_model UTF8String];
        pauseBtn = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        pauseBtn->setCoordinateSystemID(0);
        pauseBtn->setScale(0.5f);
        pauseBtn->setRelativeToScreen(5,8);
        pauseBtn->setRenderOrder(51);
        pauseBtn->setTranslation(metaio::Vector3d(15.0f, 55.0f, 5.0f));
        pauseBtn->setVisible(false);
    }
    NSString* replayBtn_model = [[NSBundle mainBundle] pathForResource:@"replay1"
                                                                ofType:@"png"
                                                           inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    if (replayBtn_model)
    {
        const char *utf8Path = [replayBtn_model UTF8String];
        replayBtn = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        replayBtn->setCoordinateSystemID(0);
        replayBtn->setScale(0.5f);
        replayBtn->setRelativeToScreen(5,8);
        replayBtn->setRenderOrder(51);
        replayBtn->setTranslation(metaio::Vector3d(15.0f, 55.0f, 5.0f));
        replayBtn->setVisible(false);
    }
    
    // load the box
    
    const char *utf8Path = [modelPath[0] UTF8String];
    track_stuff =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
    track_stuff->setScale(54.f);
    
    track_stuff2 =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
    track_stuff2->setScale(27.f);
    track_stuff2->setCoordinateSystemID(2);
    
    track_stuff3 =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
    track_stuff3->setScale(27.f);
    track_stuff3->setCoordinateSystemID(2);
    
    NSString* topTitle_model = [[NSBundle mainBundle] pathForResource:@"top"
                                                               ofType:@"png"
                                                          inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    
    if (topTitle_model)
    {
        const char *utf8Path = [topTitle_model UTF8String];
        top_title = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        top_title->setCoordinateSystemID(0);
        top_title->setScale(0.41f);
        top_title->setRelativeToScreen(10,8);
    }
    NSString* footer_model = [[NSBundle mainBundle] pathForResource:@"foot"
                                                             ofType:@"png"
                                                        inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    
    if (footer_model)
    {
        const char *utf8Path = [footer_model UTF8String];
        footer = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        footer->setCoordinateSystemID(0);
        footer->setScale(0.4f);
        footer->setRelativeToScreen(20,8);
    }
    NSString* back_model = [[NSBundle mainBundle] pathForResource:@"fh"
                                                           ofType:@"png"
                                                      inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    
    if (back_model)
    {
        const char *utf8Path = [back_model UTF8String];
        back_btn = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        back_btn->setCoordinateSystemID(0);
        back_btn->setScale(0.41f);
        back_btn->setRelativeToScreen(9,8);
        back_btn->setRenderOrder(2,false,true);
    }
    NSString* camara_model = [[NSBundle mainBundle] pathForResource:@"cam"
                                                             ofType:@"png"
                                                        inDirectory:@"tutorialContent_crossplatform/Tulufan/Assets"];
    
    if (camara_model)
    {
        const char *utf8Path = [camara_model UTF8String];
        picture_taken = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
        picture_taken->setCoordinateSystemID(0);
        picture_taken->setScale(0.4f);
        picture_taken->setRenderOrder(3);
        picture_taken->setRelativeToScreen(20,8);
        if(testFirstTime==1){
            picture_taken->setVisible(true);
        }
        else{
            picture_taken->setVisible(false);
        }
        picture_taken->setTranslation(metaio::Vector3d(0.0f, 50.0f, 0.0f));
    }
    
    background->setVisible(false);
    backgroundWord->setVisible(false);
}


#pragma mark - App Logic

- (void) onTrackingEvent: (const metaio::stlcompat::Vector<metaio::TrackingValues>&) trackingValues
{
    NSLog(@"hi");
    if (trackingValues.empty() || !trackingValues[0].isTrackingState())
    {NSLog(@"hi1");
        //if(enable==1){
        [self setActiveModel:0];
        //}
    }
    else
    {NSLog(@"hi2");
        [self setActiveModel:1];
        if (track_stuff)
        {
            track_stuff->setVisible(true);
            track_stuff->startAnimation( "ani_appear" , false);
        }
        if (track_stuff2)
        {
            track_stuff2->setVisible(true);
            track_stuff2->startAnimation( "ani_appear" , false);
        }
        if (track_stuff3)
        {
            track_stuff3->setVisible(true);
            track_stuff3->startAnimation( "ani_appear" , false);
        }
    }
}

- (void)onSDKReady
{
    [super onSDKReady];
}

- (void)setActiveModel:(int)modelIndex
{
    switch (modelIndex)
    {
        case 0:
        {
            finder->setVisible(true);
            track_stuff->setVisible(false);
            track_stuff2->setVisible(false);
            track_stuff3->setVisible(false);
            playBtn->setVisible(false);
            break;
        }
        case 1:
        {
            finder->setVisible(false);
            track_stuff->setVisible(true);
            track_stuff2->setVisible(true);
            track_stuff3->setVisible(true);
            break;
        }
    }
}

-(void) testNetwork
{
    //側網路狀態
    NSUserDefaults *data1 = [NSUserDefaults standardUserDefaults];
    NSString *value1 = [data1 objectForKey:@"testNetWork"];
    if([value1 caseInsensitiveCompare:@"0"]==0) testNetWork=0;
    else testNetWork=1;
}

-(void) getJson
{
    NSUserDefaults *data1 = [NSUserDefaults standardUserDefaults];
    
    if(testNetWork==1){
        
        NSString *ConText = @"http://cqplayart.cn/assets/jsonvalue_beta.php";//get json url
        
        NSURL *url = [NSURL URLWithString:ConText];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSData* data_json = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];//將json存入data中
        NSDictionary* jsonObj =
        [NSJSONSerialization JSONObjectWithData:data_json
                                        options:NSJSONReadingMutableContainers   error:nil];
        
        
        //model data
        NSArray *sapan = [[jsonObj objectForKey:@"ticket"] valueForKey:@"sapan"];
        [data1 setObject:sapan[0] forKey:@"sapan"];
        NSArray *track1 = [[jsonObj objectForKey:@"ticket"] valueForKey:@"track1"];
        [data1 setObject:track1[0] forKey:@"track1"];
        NSArray *track2 = [[jsonObj objectForKey:@"ticket"] valueForKey:@"track2"];
        [data1 setObject:track2[0] forKey:@"track2"];
        NSArray *trackConf = [[jsonObj objectForKey:@"ticket"] valueForKey:@"trackConfig"];
        [data1 setObject:trackConf[0] forKey:@"trackConfig"];
        
        model[0] = [data1 objectForKey:@"sapan"];
        NSLog(@"%@",model[0]);
        
        model[1] = [data1 objectForKey:@"track1"];
        NSLog(@"%@",model[1]);
        
        model[2] = [data1 objectForKey:@"track2"];
        NSLog(@"%@",model[2]);
        
        model[3] = [data1 objectForKey:@"trackConfig"];
        NSLog(@"%@",model[3]);
    }
    else
    {
        model[0] = [data1 objectForKey:@"sapan"];
        NSLog(@"%@",model[0]);
        
        model[1] = [data1 objectForKey:@"track1"];
        NSLog(@"%@",model[1]);
        
        model[2] = [data1 objectForKey:@"track2"];
        NSLog(@"%@",model[2]);
        
        model[3] = [data1 objectForKey:@"trackConfig"];
        NSLog(@"%@",model[3]);
    }
    [self modelDownload];
}

- (void) modelDownload{
    NSLog(@"downloadtype:%d %d",downloadType, downloadTest);
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
    while(downloadType<4 && downloadTest==1){
        
        //data save each version
        NSString *temp1 = [NSString stringWithFormat:@"temp%d",downloadType];
        NSString *value = [data objectForKey:temp1];
        
        NSString *checkDownload = [data objectForKey:@"checkDownLoad"];
        
        if( [model[downloadType] compare:value]==NSOrderedSame){//if version is the newest
            NSString *docDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *FilePath;
            NSString *temp;
            if(downloadType==0) temp=[NSString stringWithFormat:@"/%@.zip",model[downloadType]];
            else if(downloadType==3) temp=[NSString stringWithFormat:@"/%@.xml",model[downloadType]];
            else temp=[NSString stringWithFormat:@"/%@.jpg",model[downloadType]];
            FilePath=[docDir stringByAppendingString:temp];
            modelPath[downloadType]=FilePath;
            
            NSLog(@"%@%@",@"檔案存在_true：",modelPath[downloadType]);
            downloadType=downloadType+1;
            
        }
        else{//if not
            downloadTest=0;
            
            NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
            self.session = session;
            NSString *model1url;
            
            if(downloadType==0)model1url = [NSString stringWithFormat:@"%@%@%@", @"http://cqplayart.cn/metaio/",model[downloadType],@".zip"];
            else if(downloadType==3)model1url = [NSString stringWithFormat:@"%@%@%@", @"http://cqplayart.cn/metaio/",model[downloadType],@".xml"];
            else model1url = [NSString stringWithFormat:@"%@%@%@", @"http://cqplayart.cn/metaio/",model[downloadType],@".jpg"];
            
            self.task = [session downloadTaskWithURL:[NSURL URLWithString:[model1url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            [self.task resume];
        }
        NSLog(@"download: %d",downloadType);
        
    }
    if(downloadType==4)
    {
        std::vector<metaio::Camera> cameras = m_pMetaioSDK->getCameraList();
        m_pMetaioSDK->startCamera(cameras[0]);
        
        
        [self loadCheckTrack];
        
        
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        float dtest=0;
        dtest=totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
        //列印下載百分比
        if(dtest==1)
        {
            NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
            NSString *temp1 = [NSString stringWithFormat:@"temp%d",downloadType];
            [data setObject:model[downloadType] forKey:temp1];
            NSLog(@"%f",totalBytesWritten * 1.0 / totalBytesExpectedToWrite);
        }
  
    });
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {

    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *FilePath;
    
    NSString *temp;
    if(downloadType==0)temp=[NSString stringWithFormat:@"/%@.zip",model[downloadType]];
    else if(downloadType==1)temp=@"/track1.jpg";
    else if(downloadType==2)temp=@"/track2.jpg";
    else if(downloadType==3)temp=@"/trackConfig.xml";
    
    NSLog(@"model:%@",model[downloadType]);
    
    FilePath=[docDir stringByAppendingString:temp];
    
    [fileManager moveItemAtPath:location.path toPath:FilePath error:nil];
    BOOL isExist_m = [fileManager fileExistsAtPath:FilePath];
    if(isExist_m){
        NSLog(@"%@%@",@"檔案存在_false：",FilePath);
        modelPath[downloadType]=FilePath;
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        downloadTest=1;
        downloadType=downloadType+1;
        
        [self modelDownload];
        
    });
}

#pragma mark - Handling Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self.glkView];
    float scale = self.glkView.contentScaleFactor;
    metaio::IGeometry* modelTouch = m_pMetaioSDK->getGeometryFromViewportCoordinates(loc.x * scale, loc.y * scale, true);
    //
    if(modelTouch==NULL)
        return 0;
    if(modelTouch==back_btn)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(modelTouch==trackEnter)
    {
        blackBack->setVisible(false);
        trackEnter->setVisible(false);
        trackDownload->setVisible(false);
        checkPanel->setVisible(false);
        
    }
    else if(modelTouch==trackDownload)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://advmedia.cqplayart.cn/ticket.jpg"]];
    }
    else if(modelTouch==downloadTicket)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://advmedia.cqplayart.cn/ticket.jpg"]];
    }
    else if(modelTouch==picture_taken)
    {
        shutterSound->startMovieTexture(false);
        
        picture_taken->setVisible(false);
        back_btn->setVisible(false);
        top_title->setVisible(false);
        footer->setVisible(false);
        finder->setVisible(false);
        playBtn->setVisible(false);
        replayBtn->setVisible(false);
        pauseBtn->setVisible(false);
        
    }
    
    else if(modelTouch==playBtn)
    {
        playBtn->setVisible(false);
        pauseBtn->setVisible(true);
        
        testPlayBtn=3;
        
        tangshengSound->startMovieTexture();
    }
    else if(modelTouch==replayBtn)
    {
        replayBtn->setVisible(false);
        pauseBtn->setVisible(true);
        
        testPlayBtn=3;
        
        tangshengSound->startMovieTexture();
    }
    else if(modelTouch==pauseBtn)
    {
        pauseBtn->setVisible(false);
        playBtn->setVisible(true);
        
        testPlayBtn=1;
        
        tangshengSound->pauseMovieTexture();
    }
    else{NSLog(@"can't detect");}
}

- (void) onAnimationEnd:(metaio::IGeometry *)geometry andName:(const NSString *)animationName
{
    if((geometry==track_stuff || geometry==track_stuff2 || geometry==track_stuff3) && (!(playBtn->getIsRendered()) && !(replayBtn->getIsRendered()) && !(pauseBtn->getIsRendered())))
    {
        testPlayBtn=1;
        playBtn->setVisible(true);
    }
}

- (void) onMovieEnd:(metaio::IGeometry *)geometry andMoviePath:(const NSString *)moviePath
{
    if(geometry==shutterSound)
    {
        [self onSaveScreen];
    }
    else if(geometry==tangshengSound)
    {
        pauseBtn->setVisible(false);
        replayBtn->setVisible(true);
        
        testPlayBtn=2;
    }
    
}

//Screen shot
- (void)onSaveScreen
{
    [self didReadValue:0];
    m_pMetaioSDK->requestScreenshot();
}
-(void)didReadValue:(int)value
{
    readvalue=value;
    return readvalue;
}
- (void) onScreenshotImageIOS:(UIImage *)image
{
    NSLog(@"Implement your sharing controller here.");
    
    /* UIGraphicsBeginImageContext(CGSizeMake(48, 48));
     [image drawInRect:CGRectMake(0, 0, 48,48)];
     UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     [m_imageshow setImage:reSizeImage forState:UIControlStateNormal];*/
    
    [self ImageSharing:image];
}
- (void) ImageSharing:(UIImage *)image
{
    
    
    ASImageSharingViewController* controller = [[ASImageSharingViewController alloc] initWithNibName:@"ASImageSharingViewController" bundle:nil];
    controller.imageToPost = image;
    
    controller.myValue = readvalue;
    [self presentViewController:controller animated:YES completion:nil];
    
    picture_taken->setVisible(true);
    back_btn->setVisible(true);
    top_title->setVisible(true);
    footer->setVisible(true);
    if(!(track_stuff->getIsRendered()) || !(track_stuff2->getIsRendered()) || !(track_stuff3->getIsRendered()) )finder->setVisible(true);
    if(testPlayBtn==1) playBtn->setVisible(true);
    else if(testPlayBtn==2) replayBtn->setVisible(true);
    else if(testPlayBtn==3) pauseBtn->setVisible(true);
    
}
-(void) onScreenshotSaved:(const NSString*) filepath
{
    NSLog(@"Image saved: %@", filepath);
}
//screen shot end

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape; //支援橫向
}

@end