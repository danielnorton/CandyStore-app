//
//  ShopItemDetailViewController.m
//  CandyStore
//
//  Created by Daniel Norton on 8/1/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ShopItemDetailViewController.h"
#import "Style.h"
#import "TransactionReceiptService.h"
#import "TransactionDownloadService.h"
#import "UITableViewDelgate+emptyFooter.h"
#import "CandyShopService.h"
#import "PurchaseRulesService.h"
#import "NSObject+popup.h"


#define kPurchaseCellHeight 66.0f
#define kSubscriptionCellHeight 44.0f
#define kMinimumDescriptionHeight 44.0f
#define kDescriptionPadding 20.0f
#define kTitleLabelProductX 69.0f
#define kTitleLabelSubscriptionX 5.0f
#define kShopItemDetailPurchaseCellIdentifier @"shopItemDetailPurchaseCell"


@interface ShopItemDetailViewController()

@property (nonatomic, strong) NSIndexPath *activeBuyButtonIndexPath;

@end


@implementation ShopItemDetailViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.tableView setSeparatorColor:[UIColor shopTableSeperatorColor]];
	[self setTitle:_product.title];
	
	UINib *nib = [UINib nibWithNibName:@"ShopItemDetailPurchaseCell" bundle:nil];
	[self.tableView registerNib:nib forCellReuseIdentifier:kShopItemDetailPurchaseCellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	NSNotificationCenter *ctr = [NSNotificationCenter defaultCenter];
	[ctr addObserverForName:TransactionReceiptServiceCompletedNotification
					 object:nil
					  queue:nil
				 usingBlock:^(NSNotification *notification) {
					 
					 [self.navigationController.view setUserInteractionEnabled:YES];
					 [self.navigationController popToRootViewControllerAnimated:YES];
				 }];
	
	[ctr addObserverForName:TransactionReceiptServiceFailedNotification
					 object:nil
					  queue:nil
				 usingBlock:^(NSNotification *notification) {
					 
					 SKPaymentTransaction *transaction = [notification userInfo][TransactionReceiptServiceKeyTransaction];
					 if (transaction.error.code == -1001) {
						 
						 [self popup:transaction.error.localizedDescription];
					 }
					 
					 [self.navigationController.view setUserInteractionEnabled:YES];
					 [self.tableView reloadData];
				 }];
	
	[ctr addObserverForName:TransactionDownloadServiceBeginTransactionDownloads
					 object:nil
					  queue:nil
				 usingBlock:^(NSNotification *notification) {
					 
					 ShopItemDetailPurchaseCell *cell = (ShopItemDetailPurchaseCell *)[self.tableView cellForRowAtIndexPath:_activeBuyButtonIndexPath];
					 [cell.downloadProgress setHidden:NO];
					 [cell.downloadProgress setProgress:0.0f];
				 }];
	
	[ctr addObserverForName:TransactionDownloadServiceCompleteTransactionDownloads
					 object:nil
					  queue:nil
				 usingBlock:^(NSNotification *notification) {
					 
					 ShopItemDetailPurchaseCell *cell = (ShopItemDetailPurchaseCell *)[self.tableView cellForRowAtIndexPath:_activeBuyButtonIndexPath];
					 [cell.downloadProgress setHidden:NO];
					 [cell.downloadProgress setProgress:1.0f];
					 
					 [self.navigationController.view setUserInteractionEnabled:YES];
					 [self.navigationController popToRootViewControllerAnimated:YES];
				 }];
	
	[ctr addObserverForName:TransactionDownloadServiceReportDownloadWaiting
					 object:nil
					  queue:nil
				 usingBlock:^(NSNotification *notification) {
					 
					 ShopItemDetailPurchaseCell *cell = (ShopItemDetailPurchaseCell *)[self.tableView cellForRowAtIndexPath:_activeBuyButtonIndexPath];
					 [cell.downloadProgress setHidden:NO];
					 [cell.downloadProgress setProgress:0.0f];
				 }];
	
	[ctr addObserverForName:TransactionDownloadServiceReportDownloadActive
					 object:nil
					  queue:nil
				 usingBlock:^(NSNotification *notification) {
					 
					 ShopItemDetailPurchaseCell *cell = (ShopItemDetailPurchaseCell *)[self.tableView cellForRowAtIndexPath:_activeBuyButtonIndexPath];
					 
					 if (![notification.userInfo isKindOfClass:[NSDictionary class]]) return;
					 
					 NSDictionary *userInfo = (NSDictionary *)notification.userInfo;
					 SKDownload *download = (SKDownload *)userInfo[TransactionDownloadServiceKeyDownload];
					 [cell.downloadProgress setHidden:NO];
					 [cell.downloadProgress setProgress:download.progress];
				 }];
	
	[ctr addObserverForName:TransactionDownloadServiceReportDownloadFinished
					 object:nil
					  queue:nil
				 usingBlock:^(NSNotification *notification) {
					 
					 ShopItemDetailPurchaseCell *cell = (ShopItemDetailPurchaseCell *)[self.tableView cellForRowAtIndexPath:_activeBuyButtonIndexPath];
					 
					 if (![notification.userInfo isKindOfClass:[NSDictionary class]]) return;

					 NSDictionary *userInfo = (NSDictionary *)notification.userInfo;
					 SKDownload *download = (SKDownload *)userInfo[TransactionDownloadServiceKeyDownload];
					 [cell.downloadProgress setHidden:NO];
					 [cell.downloadProgress setProgress:download.progress];
				 }];
	
	[ctr addObserverForName:TransactionDownloadServiceReportDownloadFailed
					 object:nil
					  queue:nil
				 usingBlock:^(NSNotification *notification) {
					 
					 ShopItemDetailPurchaseCell *cell = (ShopItemDetailPurchaseCell *)[self.tableView cellForRowAtIndexPath:_activeBuyButtonIndexPath];
					 
					 if (![notification.userInfo isKindOfClass:[NSDictionary class]]) return;
					 
					 NSDictionary *userInfo = (NSDictionary *)notification.userInfo;
					 SKDownload *download = (SKDownload *)userInfo[TransactionDownloadServiceKeyDownload];
					 [cell.downloadProgress setHidden:NO];
					 [cell.downloadProgress setProgress:download.progress];
					 
					 if (!download.error) return;
					 
					 [self popup:download.error.localizedDescription];
				 }];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSUInteger)supportedInterfaceOrientations {
	
	return UIInterfaceOrientationMaskAll;
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	int answer = 2;
	if (_product.subscriptions.count > 0) {
		
		answer += _product.subscriptions.count;
	}
	return answer;
}


