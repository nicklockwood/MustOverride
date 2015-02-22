//
//  MustOverride.m
//
//  Version 1.1
//
//  Created by Nick Lockwood on 22/02/2015.
//  Copyright (c) 2015 Nick Lockwood
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/MustOverride
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "MustOverride.h"

#if DEBUG

#import <dlfcn.h>
#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>

@interface MustOverride : NSObject

@end

#ifdef __LP64__
typedef uint64_t MustOverrideValue;
typedef struct section_64 MustOverrideSection;
#define GetSectByNameFromHeader getsectbynamefromheader_64
#else
typedef uint32_t MustOverrideValue;
typedef struct section MustOverrideSection;
#define GetSectByNameFromHeader getsectbynamefromheader
#endif

@implementation MustOverride

static BOOL ClassOverridesMethod(Class cls, SEL selector)
{
    unsigned int numberOfMethods;
    Method *methods = class_copyMethodList(cls, &numberOfMethods);
    for (unsigned int i = 0; i < numberOfMethods; i++)
    {
        if (method_getName(methods[i]) == selector)
        {
            free(methods);
            return YES;
        }
    }
    free(methods);
    return NO;
}

static NSArray *SubclassesOfClass(Class baseClass)
{
    static Class *classes;
    static unsigned int classCount;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      classes = objc_copyClassList(&classCount);
    });

    NSMutableArray *subclasses = [NSMutableArray array];
    for (unsigned int i = 0; i < classCount; i++)
    {
        Class cls = classes[i];
        Class superclass = cls;
        while (superclass)
        {
            if (superclass == baseClass)
            {
                [subclasses addObject:cls];
                break;
            }
            superclass = class_getSuperclass(superclass);
        }
    }
    return subclasses;
}

static void CheckOverrides(void)
{
    Dl_info info;
    dladdr((const void *)&CheckOverrides, &info);

    const MustOverrideValue mach_header = (MustOverrideValue)info.dli_fbase;
    const MustOverrideSection *section = GetSectByNameFromHeader((void *)mach_header, "__DATA", "MustOverride");
    if (section == NULL) return;

    NSMutableArray *failures = [NSMutableArray array];
    for (MustOverrideValue addr = section->offset; addr < section->offset + section->size; addr += sizeof(const char **))
    {
        NSString *entry = @(*(const char **)(mach_header + addr));
        NSArray *parts = [[entry substringWithRange:NSMakeRange(2, entry.length - 3)] componentsSeparatedByString:@" "];
        NSString *className = parts[0];
        NSRange categoryRange = [className rangeOfString:@"("];
        if (categoryRange.length)
        {
            className = [className substringToIndex:categoryRange.location];
        }

        BOOL isClassMethod = [entry characterAtIndex:0] == '+';
        Class cls = NSClassFromString(className);
        SEL selector = NSSelectorFromString(parts[1]);

        for (Class subclass in SubclassesOfClass(cls))
        {
            if (!ClassOverridesMethod(isClassMethod ? object_getClass(subclass) : subclass, selector))
            {
                [failures addObject:[NSString stringWithFormat:@"%@ does not implement required method %c%@",
                                     subclass, isClassMethod ? '+' : '-', parts[1]]];
            }
        }
    }

    NSCAssert(failures.count == 0, @"%@%@",
              failures.count > 1 ? [NSString stringWithFormat:@"%zd method override errors:\n", failures.count] : @"",
              [failures componentsJoinedByString:@"\n"]);
}

+ (void)load
{
    CheckOverrides();
}

@end

#endif
