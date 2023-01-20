//
//  main.m
//  IvarDescription
//
//  Created by Jinwoo Kim on 1/15/23.
//

#import <Cocoa/Cocoa.h>
#import "NSObject+Foundation_IvarDescription.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"%@", [NSView _fd_shortMethodDescription]);
//        char *id_encoded = @encode(id);
//        NSLog(@"%s", id_encoded);
//
//        char *bool_encoded = @encode(_Bool);
//        NSLog(@"%s", bool_encoded);
    }
    return 0;
}
