//
//  HomeWindowController.h
//  VATRP
//
//  Created by Norayr Harutyunyan on 9/3/15.
//  Developed pursuant to contract FCC15C0008 as open source software under GNU General Public License version 2.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HomeViewController.h"

@interface HomeWindowController : NSWindowController
@property (strong) HomeViewController* homeViewController;

-(void)refreshForNewLogin;
-(void)clearData;

- (HomeViewController*) getHomeViewController;

-(NSPoint) getWindowOrigin;
-(CGSize) getWindowSize;

-(void) setWindowPos:(NSPoint) pos;
@end