#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	if ([self isLastRow:indexPath.row]) {
		
		static NSString *cellIdentifier = @"descriptionIdentifier";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}
		
		[self configureDescriptionCell:cell atIndexPath:indexPath];
		
		return cell;
	}
	
    ShopItemDetailPurchaseCell *cell = (ShopItemDetailPurchaseCell *)[tableView dequeueReusableCellWithIdentifier:kShopItemDetailPurchaseCellIdentifier];
	[self configurePurchaseCell:cell atIndexPath:indexPath];
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0) {
	
		return kPurchaseCellHeight;
		
	} else if ([self isLastRow:indexPath.row]) {
	
		CGSize size = [_product.productDescription sizeWithFont:[UIFont productDescriptionFont]
											 constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
												 lineBreakMode:NSLineBreakByWordWrapping];
		
		float answer = size.height + kDescriptionPadding;
		return answer > kMinimumDescriptionHeight
		? answer
		: kMinimumDescriptionHeight;
	}
	
	return kSubscriptionCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (!_activeBuyButtonIndexPath) return;
	
	ShopItemDetailPurchaseCell *cell = (ShopItemDetailPurchaseCell *)[tableView cellForRowAtIndexPath:_activeBuyButtonIndexPath];
	[cell.buyButton setSelected:NO];
	[cell resizeTitleFromBuyButton];
	[self setActiveBuyButtonIndexPath:nil];
}


#pragma mark SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

	SKPayment *payment = [SKPayment paymentWithProduct:response.products.lastObject];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark ImageCachingServiceDelegate
- (void)imageCachingService:(ImageCachingService *)sender didLoadImage:(UIImage *)image fromPath:(NSString *)path withUserData:(id)userData {
	
	[self reloadVisibleCells];
}


#pragma mark ShopItemDetailPurchaseCellDelegate
- (void)shopItemDetailPurchaseCell:(ShopItemDetailPurchaseCell *)cell didPresentBuyButtonForProduct:(Product *)product {
	
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	[self setActiveBuyButtonIndexPath:indexPath];
}

