# Foundation_IvarDescription

Backporting `NSObject(IvarDescription)` category which is bundled in UIKit. Written in Objective-C++ with supporting ARC/MRC.

- [NSObject+Foundation_IvarDescription.h](IvarDescription/NSObject+Foundation_IvarDescription.h)
- [NSObject+Foundation_IvarDescription.mm](IvarDescription/NSObject+Foundation_IvarDescription.mm)

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

Briefly speaking: I'll explain about `-[NSObject(IvarDescription) _shortMethodDescription]`. Let's define the sample object like below:

```objc
@interface TestObject : NSObject <NSStreamDelegate>
@property (class, weak) id<NSStreamDelegate> delegate;
@property (copy) NSNumber *number;
@property (assign, getter=isEnabled) BOOL enabled;
+ (oneway void)foo;
- (id)foo:(NSUInteger *)foo name:(NSString *)name error:(NSError * __autoreleasing * _Nullable)error;
@end
```

Here's the result of `[TestObject _shortMethodDescription]`. It dumps all property and methods declarations, including all private declarations. Also it gives address of `IMP` - it is useful when you are setting breakpoints based on address or dumping assembly.

```
(lldb) expression -l objc -O -- [TestObject _shortMethodDescription]
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

Again, it's bundled in UIKit. If you are handling non-UIKit projects like Cocoa or Linux envrionments, you cannot use these cool tools. To use these I have to backport using [Objective-C Runtime](https://developer.apple.com/documentation/objectivec/objective-c_runtime).

OK, Enough.

## Limitations

- All specifications of [Type Encodings](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html) are not supported. (e.g. `An array`, `A union` types are not implemented yet.)

- Objects eligible for GCC are not supported. (It's 2023... is it needed?)

- Dumping data layouts for struct type is not implemented yet. `IvarDescription` supports dumping struct type restrictively, but I want to implement perferctly soon.

## Usages

My `Foundation_IvarDescriptions` provides 8 methods - dumping methods/properties/ivars description. Also it supports dumping Objective-C Protocols which is not supported in `IvarDescriptions`!

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

Backport of `-[NSObject(IvarDescription) _shortMethodDescription]`. Only dumps class itself, excluding subclasses.

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

Backport of `-[NSObject(IvarDescription) _methodDescription]`. It dumps descriptions of class itself and subclasses.

- Dumping Conformance of Procotols.

- Dumping Class/Instance Properties.

- Dumping Class/Instance Methods.

- Dumping `IMP` addresses.

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

### `_fd__methodDescriptionForClass:`

Backport of `-[NSObject(IvarDescription) _methodDescriptionForClass:]`. It dumps descriptions of input class and subclasses.

- Dumping Conformance of Procotols.

- Dumping Class/Instance Properties.

- Dumping Class/Instance Methods.

- Dumping `IMP` addresses.

```
(lldb) expression -l objc -O -- [NSObject _fd__methodDescriptionForClass:TestObject.class]
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

### `_fd_propertyDescription`

Backport of `-[NSObject(IvarDescription) _propertyDescription]`. It dumps properties of class itself and subclasses.

```
(lldb) expression -l objc -O -- [TestObject _fd_propertyDescription]
<TestObject: 0x10000c8e8> (NSStreamDelegate):


in TestObject:
    Properties:
        @property (class, weak) <NSStreamDelegate>* delegate;
        @property (copy) NSNumber* number;
        @property (getter=isEnabled) _Bool enabled;
        @property (readonly) unsigned long hash;
        @property (readonly) Class superclass;
        @property (readonly, copy) NSString* description;
        @property (readonly, copy) NSString* debugDescription;

in NSObject:
    Properties:
        @property (class, readonly) _Bool accessInstanceVariablesDirectly;
        @property (readonly, copy) NSClassDescription* classDescription;
        @property (readonly, copy) NSArray* attributeKeys;
        @property (readonly, copy) NSArray* toOneRelationshipKeys;
        @property (readonly, copy) NSArray* toManyRelationshipKeys;
        @property void* observationInfo;
        @property (readonly) Class classForKeyedArchiver;
        @property (readonly, retain) id autoContentAccessingProxy;
        @property (copy) NSDictionary* scriptingProperties;
        @property (readonly) unsigned int classCode;
        @property (readonly, copy) NSString* className;
        @property (readonly) unsigned long hash;
        @property (readonly) Class superclass;
        @property (readonly, copy) NSString* description;
        @property (readonly, copy) NSString* debugDescription;
```

