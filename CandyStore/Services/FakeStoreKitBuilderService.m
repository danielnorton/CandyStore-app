//
//  FakeStoreKitBuilderService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/14/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "FakeStoreKitBuilderService.h"
#import "Model.h"
#import "ProductRepository.h"
#import "PurchaseRepository.h"
#import "ExchangeItemRepository.h"
#import "NSData+Base64.h"



@interface FakeStoreKitBuilderService()

@property (nonatomic, weak) NSManagedObjectContext *context;

@end


@implementation FakeStoreKitBuilderService


#pragma mark -
#pragma mark FakeStoreKitProductBuilderService
- (void)buildFakesForContext:(NSManagedObjectContext *)aContext {
	
	[self setContext:aContext];
	
	[self buildFakeProductDescriptions];
	[self buildFakePurchases];
	
	[_context save:nil];
}


#pragma mark Private Messages
- (void)buildFakeProductDescriptions {
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:_context];
	
	
	Product *product = (Product *)[repo itemForId:@"com.brimstead.candystore2.orangecandy"];
	[product setLocalizedPrice:@"$0.99"];
	[product setTitle:@"Orange Candy"];
	[product setProductDescription:@"Delicious orange candy to buy and \"eat\" in your app"];
	
	
	product = (Product *)[repo itemForId:@"com.brimstead.candystore2.bluecandy"];
	[product setLocalizedPrice:@"$0.99"];
	[product setTitle:@"Blue Candy"];
	[product setProductDescription:@"Delicious blue candy to buy and \"eat\" in your app"];
	
	
	product = (Product *)[repo itemForId:@"com.brimstead.candystore2.redcandy"];
	[product setLocalizedPrice:@"$0.99"];
	[product setTitle:@"Red Candy"];
	[product setProductDescription:@"Delicious red candy to buy and \"eat\" in your app"];
	
	
	product = (Product *)[repo itemForId:@"com.brimstead.candystore2.purplecandy"];
	[product setLocalizedPrice:@"$0.99"];
	[product setTitle:@"Purple Candy"];
	[product setProductDescription:@"Delicious purple candy to buy and \"eat\" in your app"];
	
	
	product = (Product *)[repo itemForId:@"com.brimstead.candystore2.greencandy"];
	[product setLocalizedPrice:@"$0.99"];
	[product setTitle:@"Green Candy"];
	[product setProductDescription:@"Delicious green candy to buy and \"eat\" in your app"];
	
	
	product = (Product *)[repo itemForId:@"com.brimstead.candystore2.bigcandyjar"];
	[product setLocalizedPrice:@"$1.99"];
	[product setTitle:@"Big Candy Jar"];
	[product setProductDescription:@"The Big Candy Jar allows you to store virtually unlimited amounts of candy on your device."];
	
	
	product = (Product *)[repo itemForId:@"com.brimstead.candystore2.exchange"];
	[product setTitle:@"Candy Exchange"];
	[product setProductDescription:@"The Candy Exchange allows you to trade candy you have on your device for other candy in the Candy Shop"];
	
	
	product = (Product *)[repo itemForId:@"com.brimstead.candystore2.exchange.7day"];
	[product setLocalizedPrice:@"$0.99"];
	[product setTitle:@"Candy Exchange"];
	
	product = (Product *)[repo itemForId:@"com.brimstead.candystore2.exchange.6mo"];
	[product setLocalizedPrice:@"$1.99"];
	[product setTitle:@"Candy Exchange"];
	
	product = (Product *)[repo itemForId:@"com.brimstead.candystore2.exchange.1yr"];
	[product setLocalizedPrice:@"$2.99"];
	[product setTitle:@"Candy Exchange"];
}

