//
//  HTTPMultipartBuilder.m
// 
//
//  Created by Daniel Norton on 12/10/10.
//  Copyright 2010 Bandit Software. All rights reserved.
//

#import "HTTPMultipartBuilder.h"
#import "NSDictionary+join.h"

#define kMultipartFormatStart @"\r\n--%@\r\n"
#define kMultipartFormatEnd @"\r\n--%@\r\n"
#define kMultipartFormatEndLast @"\r\n--%@--\r\n"

@interface HTTPMultipartBuilder()

+ (void)setRequest:(NSMutableURLRequest *)request withParametersAndNoAttachment:(NSDictionary *)parameters;
+ (NSData *)attachmentDataFromTransfer:(AttachmentTransfer *)transfer withBoundary:(NSString *)boundary isLastParam:(BOOL)isLastParam;
+ (NSData *)parameterData:(NSDictionary *)parameters key:(NSString *)key withBoundary:(NSString *)boundary isLastParam:(BOOL)isLastParam;

@end



@implementation HTTPMultipartBuilder

+ (void)setRequest:(NSMutableURLRequest *)request withParameters:(NSDictionary *)parameters withAttachment:(AttachmentTransfer *)attachment {
	
	if (!attachment) {
		[HTTPMultipartBuilder setRequest:request withParametersAndNoAttachment:parameters];
		return;
	}

	NSString *boundary = [NSString stringWithFormat:@"----%i", [request hash]];
	
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

	for (NSString *key in [parameters allKeys]) {
		
		NSData *data = [HTTPMultipartBuilder parameterData:parameters key:key withBoundary:boundary isLastParam:NO];
		[postBody appendData:data];
	}

	NSData *data = [HTTPMultipartBuilder attachmentDataFromTransfer:attachment withBoundary:boundary isLastParam:YES];	
	[postBody appendData:data];
	
	[request setHTTPBody:postBody];
}

+ (void)setRequest:(NSMutableURLRequest *)request withParametersAndNoAttachment:(NSDictionary *)parameters {
	
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	NSString *paramsString = [parameters join];
	NSData *postData = [paramsString dataUsingEncoding:NSUTF8StringEncoding];	
	[request setHTTPBody:postData];
}

+ (NSData *)attachmentDataFromTransfer:(AttachmentTransfer *)transfer withBoundary:(NSString *)boundary isLastParam:(BOOL)isLastParam {
	
	NSMutableData *data = [NSMutableData data];
	
	NSString *contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",
									transfer.parameterName,
									transfer.destinationFileName];

	[data appendData:[contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", transfer.contentType] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSData *file = [NSData dataWithContentsOfURL:transfer.localURL];
	[data appendData:file];
	
	NSString *format = isLastParam ? kMultipartFormatEndLast : kMultipartFormatEnd;
	[data appendData:[[NSString stringWithFormat:format, boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	return data;
}

+ (NSData *)parameterData:(NSDictionary *)parameters key:(NSString *)key withBoundary:(NSString *)boundary isLastParam:(BOOL)isLastParam {
	
	NSMutableData *data = [NSMutableData data];
	
	NSString *contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
	[data appendData:[contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[[parameters objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];

	NSString *format = isLastParam ? kMultipartFormatEndLast : kMultipartFormatEnd;
	[data appendData:[[NSString stringWithFormat:format, boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	return data;
}


@end

