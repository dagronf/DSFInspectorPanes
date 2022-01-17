//
//  AppDelegate.m
//  DSFInspectorPanes Objc Demo
//
//  Created by Darren Ford on 17/1/2022.
//  Copyright © 2022 Darren Ford. All rights reserved.
//

#import "AppDelegate.h"
#import "ColorViewController.h"

@import DSFInspectorPanes;

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property (weak) IBOutlet DSFInspectorPanesView *inspectorPanes;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	{
		ColorViewController* pane = [[ColorViewController alloc] init];
		[pane loadView];
		NSView* headerView = [pane headerView];

		[[self inspectorPanes] addPaneWithTitle: @"Colors"
													  view: [pane view]
											 showsHeader: true
								  headerAccessoryView: headerView
						  headerAccessoryVisibility: DSFInspectorPaneHeaderAccessoryVisibilityOnlyWhenCollapsed
										  expansionType: DSFInspectorPaneExpansionTypeExpanded];
	}

	{
		ColorViewController* pane = [[ColorViewController alloc] init];
		[pane loadView];
		NSView* headerView = [pane headerView];

		[[self inspectorPanes] addPaneWithTitle: @"Colors 2"
													  view: [pane view]
											 showsHeader: true
								  headerAccessoryView: headerView
						  headerAccessoryVisibility: DSFInspectorPaneHeaderAccessoryVisibilityAlways
										  expansionType: DSFInspectorPaneExpansionTypeExpanded];
	}

	{
		ColorViewController* pane = [[ColorViewController alloc] init];
		[pane loadView];
		NSView* headerView = [pane headerView];

		[[self inspectorPanes] addPaneWithTitle: @"Colors 3"
													  view: [pane view]
											 showsHeader: true
								  headerAccessoryView: headerView
						  headerAccessoryVisibility: DSFInspectorPaneHeaderAccessoryVisibilityAlways
										  expansionType: DSFInspectorPaneExpansionTypeCollapsed];
	}
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
	return YES;
}


@end
