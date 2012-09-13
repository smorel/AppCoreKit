//
//  CKTypeAhead+Generator.mm
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTypeAhead+Generator.h"

#include <string>
#include <map>
#include <vector>
#include <fstream>
#include <sys/time.h>
#include <time.h>
#include <ext/hash_map>


struct TreeNodeStruct{
public:
	std::vector<unsigned int> indexes;
	std::map<unichar,TreeNodeStruct> nodes;
	unichar key;
	TreeNodeStruct* findOrCreateNode(unichar c);
};

struct TreeStruct{
public:
	std::map<unichar,TreeNodeStruct> roots;
	TreeNodeStruct* findOrCreateNode(unichar c);
};

TreeNodeStruct* TreeNodeStruct::findOrCreateNode(unichar c){
	std::map<unichar,TreeNodeStruct>::iterator itFound = nodes.find(c);
	if(itFound != nodes.end())
		return &itFound->second;
	
	TreeNodeStruct& node = nodes[c];
	node.key = c;
	return &node;
}

TreeNodeStruct* TreeStruct::findOrCreateNode(unichar c){
	std::map<unichar,TreeNodeStruct>::iterator itFound = roots.find(c);
	if(itFound != roots.end())
		return &itFound->second;
	
	TreeNodeStruct& node = roots[c];
	node.key = c;
	return &node;
}

TreeNodeStruct* nodeForText(TreeStruct* tree,const std::string& txt){
	TreeNodeStruct* currentNode = 0;
	for(int i = 0; i<txt.length(); ++i){
		unichar c = txt[i];
		currentNode = currentNode ? currentNode->findOrCreateNode(c) : tree->findOrCreateNode(c);
	}
	return currentNode;
}

void insertText(TreeStruct* tree,const std::string& txt, unsigned int index, unsigned int max){
	TreeNodeStruct* currentNode = 0;
	for(int i = 0; i<txt.length(); ++i){
		unichar c = txt[i];
		currentNode = currentNode ? currentNode->findOrCreateNode(c) : tree->findOrCreateNode(c);
		if(max == 0 || currentNode->indexes.size() < max)
			currentNode->indexes.push_back(index);
	}
}

void save(TreeNodeStruct* node,std::ofstream& stream){
	unsigned int count = node->indexes.size();
	stream.write((char*)&count, (sizeof(unsigned int)));
    
    NSLog(@"CKTypeAhead : Save node count : %u",count);
    
	for(int i = 0;i < node->indexes.size(); ++i){
		unsigned int v = node->indexes[i];
        NSLog(@"CKTypeAhead : Save node index : %u",v);
		stream.write((char*)&v, (sizeof(unsigned int)));
	}
}

extern unsigned long computeHash(const std::string &s);

using namespace __gnu_cxx;
typedef hash_map<unsigned long,unsigned int> FatType;

@interface CKTypeAhead ()
+ (NSString*)formatStringForIndexation:(NSString*)txt;
@end


@implementation CKTypeAhead(CKTypeAheadGenerator)

+ (void)saveNode:(TreeNodeStruct*)node parentNode:(TreeNodeStruct*)parentNode withBaseName:(NSString*)baseName indexesFile:(std::ofstream*)indexesFile fat:(FatType*)fat{
	if(parentNode && node && node->indexes.size() <= 1 && parentNode->indexes.size() <= 1)
		return;
	
	NSString* name = [NSString stringWithFormat:@"%@%c",baseName,node->key];
	
	unsigned int indexesIndex = (*indexesFile).tellp();
	std::string str = [name UTF8String];
	unsigned long strHash = computeHash(str);
	(*fat)[strHash] = indexesIndex;
	save(node,*indexesFile);
    
    NSLog(@"CKTypeAhead : Save node for text : %@ hash : %lu indexesIndex : %u",name,strHash,indexesIndex);
	
	for(std::map<unichar,TreeNodeStruct>::iterator it = node->nodes.begin(); it != node->nodes.end(); ++it){
		[self saveNode:&it->second parentNode:node withBaseName:name indexesFile:indexesFile fat:fat];
	}
}

