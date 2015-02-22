Purpose
--------------

MustOverride provides a macro that you can use to ensure that a method of an abstract base class *must* be overriden by its subclasses.

Apple does not currently provide a way to flag this at compile time, and the standard approach of raising an exception in the base class's implementation has two disadvantages: 1) it means that the method will only crash when it is called, which might only happen under difficult-to-reproduce conditions, and 2) you cannot provide a base implementation and require that the subclass calls super.

MustOverride uses some runtime magic to scan the class list at load time, and will crash *immediately* when the app is launched if the method is not implemented, even if it is never called.

Supported OS & SDK Versions
-----------------------------

* Supported build target - iOS 8.1 / Mac OS 10.10 (Xcode 6.1, Apple LLVM compiler 6.0)
* Earliest supported deployment target - iOS 7.0 / Mac OS 10.9
* Earliest compatible deployment target - iOS 4.3 / Mac OS 10.6

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this OS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

Works with or without ARC enabled.


Installation
--------------

To install MustOverride into your app, drag the MustOverride.h and .m files into your project. To use it, just import the MustOverride.h header file into any class, and then add the following macro inside the body of any method that must be overriden:

    SUBCLASS_MUST_OVERRIDE;
    
Like this:

    - (void)someMethod
    {
        SUBCLASS_MUST_OVERRIDE;
    }


Credits
--------------

Big thanks to Dan Tomlinson (@dantoml) for the inspiration, and Alex Akers (@a2) for the section data trick used to register the methods.


Release Notes
--------------

Version 1.1

- Now correctly detects methods that are defined in categories.
- Now reports all override errors, not just the first encountered.
- Fixed memory leak in ClassOverridesMethod.
- Performance optimization in SubclassesOfClass.
- Compliant with -Weverything warning level.
- Added Podspec.

Version 1.0

- Initial release.