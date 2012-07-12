//
//  CKSuffixTree+Generator.mm
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKSuffixTree+Generator.h"

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
	for(int i = 0;i < node->indexes.size(); ++i){
		unsigned int v = node->indexes[i];
		stream.write((char*)&v, (sizeof(unsigned int)));
	}
}

extern size_t computeHash(const std::string &s);

using namespace __gnu_cxx;
typedef hash_map<size_t,unsigned int> FatType;

@interface CKSuffixTree ()
+ (NSString*)formatStringForIndexation:(NSString*)txt;
@end


@implementation CKSuffixTree(CKSuffixTreeGenerator)

+ (void)saveNode:(TreeNodeStruct*)node parentNode:(TreeNodeStruct*)parentNode withBaseName:(NSString*)baseName indexesFile:(std::ofstream*)indexesFile fat:(FatType*)fat{
	if(parentNode && node && node->indexes.size() <= 1 && parentNode->indexes.size() <= 1)
		return;
	
	NSString* name = [NSString stringWithFormat:@"%@%c",baseName,node->key];
	
	unsigned int indexesIndex = (*indexesFile).tellp();
	std::string str = [name UTF8String];
	size_t strHash = computeHash(str);
	(*fat)[strHash] = indexesIndex;
	save(node,*indexesFile);
	
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
		for(FatType::iterator it = fat.begin(); it != fat.end(); ++it){
			fatFile.write((char*)&it->first, (sizeof(size_t)));
			fatFile.write((char*)&it->second, (sizeof(unsigned int)));
		}
		fatFile.close();
	}
}

+ (void)generateSuffixTreeWithContentOfFile:(NSString*)fileName writeToPath:(NSString*)path{
	[CKSuffixTree generateSuffixTreeWithContentOfFile:fileName writeToPath:path maximumNumberOfObjectsPerIndex:0];
}

+ (void)generateSuffixTreeWithContentOfFile:(NSString*)fileName writeToPath:(NSString*)path maximumNumberOfObjectsPerIndex:(NSUInteger)indexLimit{
	NSString* wordsFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
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
				
				NSString* stringToIndex = [CKSuffixTree formatStringForIndexation:[NSString stringWithUTF8String:buffer]];
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

