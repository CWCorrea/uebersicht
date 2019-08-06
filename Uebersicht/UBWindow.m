//
//  UBWindow.m
//  Übersicht
//
//  A window that sits on desktop level, is always fullscreen and doesn't show
//  up in Mission Control
//
//  Created by Felix Hageloh on 20/9/13.
//  Copyright (c) 2013 Felix Hageloh.
//  Released under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. See <http://www.gnu.org/licenses/> for
//  details.
//

#import "UBWindow.h"
#import "UBWebViewController.h"

@implementation UBWindow {
    UBWebViewController* webViewController;
    NSTrackingArea* trackingArea;
    BOOL hasMouse;
}

- (id)init
{

    self = [super
        initWithContentRect: NSMakeRect(0, 0, 0, 0)
        styleMask: NSBorderlessWindowMask
        backing: NSBackingStoreBuffered
        defer: NO
    ];
    
    if (self) {
        [self setBackgroundColor:[NSColor clearColor]];
        [self setOpaque:NO];
        [self sendToDesktop];
        [self setCollectionBehavior:(
            NSWindowCollectionBehaviorTransient |
            NSWindowCollectionBehaviorCanJoinAllSpaces |
            NSWindowCollectionBehaviorIgnoresCycle
        )];

        [self setRestorable:NO];
        [self disableSnapshotRestoration];
        [self setDisplaysWhenScreenProfileChanges:YES];
        [self setReleasedWhenClosed:NO];
        [self setIgnoresMouseEvents:YES];
        
        webViewController = [[UBWebViewController alloc]
            initWithFrame: [self frame]
        ];
        [self setContentView:webViewController.view];
        hasMouse = YES;
        trackingArea = [[NSTrackingArea alloc]
            initWithRect:self.contentView.bounds
            options: NSTrackingMouseMoved|NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways|NSTrackingInVisibleRect
            owner:self
            userInfo:nil
        ];
        
        [self.contentView addTrackingArea:trackingArea];
    }

    return self;
}

- (void)mouseMoved:(NSEvent*)event
{
    if (self.ignoresMouseEvents) {
       [self.contentView mouseMoved:event];
    }
    
    NSPoint location = [self.contentView
        convertPoint: [event locationInWindow]
        toView: nil
    ];
    [self acceptEventsIfAboveWidget: location];
}

- (void)mouseEntered:(NSEvent*)event
{
    hasMouse = YES;
    if (self.ignoresMouseEvents) {
       [self.contentView mouseEntered:event];
    }
}

- (void)mouseExited:(NSEvent*)event
{
    hasMouse = NO;
    if (self.ignoresMouseEvents) {
        [self.contentView mouseExited:event];
    }
}


- (void)acceptEventsIfAboveWidget:(NSPoint)point
{
    NSWindow* __weak this = self;
    [webViewController
        checkIsInsideWidget: point
        completionHandler: ^(NSNumber* result, NSError* err) {
            [this setIgnoresMouseEvents: ![result boolValue]];
        }
    ];
}

- (void)loadUrl:(NSURL*)url
{
    [webViewController load:url];
}

- (void)reload
{
    [webViewController reload];
}

// TODO: check if we can do at least some cleanups in webViewController#destroy
//- (void)close
//{
//    [webViewController destroy];
//    [super close];
//}


#
#pragma mark signals/events
#

- (void)workspaceChanged
{
    [webViewController redraw];
}

- (void)wallpaperChanged
{
    [webViewController redraw];
}

#
#pragma mark window control
#


- (void)sendToDesktop
{
    [self setLevel:kCGNormalWindowLevel-1];
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    if ([[defaults valueForKey:@"compatibilityMode"] boolValue]) {
//        [self setLevel:kCGDesktopWindowLevel - 1];
//    } else {
//        [self setLevel:kCGDesktopWindowLevel];
//    }
}

- (void)comeToFront
{
    if (self.isInFront) return;

    [self setLevel:kCGNormalWindowLevel-1];
    [NSApp activateIgnoringOtherApps:NO];
    [self makeKeyAndOrderFront:self];
}

- (BOOL)isInFront
{
    return self.level == kCGNormalWindowLevel-1;
}


#
#pragma mark flags
#

- (BOOL)isKeyWindow { return hasMouse; }
- (BOOL)canBecomeKeyWindow { return YES; }
- (BOOL)canBecomeMainWindow { return [self isInFront]; }
- (BOOL)acceptsFirstResponder { return [self isInFront]; }
- (BOOL)acceptsMouseMovedEvents { return [self isInFront]; }

@end
