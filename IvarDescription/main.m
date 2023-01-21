//
//  main.m
//  IvarDescription
//
//  Created by Jinwoo Kim on 1/15/23.
//

#import <Cocoa/Cocoa.h>
#import "NSObject+Foundation_IvarDescription.h"

@interface TestObject : NSObject
@property (class, readonly) NSUInteger number;
- (oneway void)foo;
@end

@implementation TestObject

+ (NSUInteger)number {
    return 0;
}
- (oneway void)foo {
//    return @"";
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"%@", [NSString _fd__methodDescriptionForClass:NSAttributedString.class]);
    }
    return 0;
}