- (void)buildFakePurchases {
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:_context];
	PurchaseRepository *purchaseRepo = [[PurchaseRepository alloc] initWithContext:_context];
	
	
	NSString *transactionIdentifier = @"1000000004805264";
	NSString *receipt = @"ewoJInNpZ25hdHVyZSIgPSAiQW14Um1QZmkxYXNZci9INHVDT2ZjTlh1d3djeHg3QWl4MXFIYTBMazVqYkFlZlVJSDUwK3hRS0psaXl6cy82eXBYd1BHeUMrN2ZVRnBZd0lDSW52RWpNZlowc0dLeGh5RUZTK2FhWXp6V3FOdnNEMXYvVTlDZXlhNDhUWFdhWEZJSFR4eXFFamhlZ3BzS1VsbjNtRVRhRTF4dm9yRWxETktWK0pIQyt0T2lKOUFBQURWekNDQTFNd2dnSTdvQU1DQVFJQ0NHVVVrVTNaV0FTMU1BMEdDU3FHU0liM0RRRUJCUVVBTUg4eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURXpNREVHQTFVRUF3d3FRWEJ3YkdVZ2FWUjFibVZ6SUZOMGIzSmxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1CNFhEVEE1TURZeE5USXlNRFUxTmxvWERURTBNRFl4TkRJeU1EVTFObG93WkRFak1DRUdBMVVFQXd3YVVIVnlZMmhoYzJWU1pXTmxhWEIwUTJWeWRHbG1hV05oZEdVeEd6QVpCZ05WQkFzTUVrRndjR3hsSUdsVWRXNWxjeUJUZEc5eVpURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd2daOHdEUVlKS29aSWh2Y05BUUVCQlFBRGdZMEFNSUdKQW9HQkFNclJqRjJjdDRJclNkaVRDaGFJMGc4cHd2L2NtSHM4cC9Sd1YvcnQvOTFYS1ZoTmw0WElCaW1LalFRTmZnSHNEczZ5anUrK0RyS0pFN3VLc3BoTWRkS1lmRkU1ckdYc0FkQkVqQndSSXhleFRldngzSExFRkdBdDFtb0t4NTA5ZGh4dGlJZERnSnYyWWFWczQ5QjB1SnZOZHk2U01xTk5MSHNETHpEUzlvWkhBZ01CQUFHamNqQndNQXdHQTFVZEV3RUIvd1FDTUFBd0h3WURWUjBqQkJnd0ZvQVVOaDNvNHAyQzBnRVl0VEpyRHRkREM1RllRem93RGdZRFZSMFBBUUgvQkFRREFnZUFNQjBHQTFVZERnUVdCQlNwZzRQeUdVakZQaEpYQ0JUTXphTittVjhrOVRBUUJnb3Foa2lHOTJOa0JnVUJCQUlGQURBTkJna3Foa2lHOXcwQkFRVUZBQU9DQVFFQUVhU2JQanRtTjRDL0lCM1FFcEszMlJ4YWNDRFhkVlhBZVZSZVM1RmFaeGMrdDg4cFFQOTNCaUF4dmRXLzNlVFNNR1k1RmJlQVlMM2V0cVA1Z204d3JGb2pYMGlreVZSU3RRKy9BUTBLRWp0cUIwN2tMczlRVWU4Y3pSOFVHZmRNMUV1bVYvVWd2RGQ0TndOWXhMUU1nNFdUUWZna1FRVnk4R1had1ZIZ2JFL1VDNlk3MDUzcEdYQms1MU5QTTN3b3hoZDNnU1JMdlhqK2xvSHNTdGNURXFlOXBCRHBtRzUrc2s0dHcrR0szR01lRU41LytlMVFUOW5wL0tsMW5qK2FCdzdDMHhzeTBiRm5hQWQxY1NTNnhkb3J5L0NVdk02Z3RLc21uT09kcVRlc2JwMGJzOHNuNldxczBDOWRnY3hSSHVPTVoydG04bnBMVW03YXJnT1N6UT09IjsKCSJwdXJjaGFzZS1pbmZvIiA9ICJld29KSW1sMFpXMHRhV1FpSUQwZ0lqUTFNekE1TXpFME1pSTdDZ2tpYjNKcFoybHVZV3d0ZEhKaGJuTmhZM1JwYjI0dGFXUWlJRDBnSWpFd01EQXdNREF3TURRNE1EVXlOalFpT3dvSkluQjFjbU5vWVhObExXUmhkR1VpSUQwZ0lqSXdNVEV0TURndE1EUWdNVGs2TWpNNk1EUWdSWFJqTDBkTlZDSTdDZ2tpY0hKdlpIVmpkQzFwWkNJZ1BTQWlZMjl0TG1KeWFXMXpkR1ZoWkM1allXNWtlWE4wYjNKbExtSnNkV1ZqWVc1a2VTSTdDZ2tpZEhKaGJuTmhZM1JwYjI0dGFXUWlJRDBnSWpFd01EQXdNREF3TURRNE1EVXlOalFpT3dvSkluRjFZVzUwYVhSNUlpQTlJQ0l4SWpzS0NTSnZjbWxuYVc1aGJDMXdkWEpqYUdGelpTMWtZWFJsSWlBOUlDSXlNREV4TFRBNExUQTBJREU1T2pJek9qQTBJRVYwWXk5SFRWUWlPd29KSW1KcFpDSWdQU0FpWTI5dExtSnlhVzF6ZEdWaFpDNURZVzVrZVZOMGIzSmxJanNLQ1NKaWRuSnpJaUE5SUNJeExqQWlPd3A5IjsKCSJlbnZpcm9ubWVudCIgPSAiU2FuZGJveCI7CgkicG9kIiA9ICIxMDAiOwoJInNpZ25pbmctc3RhdHVzIiA9ICIwIjsKfQ==";
	Product *product = (Product *)[repo itemForId:@"com.brimstead.candystore2.bluecandy"];
	Purchase *purchase = [purchaseRepo addOrRetreivePurchaseForProduct:product withTransactionIdentifier:transactionIdentifier];
	[purchase setReceipt:[NSData dataFromBase64String:receipt]];

	
	transactionIdentifier = @"1000000005248017";
	receipt = @"ewoJInNpZ25hdHVyZSIgPSAiQWlOMDRqUWNSdjA4eTdkSFE1ckNKdGVQNnpTZ3Q1dlR6M1FZcTkvYmk1QVk4bmVtaGhuRzBVYVc3TkZGSitLRklQMlBsMmZGMWFTN05MSnVFZGtJQUp2NkpFUlNBeUNlT3pQLytsQnZTWTR5TmhXTW83VmhqSmlyZWtNTUI4ejVZUGFhSWpqK0hSMmt0OTVVaHJhNGx0d09LK21Jc1k4YnhyU3U5eWcyYUw0c0FBQURWekNDQTFNd2dnSTdvQU1DQVFJQ0NHVVVrVTNaV0FTMU1BMEdDU3FHU0liM0RRRUJCUVVBTUg4eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURXpNREVHQTFVRUF3d3FRWEJ3YkdVZ2FWUjFibVZ6SUZOMGIzSmxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1CNFhEVEE1TURZeE5USXlNRFUxTmxvWERURTBNRFl4TkRJeU1EVTFObG93WkRFak1DRUdBMVVFQXd3YVVIVnlZMmhoYzJWU1pXTmxhWEIwUTJWeWRHbG1hV05oZEdVeEd6QVpCZ05WQkFzTUVrRndjR3hsSUdsVWRXNWxjeUJUZEc5eVpURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd2daOHdEUVlKS29aSWh2Y05BUUVCQlFBRGdZMEFNSUdKQW9HQkFNclJqRjJjdDRJclNkaVRDaGFJMGc4cHd2L2NtSHM4cC9Sd1YvcnQvOTFYS1ZoTmw0WElCaW1LalFRTmZnSHNEczZ5anUrK0RyS0pFN3VLc3BoTWRkS1lmRkU1ckdYc0FkQkVqQndSSXhleFRldngzSExFRkdBdDFtb0t4NTA5ZGh4dGlJZERnSnYyWWFWczQ5QjB1SnZOZHk2U01xTk5MSHNETHpEUzlvWkhBZ01CQUFHamNqQndNQXdHQTFVZEV3RUIvd1FDTUFBd0h3WURWUjBqQkJnd0ZvQVVOaDNvNHAyQzBnRVl0VEpyRHRkREM1RllRem93RGdZRFZSMFBBUUgvQkFRREFnZUFNQjBHQTFVZERnUVdCQlNwZzRQeUdVakZQaEpYQ0JUTXphTittVjhrOVRBUUJnb3Foa2lHOTJOa0JnVUJCQUlGQURBTkJna3Foa2lHOXcwQkFRVUZBQU9DQVFFQUVhU2JQanRtTjRDL0lCM1FFcEszMlJ4YWNDRFhkVlhBZVZSZVM1RmFaeGMrdDg4cFFQOTNCaUF4dmRXLzNlVFNNR1k1RmJlQVlMM2V0cVA1Z204d3JGb2pYMGlreVZSU3RRKy9BUTBLRWp0cUIwN2tMczlRVWU4Y3pSOFVHZmRNMUV1bVYvVWd2RGQ0TndOWXhMUU1nNFdUUWZna1FRVnk4R1had1ZIZ2JFL1VDNlk3MDUzcEdYQms1MU5QTTN3b3hoZDNnU1JMdlhqK2xvSHNTdGNURXFlOXBCRHBtRzUrc2s0dHcrR0szR01lRU41LytlMVFUOW5wL0tsMW5qK2FCdzdDMHhzeTBiRm5hQWQxY1NTNnhkb3J5L0NVdk02Z3RLc21uT09kcVRlc2JwMGJzOHNuNldxczBDOWRnY3hSSHVPTVoydG04bnBMVW03YXJnT1N6UT09IjsKCSJwdXJjaGFzZS1pbmZvIiA9ICJld29KSW1sMFpXMHRhV1FpSUQwZ0lqUTFORFkzTXpNeE5pSTdDZ2tpYjNKcFoybHVZV3d0ZEhKaGJuTmhZM1JwYjI0dGFXUWlJRDBnSWpFd01EQXdNREF3TURVeU5EZ3dNVGNpT3dvSkluQjFjbU5vWVhObExXUmhkR1VpSUQwZ0lqSXdNVEV0TURndE1USWdNRE02TURNNk1Ua2dSWFJqTDBkTlZDSTdDZ2tpY0hKdlpIVmpkQzFwWkNJZ1BTQWlZMjl0TG1KeWFXMXpkR1ZoWkM1allXNWtlWE4wYjNKbExtOXlZVzVuWldOaGJtUjVJanNLQ1NKMGNtRnVjMkZqZEdsdmJpMXBaQ0lnUFNBaU1UQXdNREF3TURBd05USTBPREF4TnlJN0Nna2ljWFZoYm5ScGRIa2lJRDBnSWpFaU93b0pJbTl5YVdkcGJtRnNMWEIxY21Ob1lYTmxMV1JoZEdVaUlEMGdJakl3TVRFdE1EZ3RNVElnTURNNk1ETTZNVGtnUlhSakwwZE5WQ0k3Q2draVltbGtJaUE5SUNKamIyMHVZbkpwYlhOMFpXRmtMa05oYm1SNVUzUnZjbVVpT3dvSkltSjJjbk1pSUQwZ0lqRXVNQ0k3Q24wPSI7CgkiZW52aXJvbm1lbnQiID0gIlNhbmRib3giOwoJInBvZCIgPSAiMTAwIjsKCSJzaWduaW5nLXN0YXR1cyIgPSAiMCI7Cn0=";
	product = (Product *)[repo itemForId:@"com.brimstead.candystore2.orangecandy"];
	purchase = [purchaseRepo addOrRetreivePurchaseForProduct:product withTransactionIdentifier:transactionIdentifier];
	[purchase setReceipt:[NSData dataFromBase64String:receipt]];

	
	transactionIdentifier = @"1000000004699289";
	receipt = @"ew0KCSJzaWduYXR1cmUiID0gIkFqb2lOVWxxR2h5VGx5VFFaemlkK0R1ZExNZWE3eHdXUks0aU12NlAzZW5QdjhkcDIwMGs4bk9vdjFIOVVnT2tKV2xIZStSMytTL3hwd2xTYlpwOFNZR1NySGpzbVZvY0J0TG9NR1pUSCtQbXFkMTN0YjBURXJSYzZ6VWFkZWtxUUFJeGh0c2FMNk9qbTJFTEo2NFJvYUpVT0dnZmIyZTdTWGM1Y0JCZVF3QUhBQUFEVnpDQ0ExTXdnZ0k3b0FNQ0FRSUNDR1VVa1UzWldBUzFNQTBHQ1NxR1NJYjNEUUVCQlFVQU1IOHhDekFKQmdOVkJBWVRBbFZUTVJNd0VRWURWUVFLREFwQmNIQnNaU0JKYm1NdU1TWXdKQVlEVlFRTERCMUJjSEJzWlNCRFpYSjBhV1pwWTJGMGFXOXVJRUYxZEdodmNtbDBlVEV6TURFR0ExVUVBd3dxUVhCd2JHVWdhVlIxYm1WeklGTjBiM0psSUVObGNuUnBabWxqWVhScGIyNGdRWFYwYUc5eWFYUjVNQjRYRFRBNU1EWXhOVEl5TURVMU5sb1hEVEUwTURZeE5ESXlNRFUxTmxvd1pERWpNQ0VHQTFVRUF3d2FVSFZ5WTJoaGMyVlNaV05sYVhCMFEyVnlkR2xtYVdOaGRHVXhHekFaQmdOVkJBc01Fa0Z3Y0d4bElHbFVkVzVsY3lCVGRHOXlaVEVUTUJFR0ExVUVDZ3dLUVhCd2JHVWdTVzVqTGpFTE1Ba0dBMVVFQmhNQ1ZWTXdnWjh3RFFZSktvWklodmNOQVFFQkJRQURnWTBBTUlHSkFvR0JBTXJSakYyY3Q0SXJTZGlUQ2hhSTBnOHB3di9jbUhzOHAvUndWL3J0LzkxWEtWaE5sNFhJQmltS2pRUU5mZ0hzRHM2eWp1KytEcktKRTd1S3NwaE1kZEtZZkZFNXJHWHNBZEJFakJ3Ukl4ZXhUZXZ4M0hMRUZHQXQxbW9LeDUwOWRoeHRpSWREZ0p2MllhVnM0OUIwdUp2TmR5NlNNcU5OTEhzREx6RFM5b1pIQWdNQkFBR2pjakJ3TUF3R0ExVWRFd0VCL3dRQ01BQXdId1lEVlIwakJCZ3dGb0FVTmgzbzRwMkMwZ0VZdFRKckR0ZERDNUZZUXpvd0RnWURWUjBQQVFIL0JBUURBZ2VBTUIwR0ExVWREZ1FXQkJTcGc0UHlHVWpGUGhKWENCVE16YU4rbVY4azlUQVFCZ29xaGtpRzkyTmtCZ1VCQkFJRkFEQU5CZ2txaGtpRzl3MEJBUVVGQUFPQ0FRRUFFYVNiUGp0bU40Qy9JQjNRRXBLMzJSeGFjQ0RYZFZYQWVWUmVTNUZhWnhjK3Q4OHBRUDkzQmlBeHZkVy8zZVRTTUdZNUZiZUFZTDNldHFQNWdtOHdyRm9qWDBpa3lWUlN0USsvQVEwS0VqdHFCMDdrTHM5UVVlOGN6UjhVR2ZkTTFFdW1WL1VndkRkNE53Tll4TFFNZzRXVFFmZ2tRUVZ5OEdYWndWSGdiRS9VQzZZNzA1M3BHWEJrNTFOUE0zd294aGQzZ1NSTHZYaitsb0hzU3RjVEVxZTlwQkRwbUc1K3NrNHR3K0dLM0dNZUVONS8rZTFRVDlucC9LbDFuaithQnc3QzB4c3kwYkZuYUFkMWNTUzZ4ZG9yeS9DVXZNNmd0S3Ntbk9PZHFUZXNicDBiczhzbjZXcXMwQzlkZ2N4Ukh1T01aMnRtOG5wTFVtN2FyZ09TelE9PSI7DQoJInB1cmNoYXNlLWluZm8iID0gImV3b0pJbWwwWlcwdGFXUWlJRDBnSWpRMU16QTVOREE1T0NJN0Nna2liM0pwWjJsdVlXd3RkSEpoYm5OaFkzUnBiMjR0YVdRaUlEMGdJakV3TURBd01EQXdNRFEyT1RreU9Ea2lPd29KSW5CMWNtTm9ZWE5sTFdSaGRHVWlJRDBnSWpJd01URXRNRGd0TURNZ01EWTZNemc2TXpjZ1JYUmpMMGROVkNJN0Nna2ljSEp2WkhWamRDMXBaQ0lnUFNBaVkyOXRMbUp5YVcxemRHVmhaQzVqWVc1a2VYTjBiM0psTG1KcFoyTmhibVI1YW1GeUlqc0tDU0owY21GdWMyRmpkR2x2YmkxcFpDSWdQU0FpTVRBd01EQXdNREF3TkRZNU9USTRPU0k3Q2draWNYVmhiblJwZEhraUlEMGdJakVpT3dvSkltOXlhV2RwYm1Gc0xYQjFjbU5vWVhObExXUmhkR1VpSUQwZ0lqSXdNVEV0TURndE1ETWdNRFk2TXpnNk16Y2dSWFJqTDBkTlZDSTdDZ2tpWW1sa0lpQTlJQ0pqYjIwdVluSnBiWE4wWldGa0xrTmhibVI1VTNSdmNtVWlPd29KSW1KMmNuTWlJRDBnSWpFdU1DSTdDbjA9IjsNCgkiZW52aXJvbm1lbnQiID0gIlNhbmRib3giOw0KCSJwb2QiID0gIjEwMCI7DQoJInNpZ25pbmctc3RhdHVzIiA9ICIwIjsNCn0NCg==";
	product = (Product *)[repo itemForId:@"com.brimstead.candystore2.bigcandyjar"];
	purchase = [purchaseRepo addOrRetreivePurchaseForProduct:product withTransactionIdentifier:transactionIdentifier];
	[purchase setReceipt:[NSData dataFromBase64String:receipt]];
	
	
	// This receipt is long since expired, but the app (and service) allows a user to continue to consume
	// new exchanges if they already have credits. So, it's an easy step to fake the data on the server side
	// to add new credits to this transaction identifier and allow a way for more products to make it into this
	// test account
	transactionIdentifier = @"1000000004746100";
	receipt = @"ewoJInNpZ25hdHVyZSIgPSAiQWhYR3dWaG91SUw0MktPSk92OTg1cTg3NnRtM2FHNTg3SnZZTm85WldrRXJyd2ZvN0x0QkN6UUNrVWxzNUtLVXV3MU1PNEhXd08xVSs2K1BvM1pCY3JaRXVoUTFYSURPNjRFdkNHUkJRSzdOTEE0cTNpMUdVWWx6U0ZlWjZRK2dmMDQ3b3NrQjIyQklUbXZnNERHaVkzUVVhV0J1VGtRN0NESWN4b1pDNkFCQ0FBQURWekNDQTFNd2dnSTdvQU1DQVFJQ0NHVVVrVTNaV0FTMU1BMEdDU3FHU0liM0RRRUJCUVVBTUg4eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURXpNREVHQTFVRUF3d3FRWEJ3YkdVZ2FWUjFibVZ6SUZOMGIzSmxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1CNFhEVEE1TURZeE5USXlNRFUxTmxvWERURTBNRFl4TkRJeU1EVTFObG93WkRFak1DRUdBMVVFQXd3YVVIVnlZMmhoYzJWU1pXTmxhWEIwUTJWeWRHbG1hV05oZEdVeEd6QVpCZ05WQkFzTUVrRndjR3hsSUdsVWRXNWxjeUJUZEc5eVpURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd2daOHdEUVlKS29aSWh2Y05BUUVCQlFBRGdZMEFNSUdKQW9HQkFNclJqRjJjdDRJclNkaVRDaGFJMGc4cHd2L2NtSHM4cC9Sd1YvcnQvOTFYS1ZoTmw0WElCaW1LalFRTmZnSHNEczZ5anUrK0RyS0pFN3VLc3BoTWRkS1lmRkU1ckdYc0FkQkVqQndSSXhleFRldngzSExFRkdBdDFtb0t4NTA5ZGh4dGlJZERnSnYyWWFWczQ5QjB1SnZOZHk2U01xTk5MSHNETHpEUzlvWkhBZ01CQUFHamNqQndNQXdHQTFVZEV3RUIvd1FDTUFBd0h3WURWUjBqQkJnd0ZvQVVOaDNvNHAyQzBnRVl0VEpyRHRkREM1RllRem93RGdZRFZSMFBBUUgvQkFRREFnZUFNQjBHQTFVZERnUVdCQlNwZzRQeUdVakZQaEpYQ0JUTXphTittVjhrOVRBUUJnb3Foa2lHOTJOa0JnVUJCQUlGQURBTkJna3Foa2lHOXcwQkFRVUZBQU9DQVFFQUVhU2JQanRtTjRDL0lCM1FFcEszMlJ4YWNDRFhkVlhBZVZSZVM1RmFaeGMrdDg4cFFQOTNCaUF4dmRXLzNlVFNNR1k1RmJlQVlMM2V0cVA1Z204d3JGb2pYMGlreVZSU3RRKy9BUTBLRWp0cUIwN2tMczlRVWU4Y3pSOFVHZmRNMUV1bVYvVWd2RGQ0TndOWXhMUU1nNFdUUWZna1FRVnk4R1had1ZIZ2JFL1VDNlk3MDUzcEdYQms1MU5QTTN3b3hoZDNnU1JMdlhqK2xvSHNTdGNURXFlOXBCRHBtRzUrc2s0dHcrR0szR01lRU41LytlMVFUOW5wL0tsMW5qK2FCdzdDMHhzeTBiRm5hQWQxY1NTNnhkb3J5L0NVdk02Z3RLc21uT09kcVRlc2JwMGJzOHNuNldxczBDOWRnY3hSSHVPTVoydG04bnBMVW03YXJnT1N6UT09IjsKCSJwdXJjaGFzZS1pbmZvIiA9ICJld29KSW5GMVlXNTBhWFI1SWlBOUlDSXhJanNLQ1NKd2RYSmphR0Z6WlMxa1lYUmxJaUE5SUNJeU1ERXhMVEE0TFRBMElERTVPakkxT2pJNUlFVjBZeTlIVFZRaU93b0pJbWwwWlcwdGFXUWlJRDBnSWpRMU16QTVOamN3TmlJN0Nna2laWGh3YVhKbGN5MWtZWFJsTFdadmNtMWhkSFJsWkNJZ1BTQWlNakF4TVMwd09DMHdOQ0F4T1RveU9Eb3lPU0JGZEdNdlIwMVVJanNLQ1NKbGVIQnBjbVZ6TFdSaGRHVWlJRDBnSWpFek1USTBPRFl4TURrME5qRWlPd29KSW5CeWIyUjFZM1F0YVdRaUlEMGdJbU52YlM1aWNtbHRjM1JsWVdRdVkyRnVaSGx6ZEc5eVpTNWxlR05vWVc1blpTNDNaR0Y1SWpzS0NTSjBjbUZ1YzJGamRHbHZiaTFwWkNJZ1BTQWlNVEF3TURBd01EQXdORGd3TlRNME55STdDZ2tpYjNKcFoybHVZV3d0Y0hWeVkyaGhjMlV0WkdGMFpTSWdQU0FpTWpBeE1TMHdPQzB3TXlBeU1UbzBOVG93TWlCRmRHTXZSMDFVSWpzS0NTSnZjbWxuYVc1aGJDMTBjbUZ1YzJGamRHbHZiaTFwWkNJZ1BTQWlNVEF3TURBd01EQXdORGMwTmpFd01DSTdDZ2tpWW1sa0lpQTlJQ0pqYjIwdVluSnBiWE4wWldGa0xrTmhibVI1VTNSdmNtVWlPd29KSW1KMmNuTWlJRDBnSWpFdU1DSTdDbjA9IjsKCSJlbnZpcm9ubWVudCIgPSAiU2FuZGJveCI7CgkicG9kIiA9ICIxMDAiOwoJInNpZ25pbmctc3RhdHVzIiA9ICIwIjsKfQ==";
	product = (Product *)[repo itemForId:@"com.brimstead.candystore2.exchange.7day"];
	purchase = [purchaseRepo addOrRetreivePurchaseForProduct:product withTransactionIdentifier:transactionIdentifier];
	[purchase setReceipt:[NSData dataFromBase64String:receipt]];
}


@end

