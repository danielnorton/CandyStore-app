//
//  ShopItemDetailViewController.m
//  CandyStore
//
//  Created by Daniel Norton on 8/1/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "ShopItemDetailViewController.h"
#import "Style.h"
#import "TransactionReceiptService.h"
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


@interface ShopItemDetailViewController()

@property (nonatomic, retain) NSIndexPath *activeBuyButtonIndexPath;

- (BOOL)isLastRow:(int)row;
- (void)reloadVisibleCells;
- (void)configureDescriptionCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configurePurchaseCell:(ShopItemDetailPurchaseCell *)purchaseCell atIndexPath:(NSIndexPath *)indexPath;
- (void)setBuyButton:(BuyButton *)buyButton enabledForProduct:(Product *)product;

@end


@implementation ShopItemDetailViewController


@synthesize purchaseCell;
@synthesize product;
@synthesize activeBuyButtonIndexPath;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	
	[purchaseCell release];
	[activeBuyButtonIndexPath release];
	[super dealloc];
}


#pragma mark UIViewController
- (void)viewDidUnload {
	[super viewDidUnload];
	
	[self setPurchaseCell:nil];
	[self setActiveBuyButtonIndexPath:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.tableView setSeparatorColor:[UIColor shopTableSeperatorColor]];
	[self setTitle:product.title];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:TransactionReceiptServiceCompletedNotification
													  object:nil
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  
													  [self.navigationController.view setUserInteractionEnabled:YES];
													  [self.navigationController popToRootViewControllerAnimated:YES];
												  }];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:TransactionReceiptServiceFailedNotification
													  object:nil
													   queue:nil
												  usingBlock:^(NSNotification *notification) {
													  
													  SKPaymentTransaction *transaction = [[notification userInfo] objectForKey:TransactionReceiptServiceKeyTransaction];
													  if (transaction.error.code == -1001) {
														  
														  [self popup:transaction.error.localizedDescription];
													  }
													  
													  [self.navigationController.view setUserInteractionEnabled:YES];
													  [self.tableView reloadData];
												  }];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	int answer = 2;
	if (product.subscriptions.count > 0) {
		
		answer += product.subscriptions.count;
	}
	return answer;
}


#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	if ([self isLastRow:indexPath.row]) {
		
		static NSString *cellIdentifier = @"descriptionIdentifier";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		}
		
		[self configureDescriptionCell:cell atIndexPath:indexPath];
		
		return cell;
	}
	
	static NSString *cellIdentifier = @"shopItemDetailPurchaseCell";
    ShopItemDetailPurchaseCell *cell = (ShopItemDetailPurchaseCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {

		[[NSBundle mainBundle] loadNibNamed:@"ShopItemDetailPurchaseCell" owner:self options:nil];
        cell = purchaseCell;
		[self setPurchaseCell:nil];
    }
	
	[self configurePurchaseCell:cell atIndexPath:indexPath];
	
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0) {
	
		return kPurchaseCellHeight;
		
	} else if ([self isLastRow:indexPath.row]) {
	
		CGSize size = [product.productDescription sizeWithFont:[UIFont productDescriptionFont]
											 constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
												 lineBreakMode:UILineBreakModeWordWrap];
		
		float answer = size.height + kDescriptionPadding;
		return answer > kMinimumDescriptionHeight
		? answer
		: kMinimumDescriptionHeight;
	}
	
	return kSubscriptionCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (!activeBuyButtonIndexPath) return;
	
	ShopItemDetailPurchaseCell *cell = (ShopItemDetailPurchaseCell *)[tableView cellForRowAtIndexPath:activeBuyButtonIndexPath];
	[cell.buyButton setSelected:NO];
	[cell resizeTitleFromBuyButton];
	[self setActiveBuyButtonIndexPath:nil];
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
	}
	
	[self.navigationController.view setUserInteractionEnabled:NO];
	
	SKPayment *payment = [SKPayment paymentWithProductIdentifier:aProduct.identifier];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark -
#pragma mark ShopItemDetailViewController
#pragma mark Private Extension
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
	
	[cell.textLabel setText:product.productDescription];
	[cell.textLabel setFont:[UIFont productDescriptionFont]];
	[cell.textLabel setNumberOfLines:0];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)configurePurchaseCell:(ShopItemDetailPurchaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {

	[cell setDelegate:self];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	CGRect t = cell.titleLabel.frame;
	CGRect titleLabelFrame = CGRectMake(0.0f, t.origin.y, t.size.width, t.size.height);
	
	if (indexPath.row == 0) {
		
		titleLabelFrame.origin.x = kTitleLabelProductX;
		[cell.titleLabel setFont:[UIFont modelTitleFont]];
		[cell.titleLabel setShadowColor:[UIColor modelTitleShadowColor]];

		[cell setProduct:product];
		
		[cell.iconView setHidden:NO];
		ImageCachingService *service = [[ImageCachingService alloc] init];
		UIImage *image = [service cachedImageAtPath:product.imagePath];
		if (!image) {
			
			[service setDelegate:self];
			[service beginLoadingImageAtPath:product.imagePath withUserData:indexPath];
			
		} else {
			
			[cell.iconView setImage:image];
		}
		
		[service release];

		[cell.titleLabel setText:product.title];
		
		if (product.subscriptions.count > 0) {
			
			[cell.buyButton setHidden:YES];
			
		} else {
			
			[cell.buyButton setHidden:NO];
			[cell.buyButton setTitle:product.localizedPrice forState:UIControlStateNormal];
			
			[self setBuyButton:cell.buyButton enabledForProduct:product];
		}
		
	} else {
		
		titleLabelFrame.origin.x = kTitleLabelSubscriptionX;
		
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"index == %d", indexPath.row - 1];
		Product *subscription = (Product *)[[product.subscriptions filteredSetUsingPredicate:pred] anyObject];
		
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
		
		NSString *normal = [buyButton titleForState:UIControlStateNormal];
		NSString *disabled = [buyButton titleForState:UIControlStateDisabled];
		[buyButton.titleLabel setFont:[UIFont buyButtonDisabledFont]];
		[buyButton resizeToLeft:normal nextText:disabled animated:NO];
		
	} else {
		
		[buyButton.titleLabel setFont:[UIFont buyButtonFont]];
	}
}

@end
