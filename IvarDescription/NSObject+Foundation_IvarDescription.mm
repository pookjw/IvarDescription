//
//  NSObject+Foundation_IvarDescription.m
//  IvarDescription
//
//  Created by Jinwoo Kim on 1/17/23.
//

#import "NSObject+Foundation_IvarDescription.h"
#import <objc/runtime.h>

@implementation NSObject (Foundation_IvarDescription)

- (NSString *)_fd_shortMethodDescription {
    NSString * _Nullable classMethodsString = [self _fd_methodsStringForClass:object_getClass(self.class) isClassType:YES];
    NSString * _Nullable classPropertiesString = [self _fd_propertiesStringForClass:object_getClass(self.class) isClassType:YES];
    NSString * _Nullable instancePropertiesString = [self _fd_propertiesStringForClass:self.class isClassType:NO];
    NSString * _Nullable instanceMethodsString = [self _fd_methodsStringForClass:self.class isClassType:NO];
    
    NSString *description = [self _fd_descriptionForClass:self.class
                                       classMethodsString:classMethodsString
                                    classPropertiesString:classPropertiesString
                                 instancePropertiesString:instancePropertiesString
                                    instanceMethodsString:instanceMethodsString];
    
    if (self.superclass) {
        return [NSString stringWithFormat:@"<%@: %p>:\n%@\n(%@ ...)", NSStringFromClass(self.class), self.class, description, self.superclass];
    } else {
        return description;
    }
}

- (NSString *)_fd_methodDescription {
    return [self _fd__methodDescriptionForClass:self.class];
}

- (NSString *)_fd__methodDescriptionForClass:(Class)arg1 {
    Class loopClass = arg1;
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"<%@: %p>:\n", arg1, arg1];
    
    while (loopClass) {
        NSString * _Nullable classMethods = [self _fd_methodsStringForClass:object_getClass(loopClass) isClassType:YES];
        NSString * _Nullable classProperties = [self _fd_propertiesStringForClass:object_getClass(loopClass) isClassType:YES];
        NSString * _Nullable instanceProperties = [self _fd_propertiesStringForClass:loopClass isClassType:NO];
        NSString * _Nullable instanceMethods = [self _fd_methodsStringForClass:loopClass isClassType:NO];
        
        NSString *description = [self _fd_descriptionForClass:loopClass
                                           classMethodsString:classMethods
                                        classPropertiesString:classProperties
                                     instancePropertiesString:instanceProperties
                                        instanceMethodsString:instanceMethods];
        
        [result appendString:description];
        
        loopClass = loopClass.superclass;
        
        if (loopClass) {
            [result appendString:@"\n"];
        }
    }
    
    return [result copy];
}

- (NSString *)_fd_propertyDescription {
    return [self _fd__propertyDescriptionForClass:self.class];
}

- (NSString *)_fd__propertyDescriptionForClass:(Class)arg1 {
    NSMutableString *result = [NSMutableString stringWithFormat:@"<%@: %p>:\n", arg1, arg1];
    Class loopClass = arg1;
    
    while (loopClass) {
        [result appendFormat:@"\nin %@:\n\tProperties:\n", loopClass];
        
        NSString * _Nullable classProperties = [self _fd_propertiesStringForClass:object_getClass(loopClass) isClassType:YES];
        NSString * _Nullable instanceProperties = [self _fd_propertiesStringForClass:loopClass isClassType:NO];
        
        if (classProperties) {
            [result appendFormat:@"%@\n", classProperties];
        }
        
        if (instanceProperties) {
            [result appendFormat:@"%@\n", instanceProperties];
        }
        
        loopClass = loopClass.superclass;
    }
    
    return [result copy];
}

#pragma mark - Helpers

- (NSString * _Nullable)_fd_methodsStringForClass:(Class)arg1 isClassType:(BOOL)isClassType {
    unsigned int *methodsCount = new unsigned int;
    Method *methods = class_copyMethodList(arg1, methodsCount);
    
    if (*methodsCount == 0) {
        delete methodsCount;
        return nil;
    }
    
    NSString *prefix = isClassType ? @"+" : @"-";
    NSMutableString *results = [NSMutableString string];
    
    for (unsigned int methodIndex = 0; methodIndex < *methodsCount; methodIndex++) {
        @autoreleasepool {
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
        }
    }
    
    delete methodsCount;
    delete methods;
    
    return [results copy];
}

