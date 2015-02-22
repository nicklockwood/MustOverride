//
//  MustOverride.h
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

#import <Foundation/Foundation.h>

/**
 * Include this macro inside any class or instance method that MUST be overridden
 * by its subclass(es). The app will then crash immediately on launch with an
 * assertion if the method is not overridden (even if it is never called).
 */
#define SUBCLASS_MUST_OVERRIDE __attribute__((used, section("__DATA,MustOverride" \
))) static const char *__must_override_entry__ = __func__
