//
//  OperationViewController.m
//  KKB
//
//  Created by Can Yaman on 9/11/13.
//  Copyright (c) 2013 Valensas. All rights reserved.
//

#import "VLTableViewController.h"
#import "DejalActivityView.h"
#import "UIView+VLPropertyBinding.h"
#import "UITableViewCell+contentData.h"
#import <objc/runtime.h>


static void *operationIsFinished = &operationIsFinished;


@interface VLTableViewController ()

@property (nonatomic) BOOL coverNavBar;
@property (nonatomic) NSUInteger labelWidth;
@property (nonatomic) NSTimer *timeoutTimer;

@end


@implementation VLTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)setOperation:(NSOperation *)operation{
    if (_operation) {
        [_operation removeObserver:self forKeyPath:@"state"];
    }
    _operation=operation;
    if (operation) {
        [self displayActivityView:nil];
        [operation addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:operationIsFinished];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.coverNavBar=TRUE;
    if (self.operation!=nil) {
        if (![[self.operation valueForKey:@"state"] isEqualToValue:@3]) {
            [self performSelector:@selector(displayActivityView:) withObject:nil afterDelay:0.1];
        }
    }
}
-(void)viewDidAppear:(BOOL)animated{
    if (IOS6) {
        self.tableView.contentSize = CGSizeMake(self.tableView.frame.size.width, self.tableView.contentSize.height);
    }
    [super viewDidAppear:animated];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (IOS6) {
        self.tableView.contentSize = CGSizeMake(self.tableView.frame.size.width, self.tableView.contentSize.height);
    }
}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
-(void)viewWillDisappear:(BOOL)animated{
    [self removeActivityViewWithAnimation:NO];
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated;
{
    if (self.timeoutTimer) {
        [self.timeoutTimer invalidate];
        self.timeoutTimer=nil;
    }
	[super viewDidDisappear:animated];
}

- (void)displayActivityView:(NSString *)label;
{
    UIView *viewToUse = self.view;
    
    // Perhaps not the best way to find a suitable view to cover the navigation bar as well as the content?
    if (self.coverNavBar)
        viewToUse = self.navigationController.navigationBar.superview;
    
    if (!label)
    {
        // Display the appropriate activity style, with custom label text.  The width can be omitted or zero to use the text's width:
        [DejalBezelActivityView activityViewForView:viewToUse withLabel:label width:self.labelWidth];
    }
    else
    {
        // Display the appropriate activity style, with the default "Loading..." text:
        [DejalBezelActivityView activityViewForView:viewToUse];
    }
    
    // If this is YES, the network activity indicator in the status bar is shown, and automatically hidden when the activity view is removed.  This property can be toggled on and off as needed:
    [DejalActivityView currentActivityView].showNetworkActivityIndicator = YES;
    self.timeoutTimer=[NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(activityViewTimeout:) userInfo:nil repeats:FALSE];
    [[NSRunLoop mainRunLoop] addTimer:self.timeoutTimer forMode:NSRunLoopCommonModes];
}

- (void)changeActivityView:(NSString *)label;
{
    // Change the label text for the currently displayed activity view:
    [DejalActivityView currentActivityView].activityLabel.text = label;
    
    // Disable the network activity indicator in the status bar, e.g. after downloading data and starting parsing it (don't have to disable it if simply removing the view):
    [DejalActivityView currentActivityView].showNetworkActivityIndicator = NO;
    
}
- (void)activityViewTimeout:(NSTimer *)timer{
    [self removeActivityViewWithAnimation:FALSE];
}

- (void)removeActivityViewWithAnimation:(BOOL)animation;
{
    // Remove the activity view, with animation for the two styles that support it:
    [DejalActivityView currentActivityView].showNetworkActivityIndicator = NO;
    [DejalBezelActivityView removeViewAnimated:animation];
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    if (self.timeoutTimer) {
        [self.timeoutTimer invalidate];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //always remove ActivityView when operation is finished with whatever result failed or succeeded
    if (context == operationIsFinished) {
        //3 is state of the operation state as finished
        NSOperation *op=object;
        if(op.isFinished){
            [self removeActivityViewWithAnimation:YES];
        }
//        if ([[change valueForKey:@"new"] isEqualToValue:@3]) {
//            [self removeActivityView];
//        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
-(void)dealloc{
    self.operation=nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    if ([self isDynamicCell:indexPath]) {
        UITableViewCell *sectionPrototypeCell=[self tableView:tableView prototypeCellForIndexPath:indexPath];
        NSString *cellIdentifier=sectionPrototypeCell.reuseIdentifier;
        if (!cellIdentifier) {
            cellIdentifier=@"Cell";
        }
        NSArray *sectionArray=[self tableDataOfSection:[indexPath section]];
        if ((sectionArray.count==0)&&(self.data)&&(indexPath.row==0)) {
            cellIdentifier=@"NoDataCell";
            cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            return cell;
        }
        cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        //if not reused
        if (cell.contentView.subviews.count==0) {
            //clone prototype cell
            cell=[sectionPrototypeCell cloneView];
        }
        id cellData=[self cellDataForIndexPath:indexPath];
        [cell bindWithObject:cellData];
        cell.contentData=cellData;
    }else{
        cell=[super tableView:tableView cellForRowAtIndexPath:indexPath];
        [cell bindWithObject:self.data];
    }
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numOfRow=0;
    NSArray *sectionData=[self tableDataOfSection:section];
    if (!sectionData) {
        //static cell section of NSArray data type
        numOfRow = [super tableView:self.tableView numberOfRowsInSection:section];
    }else{
        //dynamic cell section
        numOfRow = sectionData.count;
        if ((numOfRow==0)&&(self.data)&&([tableView dequeueReusableCellWithIdentifier:@"NoDataCell"])){
            numOfRow=1;
        }
    }
    return numOfRow;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self isDynamicCell:indexPath]) {
        NSIndexPath *genericIndexPath=[NSIndexPath indexPathForRow:0 inSection:indexPath.section];
        return [super tableView:tableView heightForRowAtIndexPath:genericIndexPath];
    }else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}
-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self isDynamicCell:indexPath]) {
        NSIndexPath *genericIndexPath=[NSIndexPath indexPathForRow:0 inSection:indexPath.section];
        return [super tableView:tableView indentationLevelForRowAtIndexPath:genericIndexPath];
    }else{
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

-(id)getInstanceVariable:(id) x  name:(NSString *) s
{
    Ivar ivar = class_getInstanceVariable([x class], [s UTF8String]);
    return object_getIvar(x, ivar);
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSArray *segues=[self getInstanceVariable:self name:@"_storyboardSegueTemplates"];
//    NSDictionary *externals=[self getInstanceVariable:self name:@"_externalObjectsTableForViewLoading"];
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    
//    for (UIView *view in [c subviews]) {
//        if ([view isKindOfClass:[UITextField class]]) {
//            UITextField *textView=(UITextField *)view;
//            if (textView) {
//                [textView becomeFirstResponder];
//            }
//            break;
//            
//        }
//    }
    self.selectedCell=cell;
    self.selectedIndex=indexPath;
    [cell setSelected:FALSE];
    //
    
    UITextField *textField=[self textFieldOfParentView:cell];
    if (textField) {
        [textField becomeFirstResponder];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];
    }else{
        [self.view endEditing:YES];
        
    }
    if (cell.segueIdentifier) {
        if ([self shouldPerformSegueWithIdentifier:cell.segueIdentifier sender:cell]) {
            [self  performSegueWithIdentifier:cell.segueIdentifier sender:cell];
        }
    }
}
-(UITextField *)textFieldOfParentView:(UIView *)parentView{
    for (UIView *view in [parentView subviews]) {
        if ([view isKindOfClass:[UITextField class]]) {
            return (UITextField *)view;
        }else{
            UITextField *result=[self textFieldOfParentView:view];
            if (result) {
                return result;
            }
        }
    }
    return nil;
}
-(void)textFieldBecomeFirstReponder:(UIView *)parentView{
    UIView *text=[self textFieldOfParentView:parentView];
    if (text) {
        [text becomeFirstResponder];
    }
}
-(BOOL)parentView:(UIView *)parentView containsView:(UIView *)childView{
    for (UIView *view in [parentView subviews]) {
        if (view == childView) {
            return YES;
        }else{
            if([self parentView:view containsView:childView]){
                return YES;
            }
        }
    }
    return NO;
}
-(UITableViewCell *)parentCell:(UIView *)view{
    if ([view superview]) {
        if ([view.superview isKindOfClass:[UITableViewCell class]]) {
            return (UITableViewCell *)view.superview;
        }else{
            return [self parentCell:view.superview];
        }
    }
    return nil;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.selectedCell) {
        if(![self parentView:self.selectedCell containsView:textField]){
            self.selectedCell=[self parentCell:textField];
            self.selectedIndex=[self.tableView indexPathForCell:self.selectedCell];
        }
    }else{
        self.selectedCell=[self parentCell:textField];
        self.selectedIndex=[self.tableView indexPathForCell:self.selectedCell];
    }
    [self.tableView scrollToRowAtIndexPath:self.selectedIndex
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    return YES;
}      // called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSIndexPath *nextIndexPath=nil;
    if (self.selectedIndex) {
        if ([self tableView:self.tableView numberOfRowsInSection:self.selectedIndex.section] > self.selectedIndex.row+1) {
            nextIndexPath=[NSIndexPath indexPathForRow:self.selectedIndex.row+1 inSection:self.selectedIndex.section];
            [self tableView:self.tableView didSelectRowAtIndexPath:nextIndexPath];

        } else if (([self numberOfSectionsInTableView:self.tableView]>self.selectedIndex.section+1)
                   &&[self tableView:self.tableView numberOfRowsInSection:self.selectedIndex.section+1] > 0){
            nextIndexPath=[NSIndexPath indexPathForRow:0 inSection:self.selectedIndex.section+1];
            [self tableView:self.tableView didSelectRowAtIndexPath:nextIndexPath];
            
        }
    }
    
    return YES;
}
//
//-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
//    NSString *selectorName=[NSString stringWithFormat:@"willPerform%@:",identifier];
//    SEL segueSelector=NSSelectorFromString(selectorName);
//    if ([self respondsToSelector:segueSelector]) {
//        //sysnchronious operation action
//        [self performSelector:segueSelector withObject:sender];
//        return NO;
//    }else{
//        return YES;
//    }
//}
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    NSString *selectorName=[NSString stringWithFormat:@"didPerform%@:sender:",segue.identifier];
//    SEL prepareSegueSelector=NSSelectorFromString(selectorName);
//    if ([self respondsToSelector:prepareSegueSelector]) {
//        [self performSelector:prepareSegueSelector withObject:segue withObject:sender];
//    }else{
//        [super prepareForSegue:segue sender:sender];
//    }
//}

