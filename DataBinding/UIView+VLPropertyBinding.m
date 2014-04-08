#import "UIView+VLPropertyBinding.h"
#import <objc/runtime.h>
#import "VLTableViewController.h"

static void * const BindedObjectsDictKey = (void*)&BindedObjectsDictKey;
static NSString *BindMapConst=@"BindMapConst";
static void * const BindedObject = (void*)&BindedObject;

static void * const SegueIdentifierKey = (void*)&SegueIdentifierKey;
static NSString *SegueIdentifier=@"SegueIdentifier";

static void * const SectionDictKey = (void*)&SectionDictKey;
static NSString *SectionDict=@"SectionDict";

static NSString * const BindKey = @"bind";
static NSString * const SegueKey = @"performSegue";
static NSString * const SectionDataKey =@"section";

@implementation UIView (VLPropertyBinding)


#pragma mark - Overrides
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL encoderSelector = @selector(encodeWithCoder:);
        SEL decoderSelector =  @selector(initWithCoder:);
        
        SEL afterEncoderSelector = @selector(afterEncodeWithCoder:);
        SEL afterDecoderSelector =  @selector(afterInitWithCoder:);
        
        Method originalEncoderMethod = class_getInstanceMethod(self, encoderSelector);
        Method originalDecoderMethod = class_getInstanceMethod(self, decoderSelector);
        
        Method newEncoderMethod = class_getInstanceMethod(self, afterEncoderSelector);
        Method newDecoderMethod = class_getInstanceMethod(self, afterDecoderSelector);
        
        method_exchangeImplementations(originalEncoderMethod, newEncoderMethod);
        method_exchangeImplementations(originalDecoderMethod, newDecoderMethod);

    });
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    //only the keys stated with bind keyword
    if ([key hasPrefix:BindKey]) {
        // see if the UndefinedObjects dictionary exists, if not, create it
        
        //remove bind prefix key
        NSString *noPrefixKey=[key substringFromIndex:BindKey.length];
        //lower case first char of the bindable property
        //ex: bindText => obj.self peroperty
        NSString *bindablePropertyKey=[noPrefixKey stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[noPrefixKey substringToIndex:1] lowercaseString]];
        
        NSMutableDictionary *bindDict = nil;
        if ( objc_getAssociatedObject(self, BindedObjectsDictKey) ) {
            bindDict = objc_getAssociatedObject(self, BindedObjectsDictKey);
        }
        else {
            bindDict = [[NSMutableDictionary alloc] init];
            objc_setAssociatedObject(self, BindedObjectsDictKey, bindDict, OBJC_ASSOCIATION_RETAIN);
        }
        //check property already exist
        
        if ([self respondsToSelector:NSSelectorFromString(bindablePropertyKey)]) {
            [bindDict setValue:bindablePropertyKey forKey:value];//keyPath - property map
        }else{
            NSString *boolPropertyName=[NSString stringWithFormat:@"is%@",noPrefixKey];
            if ([self respondsToSelector:NSSelectorFromString(boolPropertyName)]) {
                [bindDict setValue:bindablePropertyKey forKey:value];//keyPath - property map
            }else{
                NSLog(@"Missing propery of :%@ for keyPath:%@",self,key);
            }
        }
    }else if([key isEqualToString:SegueKey]){
        self.segueIdentifier=value;
    }else if([key hasPrefix:SectionDataKey]){
        NSString *sectionNo=[key substringFromIndex:SectionDataKey.length];
        NSInteger section=[sectionNo integerValue];
        
        NSMutableDictionary *sectionDict = nil;
        if ( objc_getAssociatedObject(self, SectionDictKey) ) {
            sectionDict = objc_getAssociatedObject(self, SectionDictKey);
        }
        else {
            sectionDict = [[NSMutableDictionary alloc] init];
            objc_setAssociatedObject(self, SectionDictKey, sectionDict, OBJC_ASSOCIATION_RETAIN);
        }
        
        [sectionDict setObject:value forKey:[NSNumber numberWithInteger:section]];
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    
    NSMutableDictionary *undefinedDict = nil;
    if ( objc_getAssociatedObject(self, BindedObjectsDictKey) ) {
        undefinedDict = objc_getAssociatedObject(self, BindedObjectsDictKey);
        return [undefinedDict valueForKey:key];
    }
    else {
        return nil;
    }
}

#pragma mark - Public Methods

