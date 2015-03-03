//
//  AKSound.m
//  test_SWF
//
//  Created by Sebastien Morel on 12-01-26.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import "AKSound.h"
#import "AKSoundPrivate.h"

#import <AppCoreKit/AppCoreKit.h>

static NSMutableSet* AKSoundPlayingSounds = nil;

@implementation AKSound
@synthesize name = _name;
@synthesize filePath = _filePath;
@synthesize scene = _scene;
@synthesize playing = _playing;
@synthesize sceneRef = _sceneRef;
@synthesize audioPlayer = _audioPlayer;
@synthesize block = _block;
@synthesize isTemporaryFile = _isTemporaryFile;

- (void)dealloc{
    [AKSoundPlayingSounds removeObject:[NSValue valueWithNonretainedObject:self]];
    
    if(_isTemporaryFile){
        NSError* error = nil;
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_filePath];
        if(fileExists){
            [[NSFileManager defaultManager]removeItemAtPath:_filePath error:&error];
        }
        if(error){
            NSLog(@"Could not remove sound file error : %@",error);
        }
    }
    
    [_block release];
    [_audioPlayer release];
    [_sceneRef release];
    [_name release];
    [_filePath release];
    [super dealloc];
}

- (void)setScene:(AKSceneView *)scene{
    __block AKSound* bself = self;
    self.sceneRef = [CKWeakRef weakRefWithObject:scene block:^(CKWeakRef *weakRef) {
        [bself stop];
    }];
}

- (AKSceneView*)scene{
    return [_sceneRef object];
}

+ (AKSound*)soundNamed:(NSString*)name{
    return [[[AKSound alloc]initWithContentOfFile:_snd(name)]autorelease];
}

+ (AKSound*)soundWithContentOfFile:(NSString*)path{
    return [[[AKSound alloc]initWithContentOfFile:path]autorelease];
}

+ (AKSound*)instanceOfSound:(AKSound*)thesound{
    if(thesound == nil || thesound.filePath == nil){
        //if sound is invalid, we create a fake sound just to be able to play it with completion as we often have code depending on sound completion
        //if the sound is invalid like that, the duration of the "fake" sound will be 0 and a log message will appear in the output.
        AKSound* sound = [[[AKSound alloc]init]autorelease];
        sound.name = thesound.name;
        sound.scene = thesound.scene;
        
        [thesound.scene.debugger addEvent:[AKDebugContentEvent eventWithObject:self type:AKDebugFrameEventTypeNotFound name:[NSString stringWithFormat:@"SOUND (%@)",sound.name]]];
        return sound;
    }
    
    AKSound* sound = [[[AKSound alloc]initWithContentOfFile:thesound.filePath]autorelease];
    sound.name = thesound.name;
    sound.scene = thesound.scene;
    return sound;
}

- (AKSound*)createInstance{
    return [AKSound instanceOfSound:self];
}

- (id)initWithContentOfFile:(NSString*)path temporaryFile:(BOOL)temporaryFile{
    self = [super init];
    
    NSAssert(path != nil,@"invalid file path");
    
    self.name = [[path lastPathComponent] stringByDeletingPathExtension];
    self.filePath = path;
    
    self.playing = NO;
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
    
    NSError* error = nil;
    [[AVAudioSession sharedInstance] setActive: YES error: &error];
    if(error){
        NSLog(@"Could not activate sound session");
    }
        
    self.isTemporaryFile = temporaryFile;
    
    NSAssert(_filePath!= nil,@"invalid file path");
    
    if(!_audioPlayer){
        NSError* error = nil;
        self.audioPlayer = [[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:self.filePath] error:&error ]autorelease];
        if(error){
            NSLog(@"Could not initialize audio player with path : %@",self.filePath);
        }
        
        [_audioPlayer setVolume:1.0];
        [_audioPlayer prepareToPlay];
        [_audioPlayer setDelegate:self];
    }
    
    return self;
}

- (id)initWithContentOfFile:(NSString*)path{
    return [self initWithContentOfFile:path temporaryFile:NO];
}

