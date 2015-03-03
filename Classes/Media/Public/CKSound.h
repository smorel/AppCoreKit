//
//  CKSound.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 15-03-03.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define _snd(soundname) [CKSound localizedFilePathForSoundNamed:soundname]

/** 
 The CKSound class represents an instance of a sound.
 
 This class provides an easy way to play/stop sounds for a localized embedded file, a specified path or a binary content with callbacks at the end of this sound's playback.
 
 Our sound engine is based on AVFoundation and OpenAL. You can refer to these framework's documentation to have an overview of the supported file formats.
 
 <b>Playing several instances of sound in the same time:</b>
 
 An instance of a sound can be played only once at a time. If you need to do so, you should create as much instances of this sound you have to play at the same time using instanceOfSound: or createInstance methods.
 
 Creating several instances of a sound is a costly operation only if you initialize it with initWithData:fileName:
 If you need to play such a sound several time you can do it programatically using:
 
     CKSound* sound1 = [[[CKSound alloc]initWithData:myData name:@"myName.mp3"]autorelease];
     [sound1 play];
     CKSound* sound2 = [sound1 createInstance];
     [sound2 play]; 
 
 <b>Known Performance Issue:</b> 
 
     You could encounter some performance issue when playing a sound for the first time in your application life cycle as the engine takes a several amount of time to get initialized. More or less 2 to 3 seconds depending on the device.
 
 See Also: Samples
 */
@interface CKSound : NSObject<AVAudioPlayerDelegate>

///-----------------------------------
/// @name Initializing a Sound Object
///-----------------------------------

/** Returns an autorelease Sound instance initialized with the localized file named by the specified value.
 
 @param name The file name for the sound. This file name MUST specify the extension (ex. @"mySound.mp3")
 @return An initialized Sound object.
 */
+ (CKSound*)soundNamed:(NSString*)name;

/** Returns an autorelease Sound instance initialized with the specified file path.
 
 @param path The absolute path of the sound file.
 @return An initialized Sound object.
 */
+ (CKSound*)soundWithContentOfFile:(NSString*)path;

/** Returns an autorelease Sound instance initialized with the specified sound's content.
 
 @param sound The original sound containing the content.
 @return An initialized Sound object.
 */
+ (CKSound*)instanceOfSound:(CKSound*)sound;

/** Initializes and returns a newly allocated Sound object by importing the specified file at path.
 
 @param path The absolute path of the sound file.
 @return An initialized Sound object.
 */
- (id)initWithContentOfFile:(NSString*)path;

/** Initializes and returns a newly allocated Sound object using the data and filename.
 
 This method will load an audio player with the specified data and use the specified filename to store the file on the cache directory. The filename MUST specify the right extension (ex. @"mySound.mp3")
 
 @param data The binary data representing a sound file.
 @return An initialized Sound object.
 */
- (id)initWithData:(NSData*)data filename:(NSString*)filename;

/** Returns an autorelease Sound instance initialized with the content of the receiver Sound Object.
 
 @return An initialized Sound object.
 */
- (CKSound*)createInstance;


///-----------------------------------
/// @name Identifying the Sound at Runtime
///-----------------------------------

/** A string that you can use to identify instance object in your application.
 
 The default value is computed at initialization using the fileName and by removing the extension.
 You can set the value of this name and use that value to identify the sound later.
 */
@property(nonatomic,retain) NSString* name;


///-----------------------------------
/// @name Retrieving Sound Informations
///-----------------------------------

/** The absolute file path for the current sound
 */
@property(nonatomic,copy,readonly) NSString* filePath;

/** A Boolean value indicating if the sound is currently playing.
 */
@property(nonatomic,assign,readonly) BOOL playing;


///-----------------------------------
/// @name Managing Sound Playback
///-----------------------------------

/** Play the sound
 
 @return return NO if the sound has not been initialized correctly or is currently playing.
 */
- (BOOL)play;

/** Play the sound with a completion callback
 
 @param completion A completion block that will get executed at the end of the sound's playback. If a sound is stopped before it is supposed to end, this block will not get executed.
 @return return NO if the sound has not been initialized correctly or is currently playing.
 */
- (BOOL)playWithCompletion:(void(^)(CKSound* sound))completion;

/** Stops the sound playback
 */
- (void)stop;

/** Stops All the sounds that are currently playing
 
 This method uninitialize the sound engine. Playing a sound after calling this method could take a several amount of time to re-initialize an engine.
 */
+ (void)stopAllSounds;


///-----------------------------------
/// @name Localization
///-----------------------------------

/** Returns the localized absolute file path for a sound file with specified soundName.
 
 The Specified soundName MUST includes the file extension (ex. @"mySound.mp3").
 A helper macro _snd(soundName) execute this method and help reducing code size.
 
 @return The localized absolute file path for a sound file with specified soundName.
 */
+ (NSString*)localizedFilePathForSoundNamed:(NSString*)soundName;

@end
