//
//  UBWebView.m
//  Uebersicht
//
//  Created by Felix Hageloh on 5/8/19.
//  Copyright © 2019 tracesOf. All rights reserved.
//

#import "UBWebView.h"

@implementation UBWebView


- (void)mouseMoved:(NSEvent *)event
{
    [super mouseMoved: event];
    NSPoint location = [self convertPoint:[event locationInWindow] toView:nil];
    [self acceptEventsIfAboveWidget:location];
}

- (void)acceptEventsIfAboveWidget:(NSPoint)point
{
    UBWebView* __weak this = self;
    [self
        checkIsInsideWidget: point
        completionHandler: ^(NSNumber* result, NSError* err) {
            [this.window setIgnoresMouseEvents: ![result boolValue]];
        }
    ];
}

- (void)checkIsInsideWidget:(NSPoint)aPoint
          completionHandler:(void (^)(NSNumber*, NSError*))completionHandler
{
    NSString* command = [NSString
        stringWithFormat:@"document.elementFromPoint(%f, %f).id !== 'uebersicht'",
        aPoint.x, aPoint.y
    ];
    [self
        evaluateJavaScript: command
        completionHandler: completionHandler
    ];
}

- (BOOL) acceptsFirstMouse:(NSEvent*) event
{
    return YES;
}
@end
