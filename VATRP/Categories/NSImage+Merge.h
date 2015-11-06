#import <Cocoa/Cocoa.h>

@interface NSImage (Merge) 

+ (NSImage*)imageByTilingImages:(NSArray*)images
					   spacingX:(CGFloat)spacingY
					   spacingY:(CGFloat)spacingY
					 vertically:(BOOL)vertically ;
- (NSImage *)resizableImageWithTopCap:(CGFloat)top bottomCap:(CGFloat)bottom;

@end