- (id)initWithData:(NSData*)data filename:(NSString*)filename{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSError* error = nil;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if(fileExists){
        [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
    }
    if(error){
        NSLog(@"Could not remove sound file error : %@",error);
    }
    
    [data writeToFile:path options:NSDataWritingAtomic error:&error];
    if(error){
        NSLog(@"Could not write sound file error : %@",error);
    }
    
    return [self initWithContentOfFile:path temporaryFile:YES];
}

- (BOOL)playWithCompletion:(void(^)(AKSound* sound))completion{
    if(_audioPlayer.playing)
        return NO;//currently playing
    
    if(!AKSoundPlayingSounds){
        AKSoundPlayingSounds = [[NSMutableSet alloc]init];
    }
    [AKSoundPlayingSounds addObject:[NSValue valueWithNonretainedObject:self]];
    
    self.block = completion;
    if(![_audioPlayer play]){
        if(completion){
            completion(self);
        }
        return NO;
    }
    self.playing = YES;
    
    [self retain];
    
    return YES;
}

- (BOOL)play{
    return [self playWithCompletion:nil];
}

- (void)stop{
    if(!_audioPlayer.playing)
        return;
    
    [AKSoundPlayingSounds removeObject:[NSValue valueWithNonretainedObject:self]];
    
    [_audioPlayer stop];
    self.playing = NO;
    self.block = nil;
    
    [self autorelease];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if(flag && _block){
        _block(self);
    }
    [AKSoundPlayingSounds removeObject:[NSValue valueWithNonretainedObject:self]];
    self.playing = NO;
    
    [self autorelease];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSAssert(error == nil,[error description]);
}

+ (void)stopAllSounds{
    NSSet* soundsToStop = [NSSet setWithSet:AKSoundPlayingSounds];
    for(NSValue* soundValue in soundsToStop){
        AKSound* sound = [soundValue nonretainedObjectValue];
        [sound stop];
    }
}


+ (NSString*)localizedFilePathForSoundNamed:(NSString*)soundName{
    NSString* currentLanguage = [[CKLocalizationManager sharedManager]language];
    NSString *path = [[ NSBundle mainBundle ] pathForResource:currentLanguage ofType:@"lproj" ];
    NSBundle* bundle = [ NSBundle mainBundle ];
    if (path != nil){
        bundle = [NSBundle bundleWithPath:path];
    }
    
    NSString* result = [bundle pathForResource:soundName ofType:nil];
    if(!result){
        result = [[ NSBundle mainBundle ] pathForResource:soundName ofType:nil];
    }
    return result;
}

/*
+ (NSDictionary *)getMetadataForFile:(NSString *)filePath {
    AudioFileID fileID  = nil;
    OSStatus err        = noErr;
    
    NSURL *fileURL = [[NSURL alloc]initFileURLWithPath:filePath];
    
    err = AudioFileOpenURL( (CFURLRef) fileURL, kAudioFileReadPermission, 0, &fileID );
    if( err != noErr ) {
        NSLog( @"AudioFileOpenURL failed" );
        return nil;
    }
    
    UInt32 id3DataSize  = 0;
    char * rawID3Tag    = NULL;
    
    err = AudioFileGetPropertyInfo( fileID, kAudioFilePropertyID3Tag, &id3DataSize, NULL );
    if( err != noErr ) {
        NSLog( @"AudioFileGetPropertyInfo failed for ID3 tag" );
        return nil;
    }
    
    rawID3Tag = (char *) malloc( id3DataSize );
    if( rawID3Tag == NULL ) {
        //NSLog( @"could not allocate %d bytes of memory for ID3 tag", id3DataSize );
        return nil;
    }
    
    err = AudioFileGetProperty( fileID, kAudioFilePropertyID3Tag, &id3DataSize, rawID3Tag );
    if( err != noErr ) {
        NSLog( @"AudioFileGetProperty failed for ID3 tag" );
        return nil;
    }
    
    
    CFDictionaryRef piDict = nil;
    UInt32 piDataSize   = sizeof( piDict );
    
    err = AudioFileGetProperty( fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict );
    if( err != noErr ) {
        NSLog( @"AudioFileGetProperty failed for property info dictionary" );
        return nil;
    }
    
    return (NSDictionary*)piDict;
}
 */


@end