-(void)setData:(id)data{
    _data=data;
    
    //if static table view
//    if (![self respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
//        for ( UIView *subview in [self.tableView subviews] ) {
//            [subview bindWithObject:data];
//        }
//    }
    if ([data isKindOfClass:[NSArray class]]) {
        //This is dynamic simple 1 section table view
        self.sectionsKeyPath=[NSMutableDictionary dictionaryWithObject:@"self" forKey:[NSNumber numberWithInteger:0]];
    }else{
        self.sectionsKeyPath=[self.tableView sectionData];
    }
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
}
-(BOOL)isDynamicCell:(NSIndexPath *)indexPath{
    if ([self.sectionsKeyPath objectForKey:[NSNumber numberWithInteger:indexPath.section]]) {
        return YES;
    }
    return NO;
}

-(UITableViewCell *)tableView:(UITableView *)tableView prototypeCellForIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
}
-(void)tableView:(UITableView *)tableView registerPrototypeCellAtSection:(NSInteger)section{
    UITableViewCell *sectionPrototypeCell=[self tableView:tableView prototypeCellForIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    [tableView registerClass:[sectionPrototypeCell class] forCellReuseIdentifier:sectionPrototypeCell.reuseIdentifier];
}
-(NSArray *)tableDataOfSection:(NSInteger)section{
    NSString *sectionKeyPath= [self.sectionsKeyPath objectForKey:[NSNumber numberWithInteger:section]];
    if (sectionKeyPath) {
        NSArray *array=[self.data valueForKeyPath:sectionKeyPath];
        if (array) {
            return  array;
        }else{
            return [NSArray array];
        }
    }
    return nil;
}
-(id)cellDataForIndexPath:(NSIndexPath *)indexPath{
    NSArray *sectionArray=[self tableDataOfSection:[indexPath section]];
    if (sectionArray) {
        return [sectionArray objectAtIndex:indexPath.row];
    }else{
        return sectionArray;
    }
}
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    NSString *selectorName=[NSString stringWithFormat:@"willPerform%@:",identifier];
    SEL segueSelector=NSSelectorFromString(selectorName);
    if ([self respondsToSelector:segueSelector]) {
        //sysnchronious operation action
        [self performSelector:segueSelector withObject:sender];
        return NO;
    }else{
        return YES;
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSString *selectorName=[NSString stringWithFormat:@"didPerform%@:sender:",segue.identifier];
    SEL prepareSegueSelector=NSSelectorFromString(selectorName);
    //if sender has contentData and target view controller has data property set this authomatically
    if ([segue.destinationViewController respondsToSelector:@selector(setData:)]) {
        if ([sender respondsToSelector:@selector(contentData)]) {
            [segue.destinationViewController setData:[sender contentData]];
        }
    }
    if ([self respondsToSelector:prepareSegueSelector]) {
        [self performSelector:prepareSegueSelector withObject:segue withObject:sender];
    }else{
        [super prepareForSegue:segue sender:sender];
    }
}
- (IBAction)dismiss:(id)sender{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