- (NSString * _Nullable)_fd_propertiesStringForClass:(Class)arg1 isClassType:(BOOL)isClassType {
    unsigned int *propertiesCount = new unsigned int;
    objc_property_t *properties = class_copyPropertyList(arg1, propertiesCount);
    
    if (*propertiesCount == 0) {
        delete propertiesCount;
        return nil;
    }
    
    NSMutableString *results = [NSMutableString string];
    
    for (unsigned int propertyIndex = 0; propertyIndex < *propertiesCount; propertyIndex++) {
        @autoreleasepool {
            objc_property_t property = properties[propertyIndex];
            
            NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            
            unsigned int *attributesCount = new unsigned int;
            objc_property_attribute_t *attributes = property_copyAttributeList(property, attributesCount);
            
            NSMutableArray<NSString *> *attributeNames = [NSMutableArray<NSString *> array];
            
            if (isClassType) {
                [attributeNames addObject:@"class"];
            }
            
            NSString * __autoreleasing _Nullable typeName = nil;
            BOOL isDynamic = NO;
            
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
                } else if (strcmp(attribute.name, "D") == 0) {
                    isDynamic = YES;
                } else if (strcmp(attribute.name, "W") == 0) {
                    [attributeNames addObject:@"weak"];
                }
            }
            
            delete attributesCount;
            delete attributes;
            
            if (name == nil) {
                name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            }
            
            if (attributeNames.count) {
                [results appendFormat:@"\t\t@property (%@) %@ %@;", [attributeNames componentsJoinedByString:@", "], typeName, name];
            } else {
                [results appendFormat:@"\t\t@property %@ %@;", typeName, name];
            }
            
            if (isDynamic) {
                [results appendFormat:@"  (@dynamic %@;)", name];
            }
            
            if (propertyIndex < (*propertiesCount - 1)) {
                [results appendString:@"\n"];
            }
        }
    }
    
    delete propertiesCount;
    delete properties;
    
    return [results copy];
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
    } else if (strncmp("^", encodedType, 1) == 0) {
        return [NSString stringWithFormat:@"%@*", [self _fd_decodeType:encodedType + 1]];
    } else if (strcmp(encodedType, "@?") == 0) {
        return @"^block";
    } else if (strstr(encodedType, "@") && strstr(encodedType, "\"") && strstr(encodedType, "\"")) {
        NSString *string = [NSString stringWithCString:encodedType encoding:NSUTF8StringEncoding];
        NSRange startRange = [string rangeOfString:@"\""];
        NSString *trimmedString = [string substringWithRange:NSMakeRange(startRange.location + startRange.length, string.length - (startRange.location + startRange.length))];
        NSRange endRange = [trimmedString rangeOfString:@"\""];
        NSString *typeName = [trimmedString substringWithRange:NSMakeRange(0, trimmedString.length - endRange.length)];
        
        return [NSString stringWithFormat:@"%@*", typeName];
    } else if (strncmp("r", encodedType, 1) == 0) {
        return [NSString stringWithFormat:@"const %@", [self _fd_decodeType:encodedType + 1]];
    } else if (strncmp("V", encodedType, 1) == 0) {
        return [NSString stringWithFormat:@"oneway %@", [self _fd_decodeType:encodedType + 1]];
    } else if (strstr(encodedType, "{") && strstr(encodedType, "}")) {
        if (strstr(encodedType, "=")) {
            NSString *string = [NSString stringWithCString:encodedType encoding:NSUTF8StringEncoding];
            NSRange startRange = [string rangeOfString:@"{"];
            NSRange endRange = [string rangeOfString:@"="];
            NSString *typeName = [string substringWithRange:NSMakeRange(startRange.location + startRange.length, endRange.location - (startRange.location + startRange.length))];
            
            return [NSString stringWithFormat:@"struct %@", typeName];
        } else {
            size_t size = strlen(encodedType) - 2;
            char splited[size];
            strncpy(splited, (encodedType + 1), size);
            
            return [self _fd_decodeType:splited];
        }
    } else {
        return [NSString stringWithCString:encodedType encoding:NSUTF8StringEncoding];
    }
}

- (NSString *)_fd_descriptionForClass:(Class)arg1 classMethodsString:(NSString * _Nullable)classMethodsString classPropertiesString:(NSString * _Nullable)classPropertiesString instancePropertiesString:(NSString *)instancePropertiesString instanceMethodsString:(NSString *)instanceMethodsString {
    NSMutableString *result = [NSMutableString stringWithFormat:@"in %@:", NSStringFromClass(arg1)];
    
    if (classMethodsString) {
        [result appendFormat:@"\n\tClass Methods:\n%@", classMethodsString];
    }
    
    if (classPropertiesString) {
        [result appendFormat:@"\n\tProperties:\n%@", classPropertiesString];
    }
    
    if (instancePropertiesString) {
        if (classPropertiesString) {
            [result appendFormat:@"\n%@", instancePropertiesString];
        } else {
            [result appendFormat:@"\n\tProperties:\n%@", instancePropertiesString];
        }
    }
    
    if (instanceMethodsString) {
        [result appendFormat:@"\n\tInstance Methods:\n%@", instanceMethodsString];
    }
    
    return [result copy];
}

@end
