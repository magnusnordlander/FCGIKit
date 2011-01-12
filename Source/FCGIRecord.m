//
//  FCGIRecord.m
//  FCGIKit
//
//  Created by Magnus Nordlander on 2010-12-31.
//  Copyright 2010 Smiling Plants HB. All rights reserved.
//

#import "FCGIRecord.h"
#import "FCGIBeginRequestRecord.h"
#import "FCGIParamsRecord.h"
#import "FCGIByteStreamRecord.h"

@implementation FCGIRecord

@synthesize version, type, requestId, contentLength, paddingLength;

-(id)init {
    if ((self = [super init])) {
      
    }
    
    return self;
}

+(id)recordWithHeaderData:(NSData*)data
{
  FCGIRecordType type;
  [data getBytes:&type range:NSMakeRange(1, 1)];
  
  FCGIRecord* record;
  
  switch(type)
  {
    case FCGI_BEGIN_REQUEST:
      record = [[FCGIBeginRequestRecord alloc] init];
    break;
    case FCGI_PARAMS:
      record = [[FCGIParamsRecord alloc] init];
    break;
    case FCGI_STDIN:
      record = [[FCGIByteStreamRecord alloc] init];
    break;
    default:
      record = nil;
  }
  
  record.type = type;
  
  FCGIVersion version;
  [data getBytes:&version range:NSMakeRange(0, 1)];
  record.version = version;

  FCGIPaddingLength paddingLength;
  [data getBytes:&paddingLength range:NSMakeRange(6, 1)];
  record.paddingLength = paddingLength;
  
  uint16 bigEndianRequestId;
  [data getBytes:&bigEndianRequestId range:NSMakeRange(2, 2)];
  record.requestId = EndianU16_BtoN(bigEndianRequestId);
  
  uint16 bigEndianContentLength;
  [data getBytes:&bigEndianContentLength range:NSMakeRange(4, 2)];
  record.contentLength = EndianU16_BtoN(bigEndianContentLength);

  return [record autorelease];
}

-(void)processContentData:(NSData*)data
{

}

- (NSString*)description
{
  return [NSString stringWithFormat:@"Version: %d, Type: %d, Request-ID: %d, ContentLength: %d, PaddingLength: %d", self.version, self.type, self.requestId, self.contentLength, self.paddingLength];
}

-(NSData*)headerProtocolData
{
  NSMutableData* protocolData = [NSMutableData dataWithCapacity:1024];
  [protocolData appendBytes:&version length:1];
  [protocolData appendBytes:&type length:1];
  
  uint16 bigEndianRequestId = EndianU16_NtoB(self.requestId);
  [protocolData appendBytes:&bigEndianRequestId length:2];
  
  uint16 bigEndianContentLength = EndianU16_NtoB(self.contentLength);
  [protocolData appendBytes:&bigEndianContentLength length:2];
  
  [protocolData appendBytes:&paddingLength length:1];

  unsigned char reserved = 0x00;
  [protocolData appendBytes:&reserved length:1];

  return protocolData;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

@end