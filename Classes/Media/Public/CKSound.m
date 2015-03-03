//
//  CKSound.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 15-03-03.
//

#import "CKSound.h"
#import "CKLocalizationManager.h"

static NSMutableSet* CKSoundPlayingSounds = nil;

typedef void(^CKSoundCallbackBlock)(CKSound* sound);

@interface CKSound()
@property(nonatomic,copy) NSString* filePath;
@property(nonatomic,retain) AVAudioPlayer* audioPlayer;
@property(nonatomic,copy) CKSoundCallbackBlock block;
@property(nonatomic,assign,readwrite) BOOL playing;
@property(nonatomic,assign) BOOL isTemporaryFile;

@end


@implementation CKSound
@synthesize name = _name;
@synthesize filePath = _filePath;
@synthesize playing = _playing;
@synthesize audioPlayer = _audioPlayer;
@synthesize block = _block;
@synthesize isTemporaryFile = _isTemporaryFile;

- (void)dealloc{
    [CKSoundPlayingSounds removeObject:[NSValue valueWithNonretainedObject:self]];
    
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
    [_name release];
    [_filePath release];
    [super dealloc];
}

+ (CKSound*)soundNamed:(NSString*)name{
    return [[[CKSound alloc]initWithContentOfFile:_snd(name)]autorelease];
}

+ (CKSound*)soundWithContentOfFile:(NSString*)path{
    return [[[CKSound alloc]initWithContentOfFile:path]autorelease];
}

+ (CKSound*)instanceOfSound:(CKSound*)thesound{
    if(thesound == nil || thesound.filePath == nil){
        //if sound is invalid, we create a fake sound just to be able to play it with completion as we often have code depending on sound completion
        //if the sound is invalid like that, the duration of the "fake" sound will be 0 and a log message will appear in the output.
        CKSound* sound = [[[CKSound alloc]init]autorelease];
        sound.name = thesound.name;
        return sound;
    }
    
    CKSound* sound = [[[CKSound alloc]initWithContentOfFile:thesound.filePath]autorelease];
    sound.name = thesound.name;
    return sound;
}

- (CKSound*)createInstance{
    return [CKSound instanceOfSound:self];
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

- (BOOL)playWithCompletion:(void(^)(CKSound* sound))completion{
    if(_audioPlayer.playing)
        return NO;//currently playing
    
    if(!CKSoundPlayingSounds){
        CKSoundPlayingSounds = [[NSMutableSet alloc]init];
    }
    [CKSoundPlayingSounds addObject:[NSValue valueWithNonretainedObject:self]];
    
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
    
    [CKSoundPlayingSounds removeObject:[NSValue valueWithNonretainedObject:self]];
    
    [_audioPlayer stop];
    self.playing = NO;
    self.block = nil;
    
    [self autorelease];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if(flag && _block){
        _block(self);
    }
    [CKSoundPlayingSounds removeObject:[NSValue valueWithNonretainedObject:self]];
    self.playing = NO;
    
    [self autorelease];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSAssert(error == nil,[error description]);
}

+ (void)stopAllSounds{
    NSSet* soundsToStop = [NSSet setWithSet:CKSoundPlayingSounds];
    for(NSValue* soundValue in soundsToStop){
        CKSound* sound = [soundValue nonretainedObjectValue];
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
