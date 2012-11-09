//
//  CKTypeAhead+Generator.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTypeAhead.h"

/** CKTypeAhead Generator creates 3 files (.fat, .indexes, .words) optimizing search and indexation of a string file for optimal type ahead performances.
 Those files must be inserted in your XCode project to be able to Query the Type Ahead at runtime.
 
 The input file should be a text file containing the lookup strings separated by a line break. The order of the strings in this input file will be kept per index when you will query the TypeAhead later. By this way, you can classify the strings by order of importance for them to be returned first when querying the TypeAhead.
 
 To Generate the TypeAhead files from the string list, You can add the following code to your app delegate, run the app in the simulator and copy the generated files in your source tree :
     [CKTypeAhead generateTypeAheadWithContentOfFile:@"YourStringFile.YourExtension" writeToPath:@"~/TypeAheadTest/"];
 */
@interface CKTypeAhead(CKTypeAheadGenerator)

///-----------------------------------
/// @name Generating Type Ahead files from a sorted text file
///-----------------------------------

/**
 */
+ (void)generateTypeAheadWithContentOfFile:(NSString*)fileName writeToPath:(NSString*)path maximumNumberOfObjectsPerIndex:(NSUInteger)indexLimit;

/**
 */
+ (void)generateTypeAheadWithContentOfFile:(NSString*)fileName writeToPath:(NSString*)path;

/**
 */
+ (void)generateTypeAheadWithContentOfFileWithPath:(NSString*)filePath writeToPath:(NSString*)path maximumNumberOfObjectsPerIndex:(NSUInteger)indexLimit;

/**
 */
+ (void)generateTypeAheadWithContentOfFileWithPath:(NSString*)filePath writeToPath:(NSString*)path;

@end
