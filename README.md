# Foundation_IvarDescription

Backporting `-[NSObject(IvarDescription) *]` methods which are bundled in UIKit.

- [NSObject+Foundation_IvarDescription.h](IvarDescription/NSObject+Foundation_IvarDescription.h)
- [NSObject+Foundation_IvarDescription.m](IvarDescription/NSObject+Foundation_IvarDescription.m)

## Motivation

UIKit provides debugging methods in `IvarDescription` category by internally below:

```objc
@interface NSObject (IvarDescription)
- (id)_shortMethodDescription;
- (id)_methodDescription;
- (id)__methodDescriptionForClass:(Class)arg1;
- (id)_ivarDescription;
- (id)__ivarDescriptionForClass:(Class)arg1;
@end
```

Briefly speaking: I'll explain about `-[NSObject(IvarDescription) _shortMethodDescription]`. Let's define a sample object like below:

```objc
@interface TestObject : NSObject <NSStreamDelegate>
@property (class, weak) id<NSStreamDelegate> delegate;
@property (copy) NSNumber *number;
@property (assign, getter=isEnabled) BOOL enabled;
+ (oneway void)foo;
- (id)foo:(NSUInteger *)foo name:(NSString *)name error:(NSError * __autoreleasing * _Nullable)error;
@end
```

Here's the result of `[TestObject _shortMethodDescription];`. It dumps all property and methods declarations, including all private declarations. Also it gives address of `IMP` - it is useful when you are setting breakpoints based on address or dumping assembly.

```
<TestObject: 0x102619a10>:
in TestObject:
    Class Methods:
        + (void) foo; (0x1026114ac)
    Properties:
        @property (copy) NSNumber* number;  (@synthesize number = _number;)
        @property (getter=isEnabled) BOOL enabled;  (@synthesize enabled = _enabled;)
        @property (readonly) unsigned long hash;
        @property (readonly) Class superclass;
        @property (readonly, copy) NSString* description;
        @property (readonly, copy) NSString* debugDescription;
    Instance Methods:
        - (id) foo:(unsigned long*)arg1 name:(id)arg2 error:(id*)arg3; (0x1026114c0)
        - (id) number; (0x102611520)
        - (void) setNumber:(id)arg1; (0x102611548)
        - (BOOL) isEnabled; (0x102611580)
        - (void) setEnabled:(BOOL)arg1; (0x1026115a0)
        - (void) .cxx_destruct; (0x1026115c8)
(NSObject ...)
```

Again, it's bundled in UIKit. If you are handling non-UIKit projects like Cocoa or Linux envrionments, you cannot use these cool tools. To use these I have to backport these methods using [Objective-C Runtime](https://developer.apple.com/documentation/objectivec/objective-c_runtime).

OK, Enough.

## Limitations

- All specifications of [Type Encodings](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html) are not supported. `An array`, `A union` types are not implemented yet. 

- Objects eligible for GCC are not supported.

- Dumping data layouts for struct type is not implemented yet. `IvarDescription` supports dumping struct type restrictively.

## Usages

My `Foundation_IvarDescriptions` provides 7 methods - dumping methods/properties/ivars description. Also it supports dumping Objective-C Protocols which is not supported in `IvarDescriptions`!

```objc
@interface NSObject (Foundation_IvarDescription)
- (NSString *)_fd_shortMethodDescription;
- (NSString *)_fd_methodDescription;
- (NSString *)_fd__methodDescriptionForClass:(Class)arg1;
- (NSString *)_fd_propertyDescription;
- (NSString *)_fd__propertyDescriptionForClass:(Class)arg1;
- (NSString *)_fd_ivarDescription;
- (NSString *)_fd__ivarDescriptionForClass:(Class)arg1;
- (NSString *)_fd__protocolDescriptionForProtocol:(Protocol *)arg1;
@end
```

It's time to dive into `Foundation_IvarDescription`.

### `_fd_shortMethodDescription`

Backport of `-[NSObject(IvarDescription) _shortMethodDescription]`. It dumps 

- Dumping Conformance of Procotols.

- Dumping Class/Instance Properties.

- Dumping Class/Instance Methods.

- Dumping `IMP` addresses.

```
(lldb) expression -l objc -O -- [TestObject _fd_shortMethodDescription]
<TestObject: 0x10000c8e0> (NSStreamDelegate):

in TestObject:
    Class Methods:
        + (void) foo; (0x100003028)
    Properties:
        @property (class, weak) <NSStreamDelegate>* delegate;
        @property (copy) NSNumber* number;
        @property (getter=isEnabled) _Bool enabled;
        @property (readonly) unsigned long hash;
        @property (readonly) Class superclass;
        @property (readonly, copy) NSString* description;
        @property (readonly, copy) NSString* debugDescription;
    Instance Methods:
        - (id) foo:(unsigned long*)arg1 name:(id)arg2 error:(id*)arg3; (0x10000303c)
        - (id) number; (0x100003060)
        - (void) setNumber:(id)arg1; (0x100003088)
        - (_Bool) isEnabled; (0x1000030c0)
        - (void) setEnabled:(_Bool)arg1; (0x1000030e0)
(NSObject ...)
```

### `_fd_methodDescription`

Backport of `-[NSObject(IvarDescription) _methodDescription]`.

It dumps descriptions of subclasses.

```
(lldb) expression -l objc -O -- [TestObject _fd_methodDescription]
<TestObject: 0x10000c8e0> (NSStreamDelegate):

in TestObject:
    Class Methods:
        + (void) foo; (0x100003028)
    Properties:
        @property (class, weak) <NSStreamDelegate>* delegate;
        @property (copy) NSNumber* number;
        @property (getter=isEnabled) _Bool enabled;
        @property (readonly) unsigned long hash;
        @property (readonly) Class superclass;
        @property (readonly, copy) NSString* description;
        @property (readonly, copy) NSString* debugDescription;
    Instance Methods:
        - (id) foo:(unsigned long*)arg1 name:(id)arg2 error:(id*)arg3; (0x10000303c)
        - (id) number; (0x100003060)
        - (void) setNumber:(id)arg1; (0x100003088)
        - (_Bool) isEnabled; (0x1000030c0)
        - (void) setEnabled:(_Bool)arg1; (0x1000030e0)
in NSObject:
    Class Methods:
        + (void) load; (0x1a0d4be70)
        + (long) version; (0x1a0d54ae0)
        <omitted...>
    Properties:
        @property (class, readonly) _Bool accessInstanceVariablesDirectly;
        @property (readonly, copy) NSClassDescription* classDescription;
        <omitted...>
    Instance Methods:
        - (Class) classForCoder; (0x1a0d7858c)
        - (id) replacementObjectForCoder:(id)arg1; (0x1a0d67240)
        <omitted...>
```
