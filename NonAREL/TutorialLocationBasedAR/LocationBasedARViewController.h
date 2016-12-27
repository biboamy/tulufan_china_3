// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "NonARELTutorialViewController.h"

@interface LocationBasedARViewController : NonARELTutorialViewController
{
    metaio::IGeometry*	track_stuff;
    metaio::IGeometry*	track_stuff2;
    metaio::IGeometry*	track_stuff3;
    metaio::IGeometry*	finder;
    metaio::IGeometry*	top_title;
    metaio::IGeometry*	back_btn;
    metaio::IGeometry*	picture_taken;
    metaio::IGeometry*	footer;
    
    metaio::IGeometry*	shutterSound;
    
    metaio::IGeometry* tangshengSound;
    metaio::IGeometry* playBtn;
    metaio::IGeometry* pauseBtn;
    metaio::IGeometry* replayBtn;
    
    //download background
    metaio::IGeometry* background;
    metaio::IGeometry* backgroundWord;
    
    metaio::IGeometry* downloadTicket;
    
    //便是確認
    metaio::IGeometry* checkPanel;
    metaio::IGeometry* trackDownload;
    metaio::IGeometry* trackEnter;
    metaio::IGeometry* blackBack;
    
    //download stuff
    NSString *model[4];
    NSString *modelPath[4];//createModelPath
    int downloadType;
    int downloadTest;
    
    int enable;
    int count;
    int testFirstTime;
    int testPlayBtn;
    
    int testScreen;
    
    //test network
    int testNetWork;
}
@property (nonatomic, assign) int  readvalue;

@end
