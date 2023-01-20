//
//  NSObject+Foundation_IvarDescription.m
//  IvarDescription
//
//  Created by Jinwoo Kim on 1/17/23.
//

#import "NSObject+Foundation_IvarDescription.h"
#import <objc/runtime.h>
#import <string>

@implementation NSObject (Foundation_IvarDescription)

- (NSString *)_fd_shortMethodDescription {
    NSString *classMethods = [self _fd_classMethodsForClass:self.class];
    NSString *instanceMethods = [self _fd_instanceMethodsForClass:self.class];
    NSLog(@"%@", [self _fd_propertiesForClass:self.class]);
    
    NSString *result = [NSString stringWithFormat:@"\
<%@: %p>:\n\
in %@:\n\
\tClass Methods::\n\
%@\n\
\tInstance Methods:\n\
%@\
", self, self, self, classMethods, instanceMethods];
    
    if (self.superclass) {
        return [NSString stringWithFormat:@"%@\n(%@ ...)", result, self.superclass];
    } else {
        return result;
    }
}

#pragma mark - Helpers

- (NSString *)_fd_classMethodsForClass:(Class)arg1 {
    return [self _fd_methodsForClass:object_getClass(arg1) prefix:@"+"];
}

- (NSString *)_fd_instanceMethodsForClass:(Class)arg1 {
    return [self _fd_methodsForClass:arg1 prefix:@"-"];
}

- (NSString *)_fd_methodsForClass:(Class)arg1 prefix:(NSString *)prefix {
    unsigned int *methodsCount = new unsigned int;
    Method *methods = class_copyMethodList(arg1, methodsCount);
    
    NSMutableString *results = [NSMutableString new];
    
    for (unsigned int methodIndex = 0; methodIndex < *methodsCount; methodIndex++) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        
        Method method = methods[methodIndex];
        IMP imp = method_getImplementation(method);
        
        NSString *name = NSStringFromSelector(method_getName(method));
        
        char *returnType_char = new char[256];
        method_getReturnType(methods[methodIndex], returnType_char, 256);
        NSString *returnType = [self _fd_decodeType:returnType_char];
        delete[] returnType_char;
        
        NSMutableArray<NSString *> *arguments = [NSMutableArray<NSString *> array];
        for (unsigned int argumentIndex = 0; argumentIndex < method_getNumberOfArguments(method); argumentIndex++) {
            char *argument_char = new char[256];
            method_getArgumentType(methods[methodIndex], argumentIndex, argument_char, 256);
            [arguments addObject:[self _fd_decodeType:argument_char]];
            delete[] argument_char;
        }
        
        NSMutableString *result = [NSMutableString stringWithFormat:@"\t\t%@ (%@)", prefix, returnType];
        
        if (arguments.count == 2) {
            [result appendFormat:@" %@", name];
        } else {
            [[name componentsSeparatedByString:@":"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.length == 0) {
                    *stop = YES;
                    return;
                }
                
                [result appendFormat:@" %@:(%@)arg%lu", obj, arguments[idx + 2], idx + 1];
            }];
        }
        
        [result appendFormat:@"; (%p)", imp];
        [results appendString:result];
        
        if (methodIndex < (*methodsCount - 1)) {
            [results appendString:@"\n"];
        }
        
        [pool release];
    }
    
    delete methodsCount;
    delete methods;
    
    NSString *copy = [results copy];
    [results release];
    
    return [copy autorelease];
}

- (NSString *)_fd_propertiesForClass:(Class)arg1 {
    unsigned int *propertiesCount = new unsigned int;
    objc_property_t *properties = class_copyPropertyList(arg1, propertiesCount);
    
    NSMutableString *results = [NSMutableString new];
    
    for (unsigned int propertyIndex = 0; propertyIndex < *propertiesCount; propertyIndex++) {
        objc_property_t property = properties[propertyIndex];
        
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        unsigned int *attributesCount = new unsigned int;
        objc_property_attribute_t *attributes = property_copyAttributeList(property, attributesCount);
        
        NSMutableArray<NSString *> *attributeNames = [NSMutableArray<NSString *> new];
        NSString * __autoreleasing _Nullable typeName = nil;
        NSString * __autoreleasing _Nullable dynamicName = nil;
        
        for (unsigned int attributeIndex = 0; attributeIndex < *attributesCount; attributeIndex++) {
            objc_property_attribute_t attribute = attributes[attributeIndex];
            
            // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101
            if (strcmp(attribute.name, "T") == 0) {
                typeName = [self _fd_decodeType:attribute.value];
            } else if (strcmp(attribute.name, "R") == 0) {
                [attributeNames addObject:@"readonly"];
            } else if (strcmp(attribute.name, "C") == 0) {
                [attributeNames addObject:@"copy"];
            } else if (strcmp(attribute.name, "&") == 0) {
                [attributeNames addObject:@"retain"];
            } else if (strcmp(attribute.name, "N") == 0) {
                [attributeNames addObject:@"nonatomic"];
            } else if (strcmp(attribute.name, "G") == 0) {
                NSString *getterName = [NSString stringWithCString:attribute.value encoding:NSUTF8StringEncoding];
                [attributeNames addObject:[NSString stringWithFormat:@"getter=%@", getterName]];
            } else if (strcmp(attribute.name, "S") == 0) {
                NSString *setterName = [NSString stringWithCString:attribute.value encoding:NSUTF8StringEncoding];
                [attributeNames addObject:[NSString stringWithFormat:@"setter=%@", setterName]];
            }
        }
        
        if (name == nil) {
            name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        }
        
        if (attributeNames.count) {
            [results appendFormat:@"\t\t@property (%@) %@ %@;", [attributeNames componentsJoinedByString:@", "], typeName, name];
        } else {
            [results appendFormat:@"\t\t@property %@ %@;", typeName, name];
        }
        
        if (propertyIndex < (*propertiesCount - 1)) {
            [results appendString:@"\n"];
        }
        
        [attributeNames release];
        delete attributesCount;
        delete attributes;
    }
    
    delete propertiesCount;
    delete properties;
    
    NSString *copy = [results copy];
    [results release];
    
    return [copy autorelease];
}

