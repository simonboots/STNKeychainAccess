STNKeychainAccess README
=========================

Created by Simon Stiefel on 29.11.06.
Copyright 2006 Simon Stiefel. All rights reserved.

$Id$

Redistribution and use in source and binary forms, with or
without modification, are permitted provided that the
following conditions are met:

1. Redistributions of source code must retain the above
copyright notice, this list of conditions and the following
disclaimer.

2. Redistributions in binary form must reproduce the above
copyright notice, this list of conditions and the following
disclaimer in the documentation and/or other materials
provided with the distribution.

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOTLIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


About
-----
STNKeychainAccess is a class which provides basic access to the Mac OS X keychain.
It currently only supports generic passwords.
For updates and more information visit http://www.stiefels.net.


Installation
------------
There is no real installation since this class is just an ordinary .m file with corresponding .h header file.
To use it, simply add those two files to your Xcode project and do an '#import "STNKeychainAccess.h"' on
every file you want to have keychain access.

Usage
-----
Keychain entries are identified by a service name and an account name. Both can be set at the instantiation
of the object.

    Example:
        STNKeychainAccess *kc = [[STNKeychainAccess alloc] initWithServiceName:@"myServiceName"
                                                                   accountName:@"myAccountName"];

If you want to change these parameters later you can do a standard init and use setServiceName: and setAccountName:.

    Example:
        STNKeychainAccess *kc = [[STNKeychainAccess alloc] init];
        [kc setServiceName:@"myServiceName"];
        [kc setAccountName:@"myAccountName"];
        
To fetch the currently used service and account name you can use serviceName: and accountName:.

    Example:
        NSString *accountName, *serviceName;
        serviceName = [kc serviceName];
        accountName = [kc accountName];
        
Please note that the returned NSString object will be autoreleased in the next run loop. So, if you want to keep them,
you have to retain them.

To save a generic password simply use the savePassword: method. This method also updates the password if there is
already one set.

    Example:
        OSStatus rv;
        rv = [kc savePassword:@"mySecretPassword"];
        if (rv != noErr) {
            NSLog(@"Error while saving/updating password!");
        }
        
For more information about the return values read http://developer.apple.com/documentation/Security/Reference/keychainservices/Reference/reference.html.

Fetching the stored password is done using the getPassword:itemReference: method. The first parameter is a pointer to
a NSString object pointer. The second parameter is a pointer to the item of the generic password. Pass nil if you don't
want to use it.

    Example:
        OSStatus rv;
        NSString *password;
        rv = [kc getPassword:&password itemReference:nil];
        if (rv != noErr) {
            NSLog(@"Error while fetching password!");
        }
        
If you call this method and the password entry does not exist it will return the error code -25300.

A working example is included as Xcode project.
More information about the methods can be found in STNKeychainAccess.h.

