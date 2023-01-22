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
    
    NSString *description = [self _fd_descriptionForClassName:NSStringFromClass(self.class)
                                           classMethodsString:classMethodsString
                                        classPropertiesString:classPropertiesString
                                     instancePropertiesString:instancePropertiesString
                                        instanceMethodsString:instanceMethodsString];
    
    if (self.superclass) {
        return [NSString stringWithFormat:@"%@\n%@\n(%@ ...)", [self _fd_headerDescriptionForClass:self.class], description, self.superclass];
    } else {
        return description;
    }
}

- (NSString *)_fd_methodDescription {
    return [self _fd__methodDescriptionForClass:self.class];
}

- (NSString *)_fd__methodDescriptionForClass:(Class)arg1 {
    Class loopClass = arg1;
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"%@\n", [self _fd_headerDescriptionForClass:arg1]];
    
    while (loopClass) {
        NSString * _Nullable classMethodsString = [self _fd_methodsStringForClass:object_getClass(loopClass) isClassType:YES];
        NSString * _Nullable classPropertiesString = [self _fd_propertiesStringForClass:object_getClass(loopClass) isClassType:YES];
        NSString * _Nullable instancePropertiesString = [self _fd_propertiesStringForClass:loopClass isClassType:NO];
        NSString * _Nullable instanceMethodsString = [self _fd_methodsStringForClass:loopClass isClassType:NO];
        
        NSString *description = [self _fd_descriptionForClassName:NSStringFromClass(loopClass)
                                               classMethodsString:classMethodsString
                                            classPropertiesString:classPropertiesString
                                         instancePropertiesString:instancePropertiesString
                                            instanceMethodsString:instanceMethodsString];
        
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
    NSMutableString *result = [NSMutableString stringWithFormat:@"%@\n", [self _fd_headerDescriptionForClass:arg1]];
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

- (NSString *)_fd_ivarDescription {
    return [self _fd__ivarDescriptionForClass:self.class];
}

- (NSString *)_fd__ivarDescriptionForClass:(Class)arg1 {
    return @"TODO";
}

- (NSString *)_fd__protocolDescriptionForProtocol:(Protocol *)arg1 {
    NSMutableString *result = [NSMutableString stringWithFormat:@"<%@: %p>", NSStringFromProtocol(arg1), arg1];
    
    //
    
    unsigned int *protocolsCount = new unsigned int;
    Protocol * __unsafe_unretained _Nonnull *protocols = protocol_copyProtocolList(arg1, protocolsCount);
    
    if (protocolsCount) {
        [result appendString:@" ("];
        
        for (unsigned int protocolIndex = 0; protocolIndex < *protocolsCount; protocolIndex++) {
            Protocol *protocol = protocols[protocolIndex];
            const char *protocolName = protocol_getName(protocol);
            [result appendFormat:@"%s", protocolName];
            
            if (protocolIndex < (*protocolsCount - 1)) {
                [result appendString:@", "];
            }
        }
        
        [result appendString:@")"];
    }
    
    delete protocolsCount;
    delete protocols;
    
    [result appendString:@" :"];
    
    //
    
    unsigned int *requiredClassMethodDescriptionsCount = new unsigned int;
    objc_method_description *requiredClassMethodDescriptions = protocol_copyMethodDescriptionList(arg1, YES, NO, requiredClassMethodDescriptionsCount);
    NSString * _Nullable requiredClassMethodDescriptionsString = [self _fd_methodsStringFromMethodDescriptions:requiredClassMethodDescriptions count:*requiredClassMethodDescriptionsCount isClassType:YES];
    delete requiredClassMethodDescriptionsCount;
    delete requiredClassMethodDescriptions;
    
    unsigned int *optionalClassMethodDescriptionsCount = new unsigned int;
    objc_method_description *optionalClassMethodDescriptions = protocol_copyMethodDescriptionList(arg1, NO, NO, optionalClassMethodDescriptionsCount);
    NSString * _Nullable optionalClassMethodDescriptionsString = [self _fd_methodsStringFromMethodDescriptions:optionalClassMethodDescriptions count:*optionalClassMethodDescriptionsCount isClassType:YES];
    delete optionalClassMethodDescriptionsCount;
    delete optionalClassMethodDescriptions;
    
    NSString * _Nullable classMethodsString;
    if (requiredClassMethodDescriptionsString && optionalClassMethodDescriptionsString) {
        classMethodsString = [NSString stringWithFormat:@"%@\n%@", requiredClassMethodDescriptionsString, optionalClassMethodDescriptionsString];
    } else if (requiredClassMethodDescriptionsString) {
        classMethodsString = requiredClassMethodDescriptionsString;
    } else if (optionalClassMethodDescriptionsString) {
        classMethodsString = optionalClassMethodDescriptionsString;
    } else {
        classMethodsString = nil;
    }
    
    //
    
    unsigned int *requiredClassPropertiesCount = new unsigned int;
    objc_property_t *requiredClassProperties = protocol_copyPropertyList2(arg1, requiredClassPropertiesCount, YES, NO);
    NSString * _Nullable requiredClassPropertiesString = [self _fd_propertiesStringFromProperties:requiredClassProperties count:*requiredClassPropertiesCount isClassType:YES isOptionalType:NO];
    delete requiredClassPropertiesCount;
    delete requiredClassProperties;
    
    unsigned int *optionalClassPropertiesCount = new unsigned int;
    objc_property_t *optionalClassProperties = protocol_copyPropertyList2(arg1, optionalClassPropertiesCount, NO, NO);
    NSString * _Nullable optionalClassPropertiesString = [self _fd_propertiesStringFromProperties:optionalClassProperties count:*optionalClassPropertiesCount isClassType:YES isOptionalType:YES];
    delete optionalClassPropertiesCount;
    delete optionalClassProperties;
    
    NSString * _Nullable classPropertiesString;
    if (requiredClassPropertiesString && optionalClassPropertiesString) {
        classPropertiesString = [NSString stringWithFormat:@"%@\n%@", requiredClassPropertiesString, optionalClassPropertiesString];
    } else if (requiredClassPropertiesString) {
        classPropertiesString = requiredClassPropertiesString;
    } else if (optionalClassPropertiesString) {
        classPropertiesString = optionalClassPropertiesString;
    } else {
        classPropertiesString = nil;
    }
    
    //
    
    unsigned int *requiredInstancePropertiesCount = new unsigned int;
    objc_property_t *requiredInstanceProperties = protocol_copyPropertyList2(arg1, requiredInstancePropertiesCount, YES, YES);
    NSString * _Nullable requiredInstancePropertiesString = [self _fd_propertiesStringFromProperties:requiredInstanceProperties count:*requiredInstancePropertiesCount isClassType:NO isOptionalType:NO];
    delete requiredInstancePropertiesCount;
    delete requiredInstanceProperties;
    
    unsigned int *optionalInstancePropertiesCount = new unsigned int;
    objc_property_t *optionalInstanceProperties = protocol_copyPropertyList2(arg1, optionalInstancePropertiesCount, NO, YES);
    NSString * _Nullable optionalInstancePropertiesString = [self _fd_propertiesStringFromProperties:optionalInstanceProperties count:*optionalInstancePropertiesCount isClassType:NO isOptionalType:YES];
    delete optionalInstancePropertiesCount;
    delete optionalInstanceProperties;
    
    NSString * _Nullable intancePropertiesString = nil;
    if (requiredInstancePropertiesString && optionalInstancePropertiesString) {
        intancePropertiesString = [NSString stringWithFormat:@"%@\n%@", requiredInstancePropertiesString, optionalInstancePropertiesString];
    } else if (requiredInstancePropertiesString) {
        intancePropertiesString = requiredInstancePropertiesString;
    } else if (optionalInstancePropertiesString) {
        intancePropertiesString = optionalInstancePropertiesString;
    }

    //
    
    unsigned int *requiredInstanceMethodDescriptionsCount = new unsigned int;
    objc_method_description *requiredInstanceMethodDescriptions = protocol_copyMethodDescriptionList(arg1, YES, YES, requiredInstanceMethodDescriptionsCount);
    NSString * _Nullable requiredInstanceMethodDescriptionsString = [self _fd_methodsStringFromMethodDescriptions:requiredInstanceMethodDescriptions count:*requiredInstanceMethodDescriptionsCount isClassType:NO];
    delete requiredInstanceMethodDescriptionsCount;
    delete requiredInstanceMethodDescriptions;
    
    unsigned int *optionalInstanceMethodDescriptionsCount = new unsigned int;
    objc_method_description *optionalInstanceMethodDescriptions = protocol_copyMethodDescriptionList(arg1, NO, YES, optionalInstanceMethodDescriptionsCount);
    NSString * _Nullable optionalInstanceMethodDescriptionsString = [self _fd_methodsStringFromMethodDescriptions:optionalInstanceMethodDescriptions count:*optionalInstanceMethodDescriptionsCount isClassType:NO];
    delete optionalInstanceMethodDescriptionsCount;
    delete optionalInstanceMethodDescriptions;
    
    NSString * _Nullable instanceMethodsString;
    if (requiredInstanceMethodDescriptionsString && optionalInstanceMethodDescriptionsString) {
        instanceMethodsString = [NSString stringWithFormat:@"%@\n%@", requiredInstanceMethodDescriptionsString, optionalInstanceMethodDescriptionsString];
    } else if (requiredInstanceMethodDescriptionsString) {
        instanceMethodsString = requiredInstanceMethodDescriptionsString;
    } else if (optionalInstanceMethodDescriptionsString) {
        instanceMethodsString = optionalInstanceMethodDescriptionsString;
    } else {
        instanceMethodsString = nil;
    }

    //
    
    NSString *description = [self _fd_descriptionForClassName:NSStringFromProtocol(arg1)
                                           classMethodsString:classMethodsString
                                        classPropertiesString:classPropertiesString
                                     instancePropertiesString:intancePropertiesString
                                        instanceMethodsString:instanceMethodsString];
    
    [result appendFormat:@"\n\n%@", description];

    return [result copy];
}

#pragma mark - Helpers

- (NSString * _Nullable)_fd_methodsStringForClass:(Class)arg1 isClassType:(BOOL)isClassType {
    unsigned int *methodsCount = new unsigned int;
    Method *methods = class_copyMethodList(arg1, methodsCount);
    
    NSString * _Nullable result = [self _fd_methodsStringFromMethods:methods count:*methodsCount isClassType:isClassType];
    
    delete methodsCount;
    delete methods;
    
    return result;
}

- (NSString * _Nullable)_fd_methodsStringFromMethods:(Method *)methods count:(unsigned int)count isClassType:(BOOL)isClassType {
    NSString *prefix = isClassType ? @"+" : @"-";
    NSMutableString *results = [NSMutableString string];
    
    for (unsigned int methodIndex = 0; methodIndex < count; methodIndex++) {
        @autoreleasepool {
            Method method = methods[methodIndex];
            IMP imp = method_getImplementation(method);
            
            NSString *name = NSStringFromSelector(method_getName(method));
            
            char *returnType_char = new char[256];
            method_getReturnType(methods[methodIndex], returnType_char, 256);
            NSString *returnType = [self _fd_decodedTypeFromEncodedType:returnType_char];
            delete[] returnType_char;
            
            NSMutableArray<NSString *> *arguments = [NSMutableArray<NSString *> array];
            for (unsigned int argumentIndex = 0; argumentIndex < method_getNumberOfArguments(method); argumentIndex++) {
                char *argument_char = new char[256];
                method_getArgumentType(methods[methodIndex], argumentIndex, argument_char, 256);
                [arguments addObject:[self _fd_decodedTypeFromEncodedType:argument_char]];
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
            
            if (methodIndex < (count - 1)) {
                [results appendString:@"\n"];
            }
        }
    }
    
    return [results copy];
}

- (NSString * _Nullable)_fd_methodsStringFromMethodDescriptions:(objc_method_description *)methodDescriptions count:(unsigned int)count isClassType:(BOOL)isClassType {
    if (count == 0) return nil;
    
    NSString *prefix = isClassType ? @"+" : @"-";
    NSMutableString *results = [NSMutableString string];
    
    for (unsigned int methodDescriptionIndex = 0; methodDescriptionIndex < count; methodDescriptionIndex++) {
        @autoreleasepool {
            objc_method_description methodDescription = methodDescriptions[methodDescriptionIndex];
            
            NSString *name = [NSString stringWithCString:sel_getName(methodDescription.name) encoding:NSUTF8StringEncoding];
            NSArray<NSString *> *arguments = [self _fd_decodedTypesFromEncodedTypes:methodDescription.types];
            
            NSString *returnType = arguments[0];
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
            
            [result appendString:@";"];
            [results appendString:result];
            
            if (methodDescriptionIndex < (count - 1)) {
                [results appendString:@"\n"];
            }
        }
        
    }
    
    return [results copy];
}

- (NSString * _Nullable)_fd_propertiesStringForClass:(Class)arg1 isClassType:(BOOL)isClassType {
    unsigned int *propertiesCount = new unsigned int;
    objc_property_t *properties = class_copyPropertyList(arg1, propertiesCount);
    
    NSString * _Nullable result = [self _fd_propertiesStringFromProperties:properties count:*propertiesCount isClassType:isClassType isOptionalType:NO];
    
    delete propertiesCount;
    delete properties;
    
    return result;
}

- (NSString * _Nullable)_fd_propertiesStringFromProperties:(objc_property_t *)properties count:(unsigned int)count isClassType:(BOOL)isClassType isOptionalType:(BOOL)isOptionalType {
    if (count == 0) return nil;
    NSMutableString *results = [NSMutableString string];
    
    for (unsigned int propertyIndex = 0; propertyIndex < count; propertyIndex++) {
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
                    typeName = [self _fd_decodedTypeFromEncodedType:attribute.value];
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
            
            [results appendString:@"\t\t"];
            
            if (isOptionalType) {
                [results appendString:@"@optional"];
            }
            
            if (attributeNames.count) {
                [results appendFormat:@"@property (%@) %@ %@;", [attributeNames componentsJoinedByString:@", "], typeName, name];
            } else {
                [results appendFormat:@"@property %@ %@;", typeName, name];
            }
            
            if (isDynamic) {
                [results appendFormat:@"  (@dynamic %@;)", name];
            }
            
            if (propertyIndex < (count - 1)) {
                [results appendString:@"\n"];
            }
        }
    }
    
    return [results copy];
}

- (NSString *)_fd_decodedTypeFromEncodedType:(const char *)encodedType {
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
        return [NSString stringWithFormat:@"%@*", [self _fd_decodedTypeFromEncodedType:encodedType + 1]];
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
        return [NSString stringWithFormat:@"const %@", [self _fd_decodedTypeFromEncodedType:encodedType + 1]];
    } else if (strncmp("V", encodedType, 1) == 0) {
        return [NSString stringWithFormat:@"oneway %@", [self _fd_decodedTypeFromEncodedType:encodedType + 1]];
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
            
            return [self _fd_decodedTypeFromEncodedType:splited];
        }
    } else {
        return [NSString stringWithCString:encodedType encoding:NSUTF8StringEncoding];
    }
}