- (NSString *)_fd_decodeType:(const char *)encodedType {
    // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    if (strcmp(encodedType, @encode(char)) == 0) {
        return @"char";
    } else if (strcmp(encodedType, @encode(int)) == 0) {
        return @"int";
    } else if (strcmp(encodedType, @encode(short)) == 0) {
        return @"short";
    } else if (strcmp(encodedType, @encode(long)) == 0) {
        return @"long";
    } else if (strcmp(encodedType, @encode(long long)) == 0) {
        return @"long long";
    } else if (strcmp(encodedType, @encode(unsigned char)) == 0) {
        return @"unsigned char";
    } else if (strcmp(encodedType, @encode(unsigned int)) == 0) {
        return @"unsigned int";
    } else if (strcmp(encodedType, @encode(unsigned short)) == 0) {
        return @"unsigned short";
    } else if (strcmp(encodedType, @encode(unsigned long)) == 0) {
        return @"unsigned long";
    } else if (strcmp(encodedType, @encode(unsigned long long)) == 0) {
        return @"unsigned long long";
    } else if (strcmp(encodedType, @encode(float)) == 0) {
        return @"float";
    } else if (strcmp(encodedType, @encode(double)) == 0) {
        return @"double";
    } else if (strcmp(encodedType, @encode(_Bool)) == 0) {
        return @"_Bool";
    } else if (strcmp(encodedType, @encode(void)) == 0) {
        return @"void";
    } else if (strcmp(encodedType, @encode(char *)) == 0) {
        return @"char*";
    } else if (strcmp(encodedType, @encode(id)) == 0) {
        return @"id";
    } else if (strcmp(encodedType, @encode(Class)) == 0) {
        return @"Class";
    } else if (strcmp(encodedType, @encode(SEL)) == 0) {
        return @"SEL";
    } else if (strstr(encodedType, "{") && strstr(encodedType, "=") && strstr(encodedType, "}")) {
        NSString *string = [NSString stringWithCString:encodedType encoding:NSUTF8StringEncoding];
        NSRange startRange = [string rangeOfString:@"{"];
        NSRange endRange = [string rangeOfString:@"="];
        NSString *typeName = [string substringWithRange:NSMakeRange(startRange.location + startRange.length, endRange.location - (startRange.location + startRange.length))];
        
        return [NSString stringWithFormat:@"struct %@", typeName];
    } else if (strncmp("^", encodedType, 1) == 0) {
        char *token = strtok(const_cast<char *>(encodedType), "^");
        return [NSString stringWithFormat:@"%@*", [self _fd_decodeType:token]];
    } else if (strcmp(encodedType, "@?") == 0) {
        return @"^block";
    } else if (strstr(encodedType, "@") && strstr(encodedType, "\"") && strstr(encodedType, "\"")) {
        NSString *string = [NSString stringWithCString:encodedType encoding:NSUTF8StringEncoding];
        NSRange startRange = [string rangeOfString:@"\""];
        NSString *trimmedString = [string substringWithRange:NSMakeRange(startRange.location + startRange.length, string.length - (startRange.location + startRange.length))];
        NSRange endRange = [trimmedString rangeOfString:@"\""];
        NSString *typeName = [trimmedString substringWithRange:NSMakeRange(0, trimmedString.length - endRange.length)];
        
        return [NSString stringWithFormat:@"%@*", typeName];
    } else {
        NSLog(@"%s", encodedType);
        return [NSString stringWithCString:encodedType encoding:NSUTF8StringEncoding];
    }
}

@end
