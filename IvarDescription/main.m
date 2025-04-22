//
//  main.m
//  IvarDescription
//
//  Created by Jinwoo Kim on 1/15/23.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>
#import <objc/runtime.h>
#import "NSObject+Foundation_IvarDescription.h"

@protocol TestProtocol <NSObject, NSTabViewDelegate>
@optional @property (class, retain) id string;
@optional @property NSUInteger number;
@property NSUInteger number2;
- (id)foo;
+ (id)foo:(void)a1 a2:(long long)a2;
- (NSUInteger)foo2:(NSUInteger)a1 a2:(CGRect)a2 a3:(CGSize)a3;
@end

@interface TestObject : NSObject <NSStreamDelegate>
@property (class, weak) id<NSStreamDelegate> delegate;
@property (copy) NSNumber *number;
@property (assign, getter=isEnabled) BOOL enabled;
+ (oneway void)foo;
- (id)foo:(NSUInteger *)foo name:(NSString *)name error:(NSError * __autoreleasing * _Nullable)error;
@end

@implementation TestObject

+ (oneway void)foo {
    
}

- (id)foo:(NSUInteger *)foo name:(NSString *)name error:(NSError **)error {
    return nil;
}

@end

struct NextFlags {
    void *ptr;
};

struct MyFlags {
    unsigned int _id;
    unsigned int a : 20;
    BOOL enabled;
    NSString *text;
    struct NextFlags nf;
};

@interface MyObject : NSObject
//@property Class protoClass;
@property struct MyFlags flags;
@property NSString *text;
@property CGSize rect;
@property NSUInteger *ptr;
@property NSUInteger number;
@property (nonatomic, copy) NSUInteger (^blockName)(CGSize);
@end

@implementation MyObject
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        NSLog(@"%@", [NSObject _fd__methodDescriptionForClass:TestObject.class]);
//        NSLog(@"%@", [NSObject _fd__protocolDescriptionForProtocol:@protocol(TestProtocol)]);
        
//        NSLog(@"%@", [NSObject _fd__protocolDescriptionForProtocol:@protocol(TestProtocol)]);
//        MyObject *view = [MyObject new];
//        view.text = @"Test";
//        view.ptr = malloc(sizeof(NSUInteger));
//        view.blockName = ^NSUInteger(CGSize) {
//            return 3;
//        };
//        NSLog(@"%@", [view _fd_ivarDescription]);
//        view.protoClass = NSURL.class;
//        NSLog(@"%@", [view _fd_ivarDescription]);
//        free(view.ptr);
//        [view release];
        
        NSLog(@"%@", [NSObject _fd__ivarDescriptionForClass:(Class)NSClassFromString(@"PFCloudKitStoreComparer")]);
    }
    return 0;
}
