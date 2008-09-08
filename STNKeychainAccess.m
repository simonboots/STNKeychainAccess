//
//  STNKeychainAccess.m
//  STNKeychainAccess
//
//  Created by Simon Stiefel on 01.08.06.
//  Copyright 2006 Simon Stiefel. All rights reserved.
//
//  $Id$
//
//  Redistribution and use in source and binary forms, with or
//  without modification, are permitted provided that the
//  following conditions are met:
//
//  1. Redistributions of source code must retain the above
//  copyright notice, this list of conditions and the following
//  disclaimer.
//
//  2. Redistributions in binary form must reproduce the above
//  copyright notice, this list of conditions and the following
//  disclaimer in the documentation and/or other materials
//  provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOTLIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
//  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "STNKeychainAccess.h"
#import <Security/Security.h>


@implementation STNKeychainAccess

- (id)initWithServiceName:(NSString *)serviceName
              accountName:(NSString *)accountName
{
    self = [super init];
    if (self != nil) {
        [self setAccountName:accountName];
        [self setServiceName:serviceName];
    }
    return self;
}

- (id) init {
    return [self initWithServiceName:nil accountName:nil];
}

- (void)setServiceName:(NSString *)serviceName
{
    [_serviceName release];
    _serviceName = [serviceName copy];
}

- (NSString *)serviceName
{
    return _serviceName;
}

- (void)setAccountName:(NSString *)accountName
{
    [_accountName release];
    _accountName = [accountName copy];
}

- (NSString *)accountName
{
    return _accountName;
}

- (OSStatus)savePassword:(NSString *)password
{
    NSString *tempPassword = nil;
    SecKeychainItemRef itemRef;
    OSStatus status;
    
    // check if keychain entry already exists
    if ([self getPassword:&tempPassword
            itemReference:&itemRef] == noErr) {
        // entry exists - check if password differs
        if (! [tempPassword isEqualToString:password]) {
            
            // differs - change it
            SecKeychainAttribute attrs[] = {
            { kSecAccountItemAttr, [_accountName lengthOfBytesUsingEncoding:NSUTF8StringEncoding], [_accountName cStringUsingEncoding:NSUTF8StringEncoding] },
            { kSecServiceItemAttr, [_serviceName lengthOfBytesUsingEncoding:NSUTF8StringEncoding], [_serviceName cStringUsingEncoding:NSUTF8StringEncoding] } };
            
            const SecKeychainAttributeList attributes = { sizeof(attrs) / sizeof(attrs[0]), attrs };
            
            status = SecKeychainItemModifyAttributesAndData(itemRef,
                                                            &attributes,
                                                            [password lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                            [password cStringUsingEncoding:NSUTF8StringEncoding]);
            if (status != noErr) {
                NSLog(@"Error while updating keychain data: %d", status);
            }         
            return status;
        } else {
            // doesn't differ - all ok
            return noErr;
        }
    } else {
        // no entry - add it
        return SecKeychainAddGenericPassword(NULL,
                                             [_serviceName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                             [_serviceName cStringUsingEncoding:NSUTF8StringEncoding],
                                             [_accountName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                             [_accountName cStringUsingEncoding:NSUTF8StringEncoding],
                                             [password lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                             [password cStringUsingEncoding:NSUTF8StringEncoding],
                                             NULL);
    }
}

- (OSStatus)getPassword:(NSString **)password
          itemReference:(SecKeychainItemRef *)itemRef
{
    void *passwordData;
    UInt32 passwordLength;
    char *pword;
    
    OSStatus status = SecKeychainFindGenericPassword(NULL,
                                                     [_serviceName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                     [_serviceName cStringUsingEncoding:NSUTF8StringEncoding],
                                                     [_accountName lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
                                                     [_accountName cStringUsingEncoding:NSUTF8StringEncoding],
                                                     &passwordLength,
                                                     &passwordData,
                                                     itemRef);
    
    if (status == 0) {
        if (*password != nil) {
            [*password release];
        }

        pword = (char *)malloc(sizeof(char) * (passwordLength + 1));
        memcpy(pword, passwordData, passwordLength);
        pword[passwordLength] = '\0';
        
        *password = [NSString stringWithCString:(char *)pword encoding:NSUTF8StringEncoding];
        SecKeychainItemFreeContent(NULL, passwordData);
        free(pword);
        
    } else {
        *password = nil;
    }

    return status;
}

@end
