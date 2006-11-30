//
//  DemoController.m
//  STNKeychainAccess Demo
//
//  Created by Simon Stiefel on 29.11.06.
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

#import "DemoController.h"

@implementation DemoController

- (void)awakeFromNib
{
    kc = [[STNKeychainAccess alloc] init];
    [statusline setStringValue:@""];
}

- (IBAction)fetchStoredPassword:(id)sender
{
    [oldpassword setStringValue:@""];
    if ([self checkServiceAndAccountName]) {
        NSString *password = nil;
        OSStatus status;
        [kc setServiceName:[servicename stringValue]];
        [kc setAccountName:[accountname stringValue]];
        if (status = [kc getPassword:&password itemReference:nil]) {
            [statusline setStringValue:[NSString stringWithFormat:@"Error code: %d", status]];
        } else {
            [statusline setStringValue:@"Password fetched"];
            [oldpassword setStringValue:password];
        }
    }
}

- (IBAction)setNewPassword:(id)sender
{
    [oldpassword setStringValue:@""];
    if ([self checkServiceAndAccountName]) {
        OSStatus status;
        [kc setServiceName:[servicename stringValue]];
        [kc setAccountName:[accountname stringValue]];
        if (status = [kc savePassword:[newpassword stringValue]]) {
            [statusline setStringValue:[NSString stringWithFormat:@"Error code: %d", status]];
        } else {
            [statusline setStringValue:@"Password saved!"];
        }
    }
}

- (BOOL)checkServiceAndAccountName
{
    if ([[servicename stringValue] length] == 0 ||
        [[accountname stringValue] length] == 0) {
        [statusline setStringValue:[NSString stringWithFormat:@"Please enter service and account name"]];
        return NO;
    }
    return YES;
}

- (IBAction)quitApplication:(id)sender
{
    [NSApp terminate:self];
}


@end