+ (void)save:(TreeStruct*)tree fileName:(NSString*)fileName path:(NSString*)path{
	NSString *fatPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.fat",fileName]];
	NSString *indexsPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.indexes",fileName]];
	
	FatType fat;
	
	std::ofstream indexesFile;
	indexesFile.open([indexsPath UTF8String], std::ios_base::binary | std::ios_base::out | std::ios_base::trunc);
	if(indexesFile.is_open()){
		for(std::map<unichar,TreeNodeStruct>::iterator it = tree->roots.begin(); it != tree->roots.end(); ++it){
			[self saveNode:&it->second parentNode:nil withBaseName:@"" indexesFile:&indexesFile fat:&fat];
		}
		
		indexesFile.close();
	}
	
	std::ofstream fatFile;
	fatFile.open([fatPath UTF8String], std::ios_base::binary | std::ios_base::out | std::ios_base::trunc);
	if(fatFile.is_open()){
		unsigned int count = fat.size();
		fatFile.write((char*)&count,sizeof(unsigned int));
        
        NSLog(@"CKTypeAhead wirte FAT count : %u",count);
        
		for(FatType::iterator it = fat.begin(); it != fat.end(); ++it){
			fatFile.write((char*)&it->first, 8);
			fatFile.write((char*)&it->second, (sizeof(unsigned int)));
            
            NSLog(@"CKTypeAhead wirte FAT hash : %lu indexesIndex : %u",it->first,it->second);
		}
		fatFile.close();
	}
}

+ (void)generateTypeAheadWithContentOfFile:(NSString*)fileName writeToPath:(NSString*)path{
	[CKTypeAhead generateTypeAheadWithContentOfFile:fileName writeToPath:path maximumNumberOfObjectsPerIndex:0];
}

+ (void)generateTypeAheadWithContentOfFile:(NSString*)fileName writeToPath:(NSString*)path maximumNumberOfObjectsPerIndex:(NSUInteger)indexLimit{
	NSString* wordsFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    [self generateTypeAheadWithContentOfFileWithPath:wordsFilePath writeToPath:path maximumNumberOfObjectsPerIndex:indexLimit];
}

+ (void)generateTypeAheadWithContentOfFileWithPath:(NSString*)filePath writeToPath:(NSString*)path{
	[CKTypeAhead generateTypeAheadWithContentOfFileWithPath:filePath writeToPath:path maximumNumberOfObjectsPerIndex:0];
}

+ (void)generateTypeAheadWithContentOfFileWithPath:(NSString*)wordsFilePath writeToPath:(NSString*)path maximumNumberOfObjectsPerIndex:(NSUInteger)indexLimit{
    NSString* fileName = [[wordsFilePath lastPathComponent] stringByDeletingPathExtension];
    
    std::ifstream wordsFile;
	wordsFile.open([wordsFilePath UTF8String], std::ios_base::in);
	if(wordsFile.is_open()){
		NSString *exportWordsPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.words",fileName]];
		std::ofstream exportWordsFile;
		exportWordsFile.open([exportWordsPath UTF8String], std::ios_base::binary | std::ios_base::out | std::ios_base::trunc);
		if(exportWordsFile.is_open()){
			TreeStruct *tree = new TreeStruct();
			while(wordsFile.good()){
				char buffer[1024] = "\0";
				wordsFile.getline(buffer,1024);
				
				unsigned int seekIndex = exportWordsFile.tellp();
				unsigned int wordSize = strlen(buffer);
				exportWordsFile.write((char*)&wordSize, (sizeof(unsigned int)));
				exportWordsFile.write((char*)buffer, wordSize);
                
                NSLog(@"CKTypeAhead : Save word : %s length : %u seekIndex : %u",buffer,wordSize,seekIndex);
				
				NSString* stringToIndex = [CKTypeAhead formatStringForIndexation:[NSString stringWithUTF8String:buffer]];
				insertText(tree,[stringToIndex UTF8String],seekIndex,indexLimit);
			}
			exportWordsFile.close();
			
			[self save:tree fileName:fileName path:path];
			delete tree;
		}
		
        
		// Validate the words are properly written
        //		std::ifstream exportWordsFileRead;
        //		exportWordsFileRead.open([exportWordsPath UTF8String], std::ios_base::binary | std::ios_base::in);
        //		if(exportWordsFileRead.is_open()){
        //			while(exportWordsFileRead.good()){
        //				unsigned int seekIndex = exportWordsFileRead.tellg();
        //				unsigned int wordSize = 0;
        //				char buffer[1024] = "\0";
        //				
        //				exportWordsFileRead.read((char*)&wordSize, (sizeof(unsigned int)));
        //				exportWordsFileRead.read((char*)buffer, wordSize);
        //			}
        //			exportWordsFileRead.close();
        //		}
        
        
        
		wordsFile.close();
	}
}

@end

