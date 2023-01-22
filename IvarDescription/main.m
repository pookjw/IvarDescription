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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        NSLog(@"%@", [NSString _fd_shortMethodDescription]);
        NSLog(@"%@", [NSObject _fd__protocolDescriptionForProtocol:@protocol(TestProtocol)]);
    }
    return 0;
}
