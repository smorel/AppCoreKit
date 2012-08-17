//
//  CKTypeAhead.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#include "CKTypeAhead.h"
#include <iostream>
#include <string>
#include <fstream>
#include <ext/hash_map>

#import "NSString+Additions.h"

// magic numbers from http://www.isthe.com/chongo/tech/comp/fnv/ 
static const size_t InitialFNV = 2166136261U;
static const size_t FNVMultiple = 16777619;

// Fowler / Noll / Vo (FNV) Hash 
size_t computeHash(const std::string &s)
{
    size_t hash = InitialFNV;
    for(size_t i = 0; i < s.length(); i++)
    {
        hash = hash ^ (s[i]);       // xor  the low 8 bits 
        hash = hash * FNVMultiple;  // multiply by the magic number 
    }
    return hash;
}


struct TimeProfiler{
	clock_t start,end;
	std::string str;
	TimeProfiler(const std::string& _str):str(_str){
		start = clock();
	}
	~TimeProfiler(){
		end = clock();
		double time_in_seconds = (double)(end - start)/(double)CLOCKS_PER_SEC;
		NSLog(@"%s Duration = %g seconds",str.c_str(),time_in_seconds);
	}
};

using namespace __gnu_cxx;
typedef hash_map<size_t,unsigned int> FatType;

struct CKTypeAheadStreamReader{
	std::ifstream wordsFile,fatFile,indexesFile;
	FatType fat;
	
	CKTypeAheadStreamReader(const std::string& wordsPath,const std::string& fatPath,const std::string& indexesPath){
		wordsFile.open(wordsPath.c_str(), std::ios_base::in);
		fatFile.open(fatPath.c_str(), std::ios_base::binary | std::ios_base::in);
		indexesFile.open(indexesPath.c_str(), std::ios_base::binary | std::ios_base::in);
		loadFat();
	}
	
	void loadFat(){
		unsigned int fatSize = 0;
		fatFile.read((char*)&fatSize, (sizeof(unsigned int)));
		fat.resize(fatSize);
		
		TimeProfiler profiler("loadFat");
		size_t strHash = 0;
		unsigned int indexesSeekOffset = 0;
		while(fatFile.good()){
			fatFile.read((char*)&strHash, (sizeof(size_t)));
			fatFile.read((char*)&indexesSeekOffset, (sizeof(unsigned int)));
			fat[strHash] = indexesSeekOffset;
		}
		fatFile.close();
	}
	
	unsigned int getWordCountForText(const std::string& txt, unsigned int& seekOffset){
		std::string key = txt;
		
		FatType::iterator it = fat.find(computeHash(key));
		while(it == fat.end() && !key.empty()){
			key = key.substr(0,key.length()-1);
			it = fat.find(computeHash(key));
		}
		
		if(!key.empty()){
			unsigned int indexesOffset = it->second;
			indexesFile.seekg(0,std::ios::beg);
			indexesFile.clear();
			indexesFile.seekg(indexesOffset);
			
			unsigned int count = 0;
			indexesFile.read((char*)&count, (sizeof(unsigned int)));
			
			seekOffset = indexesFile.tellg();
			return count;
		}
		return 0;
	}
	
	void getWordsSeekIndexForText(const std::string& txt, std::vector<unsigned int>& indexes, int first, int numberOfWords){
		unsigned int seekOffset = 0;
		unsigned int count = getWordCountForText(txt,seekOffset);
		
        #define min(a,b)(a < b) ? a : b;
		int ibegin = min(first,count);
		int iend   = min(ibegin + numberOfWords,count);
		indexesFile.seekg(0,std::ios::beg);
		indexesFile.clear();
		indexesFile.seekg(seekOffset + (ibegin * sizeof(unsigned int)));
		
		for(unsigned int i=0; i < iend - ibegin; ++i){
			unsigned int index = 0;
			indexesFile.read((char*)&index, (sizeof(unsigned int)));
			indexes.push_back(index);
		}
	}
	
	void getWorkAtSeekIndex(unsigned int seekIndex,std::string& word){
		wordsFile.seekg(0,std::ios::beg);
		wordsFile.clear();
		wordsFile.seekg(seekIndex);
		unsigned int wordLength = 0;
		wordsFile.read((char*)&wordLength, (sizeof(unsigned int)));
		
		char buffer[1024] = "\0";
		wordsFile.read((char*)&buffer, (sizeof(char)*wordLength));
		word = buffer;
	}
	
	void getWordsForText(const std::string& txt, std::vector<std::string>& words, int first, int numberOfWords){
		std::vector<unsigned int> indexes;
		getWordsSeekIndexForText(txt,indexes,first,numberOfWords);
		for(int i=0;i<indexes.size();++i){
			std::string word;
			getWorkAtSeekIndex(indexes[i],word);
			
			words.push_back(word);
		}
	}
};


/* CKManagedTypeAheadStreamReader & CKTypeAheadStreamReaderManager
       Those Helpers object will manage sharing readers between multiple instances of CKTypeAhead
       initialized with the same name. That avoid to load fat for the same files several times ...
 */

struct CKManagedTypeAheadStreamReader{
	CKTypeAheadStreamReader* reader;
	int refCount;
	
	CKManagedTypeAheadStreamReader() : refCount(0),reader(0){}
	CKManagedTypeAheadStreamReader(CKTypeAheadStreamReader* _reader) : refCount(1),reader(_reader){}
	~CKManagedTypeAheadStreamReader(){ if(refCount == 0 && reader) delete reader; }
	
