//
//  main.m
//  TypeAheadCrunch
//
//  Created by Martin Dufort on 12-09-13.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTypeAhead+Generator.h"

#include <iostream>
#include <string>
#include <stdio.h>

int main(int argc, const char * argv[])
{
    std::string inputFile;
    std::string outputPath;
    
    for(int i =1; i<argc; ++i){
        std::string arg = argv[i];
        if(arg.compare("--input") == 0){
            inputFile = argv[i+1];
            ++i;
            if(outputPath.empty()){
                outputPath = inputFile.substr(0,inputFile.find_last_of("/"));
            }
        }else if(arg.compare("--output-path") == 0){
            outputPath = argv[i+1];
            ++i;
        }
    }
    
    NSLog(@"Generating TypeAhead with input : %s output Path : %s",inputFile.c_str(),outputPath.c_str());
    
    [CKTypeAhead generateTypeAheadWithContentOfFileWithPath:[NSString stringWithUTF8String:inputFile.c_str()] writeToPath:[NSString stringWithUTF8String:outputPath.c_str()]];
    
    return 0;

}