- (NSArray<NSString *> *)_fd_decodedTypesFromEncodedTypes:(const char *)encodedTypes {
    NSMutableArray<NSString *> *results = [NSMutableArray<NSString *> array];
    
    unsigned int startIndex = 0;
    
    for (unsigned int index = 0; index < strlen(encodedTypes); index++) {
        if (isdigit(static_cast<int>(encodedTypes[index]))) {
            if (startIndex == 0) continue;
            
            size_t size = index - startIndex;
            char *encodedType = new char[size];
            strncpy(encodedType, &encodedTypes[startIndex], size);
            [results addObject:[self _fd_decodedTypeFromEncodedType:encodedType]];
            delete[] encodedType;
            
            startIndex = 0;
        } else {
            if (startIndex == 0) {
                startIndex = index;
            }
        }
    }
    
    return [results copy];
}

- (NSString *)_fd_headerDescriptionForClass:(Class)arg1 {
    unsigned int *protocolsCount = new unsigned int;
    Protocol * __unsafe_unretained _Nonnull *protocols = class_copyProtocolList(arg1, protocolsCount);
    
    if (protocolsCount) {
        NSMutableArray<NSString *> *protocolNames = [NSMutableArray<NSString *> array];
        
        for (unsigned int protocolIndex = 0; protocolIndex < *protocolsCount; protocolIndex++) {
            Protocol *protocol = protocols[protocolIndex];
            const char *protocolName = protocol_getName(protocol);
            [protocolNames addObject:[NSString stringWithCString:protocolName encoding:NSUTF8StringEncoding]];
        }
        
        delete protocolsCount;
        delete protocols;
        
        return [NSString stringWithFormat:@"<%@: %p> (%@):\n", NSStringFromClass(arg1), arg1, [protocolNames componentsJoinedByString:@", "]];
    } else {
        delete protocolsCount;
        delete protocols;
        
        return [NSString stringWithFormat:@"<%@: %p>:\n", NSStringFromClass(arg1), arg1];
    }
}

- (NSString *)_fd_descriptionForClassName:(NSString *)className classMethodsString:(NSString * _Nullable)classMethodsString classPropertiesString:(NSString * _Nullable)classPropertiesString instancePropertiesString:(NSString *)instancePropertiesString instanceMethodsString:(NSString *)instanceMethodsString {
    NSMutableString *result = [NSMutableString stringWithFormat:@"in %@:", className];
    
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