	const CKManagedTypeAheadStreamReader& operator = (const CKManagedTypeAheadStreamReader& other){
		reader = other.reader;
		refCount = other.refCount;
		return *this;
	}
	
	void release(){ refCount--; }
};

@interface CKTypeAheadStreamReaderManager : NSObject{
	hash_map<size_t,CKManagedTypeAheadStreamReader> readers;
}

+ (CKTypeAheadStreamReaderManager*)defaultManager;
- (CKTypeAheadStreamReader*)findOrCreateReaderWithWithName:(NSString*)name wordsPath:(NSString*)words fatPath:(NSString*)fat indexesPath:(NSString*)indexes;
- (CKTypeAheadStreamReader*)readerForName:(NSString*)name;
- (void)releaseReaderForName:(NSString*)name;

@end

static CKTypeAheadStreamReaderManager* CKTypeAheadStreamReaderDefaultManager = nil;
@implementation CKTypeAheadStreamReaderManager

+ (CKTypeAheadStreamReaderManager*)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CKTypeAheadStreamReaderDefaultManager = [[CKTypeAheadStreamReaderManager alloc]init];
    });
	return CKTypeAheadStreamReaderDefaultManager;
}

- (CKTypeAheadStreamReader*)findOrCreateReaderWithWithName:(NSString*)name wordsPath:(NSString*)words fatPath:(NSString*)fat indexesPath:(NSString*)indexes{
	size_t key = computeHash([name UTF8String]);
	hash_map<size_t,CKManagedTypeAheadStreamReader>::iterator it = readers.find(key);
	if(it != readers.end()){
		return it->second.reader;
	}
	
	readers[key] = CKManagedTypeAheadStreamReader(new CKTypeAheadStreamReader([words UTF8String],[fat UTF8String],[indexes UTF8String]));
	return readers[key].reader;
}

- (CKTypeAheadStreamReader*)readerForName:(NSString*)name{
	size_t key = computeHash([name UTF8String]);
	hash_map<size_t,CKManagedTypeAheadStreamReader>::iterator it = readers.find(key);
	if(it != readers.end()){
		return it->second.reader;
	}
	return nil;
}

- (void)releaseReaderForName:(NSString*)name{
	size_t key = computeHash([name UTF8String]);
	hash_map<size_t,CKManagedTypeAheadStreamReader>::iterator it = readers.find(key);
	if(it != readers.end()){
		CKManagedTypeAheadStreamReader& managedReader = it->second;
		managedReader.release();
		if(managedReader.refCount == 0){
			readers.erase(it);
		}
	}
}

@end


@interface CKTypeAhead ()
+ (NSString*)formatStringForIndexation:(NSString*)txt;
@end


static NSMutableCharacterSet* CKTypeAheadFormatingStringCharacterSet = nil;
@implementation CKTypeAhead{
	NSString* name;
}

@synthesize name;

- (void)dealloc{
	[[CKTypeAheadStreamReaderManager defaultManager] releaseReaderForName:self.name];
	self.name = nil;
	[super dealloc];
}

+ (NSString*)formatStringForIndexation:(NSString*)txt{
	NSString* result = [txt stringUsingASCIIEncoding];
	result = [result lowercaseString];
	
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet* set = [NSMutableCharacterSet lowercaseLetterCharacterSet];
        [set formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
        CKTypeAheadFormatingStringCharacterSet = [set retain];
    });
	
	NSArray* components = [result componentsSeparatedByCharactersInSet:[CKTypeAheadFormatingStringCharacterSet invertedSet]];
	result = [components componentsJoinedByString:@""];
	
	return result;
}

- (id)initWithName:(NSString*)fileName{
	self.name = fileName;
	NSString* wordsFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"words"];
	NSString* fatFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"fat"];
	NSString* indexesFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"indexes"];
	[[CKTypeAheadStreamReaderManager defaultManager] findOrCreateReaderWithWithName:fileName wordsPath:wordsFilePath fatPath:fatFilePath indexesPath:indexesFilePath];
	return self;
}

- (NSArray*)stringsWithPrefix:(NSString*)prefix{
	return [self stringsWithPrefix:prefix range:NSMakeRange(0,0)];
}

- (NSArray*)stringsWithPrefix:(NSString*)prefix range:(NSRange)range{
	NSString* search = [CKTypeAhead formatStringForIndexation:prefix];
	
	CKTypeAheadStreamReader* streamer = [[CKTypeAheadStreamReaderManager defaultManager] readerForName:self.name];
	
	std::vector<std::string> words;
	(*streamer).getWordsForText([search UTF8String],words,range.location,range.length);
								
	NSMutableArray* results = [NSMutableArray array];
	for(int i=0;i<words.size();++i){
		NSString* word = [NSString stringWithUTF8String:words[i].c_str()];
		NSString* indexedWord = [CKTypeAhead formatStringForIndexation:word];
		if([indexedWord hasPrefix:search]){
			[results addObject:word];
		}
	}
	return results;
}


- (NSUInteger)numberOfStringsWithPrefix:(NSString*)prefix{
	NSString* search = [CKTypeAhead formatStringForIndexation:prefix];
	unsigned int seekOffset = 0;
	
	CKTypeAheadStreamReader* streamer = [[CKTypeAheadStreamReaderManager defaultManager] readerForName:self.name];
	return (*streamer).getWordCountForText([search UTF8String],seekOffset);
}

@end