- (void)bindWithObject:(id)obj {
    
    // first check ourselves for any bindable properties. Then process our
    // children.
    NSDictionary *bindableKeyPaths = [self bindKeyPaths];
    
    
    if ( bindableKeyPaths ) {
        //check
        BOOL __block binded=false;
        [bindableKeyPaths enumerateKeysAndObjectsUsingBlock:^(id keyPath, id property, BOOL *stop) {
            //check that target keypath exist and not nil
            id val=[obj valueForKeyPath:keyPath];
            if (val) {
                [self setObject:val forProperty:property];
                binded=true;
            }
        }];
        if (binded) {
            objc_setAssociatedObject(self, BindedObject, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    //don't bind dynamic cells
    for ( UIView *subview in [self subviews] ) {
        if(([subview isKindOfClass:[UITableViewCell class]])&&([(UITableViewCell *)subview reuseIdentifier])){
            //NSLog(@"Cell with reuse identifier not binded");
        }else{
            [subview bindWithObject:obj];
        }
    }
}
#pragma mark - Private Methods
- (NSDictionary *)bindKeyPaths {
    if ( objc_getAssociatedObject(self, BindedObjectsDictKey) ) {
        NSDictionary *bindDict = objc_getAssociatedObject(self, BindedObjectsDictKey);
        return bindDict;
    }
    else {
        return nil;
    }
}

- (void)setBindKeyPath:(NSDictionary *)bindKeyPaths {
    objc_setAssociatedObject(self, BindedObjectsDictKey, bindKeyPaths, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)segueIdentifier{
    if ( objc_getAssociatedObject(self, SegueIdentifierKey) ) {
        NSString *segueId = objc_getAssociatedObject(self, SegueIdentifierKey);
        return segueId;
    }
    else {
        return nil;
    }
}

- (void)setSegueIdentifier:(NSString *)segueIdentifier {
    objc_setAssociatedObject(self, SegueIdentifierKey, segueIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)bindedKeyPathOfProperty:(NSString *)propertyKeyPath{
    return [[self bindKeyPaths] objectForKey:propertyKeyPath];
}

-(instancetype)cloneView{
    NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:self];
    UIView *clonedView = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
    return clonedView;
}
#pragma mark NSCoding
- (void)afterEncodeWithCoder:(NSCoder *)aCoder{
    [self afterEncodeWithCoder:aCoder];
    NSDictionary *bindMap=[self bindKeyPaths];
    if (bindMap) {
        [aCoder encodeObject:bindMap forKey:BindMapConst];
    }
    NSString *segueId=[self segueIdentifier];
    if (segueId) {
        [aCoder encodeObject:segueId forKey:SegueIdentifier];
    }
}

-(id)afterInitWithCoder:(NSCoder *)aDecoder{
    id obj=[self afterInitWithCoder:aDecoder];
    NSDictionary *bindMap=[aDecoder decodeObjectForKey:BindMapConst];
    if (bindMap) {
        [obj setBindKeyPath:bindMap];
    }
    NSString *segue=[aDecoder decodeObjectForKey:SegueIdentifier];
    if (segue) {
        [obj setSegueIdentifier:segue];
    }
    return obj;
}

-(void)setObject:(id)object forProperty:(NSString *)propretyName{
    //get property type
    id val=nil;
    id targetObj=[self valueForKey:propretyName];
    if(![object isKindOfClass:[targetObj class]]){
        if(([targetObj isKindOfClass:[NSString class]])&&
           ([object respondsToSelector:@selector(stringValue)])){
            val=[object stringValue];
        }else
        if([targetObj isKindOfClass:[NSNumber class]]){
            if(object==nil){
                targetObj=[NSNumber numberWithBool:false];
            }else if ([object isKindOfClass:[NSString class]]){
                targetObj=[[NSNumberFormatter new] numberFromString:object];
            }
        }else{
            val=object;
        }
    }else{
        val=object;
    }
    if(val){
        [self setValue:val forKey:propretyName];
    }else{
        //NSLog(@"VLPropertyBinding nil for peroperty:%@",propretyName);
    }
}

-(void)setShown:(BOOL)show{
    [self setHidden:!show];
}
-(BOOL)isShown{
    return !self.isHidden;
}
@end

@implementation UITableView (DataBinding)
-(id)data{
    return nil;
}
-(void)setData:(NSArray *)data{
    UIViewController *controller=(UIViewController *)self.dataSource;
    [controller setValue:data forKey:@"data"];
}
-(BOOL)isHeaderShown{
    return YES;
}
-(void)setHeaderShown:(BOOL)shown{
    if(!shown){
        [self setTableHeaderView:nil];
    }
}
-(NSMutableDictionary *)sectionData{
    return  objc_getAssociatedObject(self, SectionDictKey);
}

@end