### `_fd__propertyDescriptionForClass:`

Backport of `-[NSObject(IvarDescription) __propertyDescriptionForClass:]`. It dumps properties of input class and subclasses.

```
(lldb) expression -l objc -O -- [NSObject _fd__propertyDescriptionForClass:[TestObject class]]
<TestObject: 0x10000c8e8> (NSStreamDelegate):


in TestObject:
    Properties:
        @property (class, weak) <NSStreamDelegate>* delegate;
        @property (copy) NSNumber* number;
        @property (getter=isEnabled) _Bool enabled;
        @property (readonly) unsigned long hash;
        @property (readonly) Class superclass;
        @property (readonly, copy) NSString* description;
        @property (readonly, copy) NSString* debugDescription;

in NSObject:
    Properties:
        @property (class, readonly) _Bool accessInstanceVariablesDirectly;
        @property (readonly, copy) NSClassDescription* classDescription;
        @property (readonly, copy) NSArray* attributeKeys;
        @property (readonly, copy) NSArray* toOneRelationshipKeys;
        @property (readonly, copy) NSArray* toManyRelationshipKeys;
        @property void* observationInfo;
        @property (readonly) Class classForKeyedArchiver;
        @property (readonly, retain) id autoContentAccessingProxy;
        @property (copy) NSDictionary* scriptingProperties;
        @property (readonly) unsigned int classCode;
        @property (readonly, copy) NSString* className;
        @property (readonly) unsigned long hash;
        @property (readonly) Class superclass;
        @property (readonly, copy) NSString* description;
        @property (readonly, copy) NSString* debugDescription;
```

### `_fd_ivarDescription`

Backport of `-[NSObject(IvarDescription) _fd_ivarDescription]`. It dumps ivar descriptions of class itself and subclasses.

```
(lldb) expression -l objc -O -- [TestObject new]
<TestObject: 0x600000204300>

(lldb) expression -l objc -O -- [0x600000204300 _fd_ivarDescription]
<TestObject: 0x600000204300>:

in TestObject:
    _enabled <0x600000204308> (_Bool): NO
    _number <0x600000204310> (NSNumber*): (null)
in NSObject:
    isa <0x600000204300> (Class): TestObject
```

### `_fd__ivarDescriptionForClass:`

Backport of `-[NSObject(IvarDescription) __ivarDescriptionForClass:]`. It dumps ivar descriptions of input class only.

```
(lldb) expression -l objc -O -- [0x600000204300 _fd__ivarDescriptionForClass:[TestObject class]]
in TestObject:
    _enabled <0x600000204308> (_Bool): NO
    _number <0x600000204310> (NSNumber*): (null)
```

### `_fd__protocolDescriptionForProtocol:`

It dumps descriptions of input protocol. It cannot distinguish between required and optional methods because of bug of [`protocol_copyMethodDescriptionList`](https://developer.apple.com/documentation/objectivec/1418822-protocol_copymethoddescriptionli).

- Dumping Conformance of Procotols.

- Dumping Class/Instance Properties.

- Dumping Class/Instance Methods.

Define the sample protocol like below:

```objc
@protocol TestProtocol <NSObject, NSTabViewDelegate>
@optional @property (class, retain) id string;
@optional @property NSUInteger number;
@property NSUInteger number2;
- (id)foo;
+ (id)foo:(void)a1 a2:(long long)a2;
- (NSUInteger)foo2:(NSUInteger)a1 a2:(CGRect)a2 a3:(CGSize)a3;
@end
```

Here's the output of dumping `TestProtocol` with `_fd__ivarDescriptionForClass:`:

```
<TestProtocol: 0x10000ccb0> (NSObject, NSTabViewDelegate) :

in TestProtocol:
    Class Methods:
        + (id) foo:(void)arg1 a2:(long)arg2;
        + (id) string;
        + (id) setString:(id)arg1;
    Properties:
        @property (class, retain) id string;
        @property unsigned long number;
        @property unsigned long number2;
    Instance Methods:
        - (id) foo2:(unsigned long)arg1 a2:(struct CGRect)arg2 a3:(struct CGSize)arg3;
        - (id) number2;
        - (id) setNumber2:(unsigned long)arg1;
        - (id) number;
        - (id) setNumber:(unsigned long)arg1;
        - (id) foo;
```
