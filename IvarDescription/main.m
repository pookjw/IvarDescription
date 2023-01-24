//
//  main.m
//  IvarDescription
//
//  Created by Jinwoo Kim on 1/15/23.
//

#import <Cocoa/Cocoa.h>
#import "NSObject+Foundation_IvarDescription.h"

@protocol TestProtocol <NSObject, NSTabViewDelegate>
@optional @property (class, retain) id string;
@optional @property NSUInteger number;
@property NSUInteger number2;
- (id)foo;
+ (id)foo:(void)a1 a2:(long long)a2;
- (NSUInteger)foo2:(NSUInteger)a1 a2:(CGRect)a2 a3:(CGSize)a3;
@end

@interface TestObject : NSObject <TestProtocol>
@property NSUInteger number;
- (id)foo;
@end

@implementation TestObject

+ (id)string { return @""; }
+ (void)setString:(id)string {}

- (NSUInteger)number {
    return 0;
}
- (void)setNumber:(NSUInteger)number {
    
}
- (id)foo {
    return @"";
}

@end

struct NextFlags {
    void *ptr;
};

struct MyFlags {
    unsigned int _id;
    BOOL enabled;
    NSString *text;
    struct NextFlags nf;
};

@interface MyObject : NSObject
@property Class protoClass;
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
//        NSLog(@"%@", [NSString _fd_shortMethodDescription]);
//        NSLog(@"%@", [NSObject _fd__protocolDescriptionForProtocol:@protocol(TestProtocol)]);
        MyObject *view = [MyObject new];
        view.text = @"Test";
//        view.ptr = malloc(sizeof(NSUInteger));
//        view.blockName = ^NSUInteger(CGSize) {
//            return 3;
//        };
//        NSLog(@"%@", [view _fd__ivarDescriptionForClass:NSView.class]);
        view.protoClass = NSView.class;
        NSLog(@"%@", [view _fd_ivarDescription]);
//        free(view.ptr);
        [view release];
    }
    return 0;
}