- (void)shopItemDetailPurchaseCell:(ShopItemDetailPurchaseCell *)cell didChooseToBuyProduct:(Product *)aProduct {
	
	PurchaseRules rule = [PurchaseRulesService canBuyMoreProduct:aProduct];
	if (rule == PurchaseRulesTooManyCandiesForSmallJar) {
		
		[cell.buyButton setSelected:NO];
		
		NSString *message = PurchaseRuleDescriptionTooManyCandiesForSmallJar;
		[self popup:NSLocalizedString(message, message)];
		return;
		
	} else if (rule == PurchaseRulesPurchasesDisabled) {
		
		[cell.buyButton setSelected:NO];
		
		NSString *message = PurchaseRuleDescriptionPurchaseRulesPurchasesDisabled;
		[self popup:NSLocalizedString(message, message)];
		return;
	}
	
	[self.navigationController.view setUserInteractionEnabled:NO];
	
	NSSet *set = [NSSet setWithObject:aProduct.identifier];
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
	[request setDelegate:self];
	[request start];
}


#pragma mark -
#pragma mark ShopItemDetailViewController
#pragma mark Private Messages
- (BOOL)isLastRow:(int)row {

	int last = [self tableView:self.tableView numberOfRowsInSection:0] - 1;
	return (row == last);
}

- (void)reloadVisibleCells {
	
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths) {
		
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		if ([self isLastRow:indexPath.row]) {
			
			[self configureDescriptionCell:cell atIndexPath:indexPath];
			
		} else {
			
			ShopItemDetailPurchaseCell *detailCell = (ShopItemDetailPurchaseCell *)cell;
			[self configurePurchaseCell:detailCell atIndexPath:indexPath];
		}
	}
}

- (void)configureDescriptionCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	[cell.textLabel setText:_product.productDescription];
	[cell.textLabel setFont:[UIFont productDescriptionFont]];
	[cell.textLabel setNumberOfLines:0];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)configurePurchaseCell:(ShopItemDetailPurchaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {

	[cell setDelegate:self];
	
	CGRect t = cell.titleLabel.frame;
	CGRect titleLabelFrame = CGRectMake(0.0f, t.origin.y, t.size.width, t.size.height);
	
	if (indexPath.row == 0) {
		
		titleLabelFrame.origin.x = kTitleLabelProductX;
		[cell.titleLabel setFont:[UIFont modelTitleFont]];
		[cell.titleLabel setShadowColor:[UIColor modelTitleShadowColor]];

		[cell setProduct:_product];
		
		[cell.iconView setHidden:NO];
		ImageCachingService *service = [[ImageCachingService alloc] init];
		UIImage *image = [service cachedImageAtPath:_product.imagePath];
		if (!image) {
			
			[service setDelegate:self];
			[service beginLoadingImageAtPath:_product.imagePath withUserData:indexPath];
			
		} else {
			
			[cell.iconView setImage:image];
		}
		

		[cell.titleLabel setText:_product.title];
		
		if (_product.subscriptions.count > 0) {
			
			[cell.buyButton setHidden:YES];
			
		} else {
			
			[cell.buyButton setHidden:NO];
			[cell.buyButton setTitle:_product.localizedPrice forState:UIControlStateNormal];
			
			[self setBuyButton:cell.buyButton enabledForProduct:_product];
		}
		
	} else {
		
		titleLabelFrame.origin.x = kTitleLabelSubscriptionX;
		
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"index == %d", indexPath.row - 1];
		Product *subscription = (Product *)[[_product.subscriptions filteredSetUsingPredicate:pred] anyObject];
		
		[cell setProduct:subscription];
		[cell.titleLabel setText:subscription.productDescription];
		[cell.titleLabel setFont:[UIFont subscriptionTitleFont]];
		[cell.titleLabel setShadowColor:[UIColor subscriptionTitleShadowColor]];
		[cell.iconView setHidden:YES];
		[cell.buyButton setHidden:NO];
		[cell.buyButton setTitle:subscription.localizedPrice forState:UIControlStateNormal];
		
		[self setBuyButton:cell.buyButton enabledForProduct:subscription];
	}
	
	[cell.titleLabel setFrame:titleLabelFrame];
}

- (void)setBuyButton:(BuyButton *)buyButton enabledForProduct:(Product *)aProduct {
	
	BOOL isButtonEnabled = [PurchaseRulesService shouldEnableBuyButtonForProduct:aProduct];
	[buyButton setEnabled:isButtonEnabled];
	if (!isButtonEnabled) {
		
		NSString *disabled = [buyButton titleForState:UIControlStateDisabled];
		[buyButton.titleLabel setFont:[UIFont buyButtonDisabledFont]];
		[buyButton resizeToLeft:disabled nextText:disabled animated:NO];
		
	} else {
		
		[buyButton.titleLabel setFont:[UIFont buyButtonFont]];
	}
}

@end
