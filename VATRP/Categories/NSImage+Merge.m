#import "NSImage+Merge.h"
#import "NSArray+Reversing.h"

@interface PFImage : NSImage {
    
    NSMutableArray *images;
    
    NSEdgeInsets caps;
    
    BOOL threeParts;
    BOOL vertical;
    CGFloat startCap, endCap;
    
    BOOL flipped;
}
- (id)initWithImage:(NSImage *)image capInsets:(NSEdgeInsets)insets;
- (id)initWithImage:(NSImage *)image startCap:(CGFloat)start endCap:(CGFloat)end vertical:(BOOL)vertical;
@end

@implementation PFImage

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        images = [coder decodeObjectForKey:@"images"];
        threeParts = [[coder decodeObjectForKey:@"threeParts"] boolValue];
        vertical = [[coder decodeObjectForKey:@"vertical"] boolValue];
        flipped = [[coder decodeObjectForKey:@"flipped"] boolValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:images forKey:@"images"];
    [coder encodeObject:@(threeParts) forKey:@"threeParts"];
    [coder encodeObject:@(vertical) forKey:@"vertical"];
    [coder encodeObject:@(flipped) forKey:@"flipped"];
}

- (id)initWithImage:(NSImage *)image capInsets:(NSEdgeInsets)insets {
    
    if (self = [super initWithSize:image.size]) {
        caps = insets;
        flipped = [image isFlipped];
        NSData *data = [image TIFFRepresentation];
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
        CGImageRef imageRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
        
        CGRect rect;
        CGImageRef slice;
        CGSize size = (CGSize) { CGImageGetWidth(imageRef), CGImageGetHeight(imageRef) };
        
        CGSize center = (CGSize) {
            size.width - caps.left - caps.right,
            size.height - caps.top - caps.bottom
        };
        
        images = [NSMutableArray arrayWithCapacity:9];
        
        rect = (NSRect) { 0.0f, 0.0f, caps.left, caps.top };
        slice = CGImageCreateWithImageInRect(imageRef, rect);
        [images addObject:[[NSImage alloc] initWithCGImage:slice size:rect.size]]; // Topleft
        CGImageRelease(slice);
        
        rect = (NSRect) { caps.left, 0.0f, center.width, caps.top };
        slice = CGImageCreateWithImageInRect(imageRef, rect);
        [images addObject:[[NSImage alloc] initWithCGImage:slice size:rect.size]]; // Top
        CGImageRelease(slice);
        
        rect = (NSRect) { size.width - caps.right, 0.0f, caps.right, caps.top };
        slice = CGImageCreateWithImageInRect(imageRef, rect);
        [images addObject:[[NSImage alloc] initWithCGImage:slice size:rect.size]]; // Topright
        CGImageRelease(slice);
        
        rect = (NSRect) { 0.0f, caps.top, caps.left, center.height };
        slice = CGImageCreateWithImageInRect(imageRef, rect);
        [images addObject:[[NSImage alloc] initWithCGImage:slice size:rect.size]]; // Left
        CGImageRelease(slice);
        
        rect = (NSRect) { caps.left, caps.top, center };
        slice = CGImageCreateWithImageInRect(imageRef, rect);
        [images addObject:[[NSImage alloc] initWithCGImage:slice size:rect.size]]; // Center
        CGImageRelease(slice);
        
        rect = (NSRect) { size.width - caps.right, caps.top, caps.right, center.height };
        slice = CGImageCreateWithImageInRect(imageRef, rect);
        [images addObject:[[NSImage alloc] initWithCGImage:slice size:rect.size]]; // Right
        CGImageRelease(slice);
        
        rect = (NSRect) { 0.0f, size.height - caps.bottom, caps.left, caps.bottom };
        slice = CGImageCreateWithImageInRect(imageRef, rect);
        [images addObject:[[NSImage alloc] initWithCGImage:slice size:rect.size]]; // Bottomleft
        CGImageRelease(slice);
        
        rect = (NSRect) { caps.left, size.height - caps.bottom, center.width, caps.bottom };
        slice = CGImageCreateWithImageInRect(imageRef, rect);
        [images addObject:[[NSImage alloc] initWithCGImage:slice size:rect.size]]; // Bottom
        CGImageRelease(slice);
        
        rect = (NSRect) { size.width - caps.right, size.height - caps.bottom, caps.right, caps.bottom };
        slice = CGImageCreateWithImageInRect(imageRef, rect);
        [images addObject:[[NSImage alloc] initWithCGImage:slice size:rect.size]]; // Bottomright
        CGImageRelease(slice);
        
        CGImageRelease(imageRef);
        CFRelease(source);
    }
    return self;
}

- (id)initWithImage:(NSImage *)image startCap:(CGFloat)start endCap:(CGFloat)end vertical:(BOOL)isVertical {
    
    if (self = [super initWithSize:image.size]) {
        
        threeParts = YES;
        startCap = start;
        endCap = end;
        vertical = isVertical;
        
        flipped = [image isFlipped];
        NSData *data = [image TIFFRepresentation];
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
        CGImageRef imageRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
        
        CGRect rect;
        CGImageRef slice;
        CGSize size = (CGSize) { CGImageGetWidth(imageRef), CGImageGetHeight(imageRef) };
        
        images = [NSMutableArray arrayWithCapacity:3];
        
        rect = (vertical ?
                (NSRect) { 0.0f, 0.0f, size.width, startCap } :
                (NSRect) { 0.0f, 0.0f, startCap, size.height });
        slice = CGImageCreateWithImageInRect(imageRef, rect);
        [images addObject:[[NSImage alloc] initWithCGImage:slice size:rect.size]];
        CGImageRelease(slice);
        
        rect = (vertical ?
                (NSRect) { 0.0f, startCap, size.width, size.height - startCap - endCap } :
                (NSRect) { startCap, 0.0f, size.width - startCap - endCap, size.height });
        slice = CGImageCreateWithImageInRect(imageRef, rect);
        [images addObject:[[NSImage alloc] initWithCGImage:slice size:rect.size]];
        CGImageRelease(slice);
        
        rect = vertical ?
        (NSRect) { 0.0f, size.width - endCap, size.width, endCap } :
        (NSRect) { size.width - endCap, 0.0f, endCap, size.height };
        slice = CGImageCreateWithImageInRect(imageRef, rect);
        [images addObject:[[NSImage alloc] initWithCGImage:slice size:rect.size]];
        CGImageRelease(slice);
        
        CGImageRelease(imageRef);
        CFRelease(source);
    }
    return self;
}

- (void)drawInRect:(NSRect)rect fromRect:(NSRect)fromRect operation:(NSCompositingOperation)op fraction:(CGFloat)delta {
    
    if (threeParts) {
        NSDrawThreePartImage(rect,
                             [images objectAtIndex:0],
                             [images objectAtIndex:1],
                             [images objectAtIndex:2],
                             vertical,
                             op, delta, flipped);
    } else {
        NSDrawNinePartImage(rect,
                            [images objectAtIndex:0],
                            [images objectAtIndex:1],
                            [images objectAtIndex:2],
                            [images objectAtIndex:3],
                            [images objectAtIndex:4],
                            [images objectAtIndex:5],
                            [images objectAtIndex:6],
                            [images objectAtIndex:7],
                            [images objectAtIndex:8],
                            op, delta, flipped);
    }
}

- (void)drawInRect:(NSRect)dstSpacePortionRect fromRect:(NSRect)srcSpacePortionRect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha respectFlipped:(BOOL)respectContextIsFlipped hints:(NSDictionary *)hints  {
    [self drawInRect:dstSpacePortionRect fromRect:srcSpacePortionRect operation:op fraction:requestedAlpha];
}

@end

@implementation NSImage (Merge)

+ (NSImage*)imageByTilingImages:(NSArray*)images
					   spacingX:(CGFloat)spacingX
					   spacingY:(CGFloat)spacingY
					 vertically:(BOOL)vertically {
	CGFloat mergedWidth = 0.0 ;
	CGFloat mergedHeight = 0.0 ;
    
	if (vertically) {
		images = [images arrayByReversingOrder] ;
	}
    
	for (NSImage* image in images) {
		NSSize size = [image size] ;
		if (vertically) {
			mergedWidth = MAX(mergedWidth, size.width) ;
			mergedHeight += size.height ;
			mergedHeight += spacingY ;
		}
		else {
			mergedWidth += size.width ;
			mergedWidth += spacingX ;
			mergedHeight = MAX(mergedHeight, size.height) ;
		}
	}
	// Add the outer margins for the single-image dimension
	// (The multi-image dimension has already had it added in the loop)
	if (vertically) {
		// Add left and right margins
		mergedWidth += 2 * spacingX ;
	}
	else {
		// Add top and bottom margins
		mergedHeight += 2 * spacingY ;
	}
	NSSize mergedSize = NSMakeSize(mergedWidth, mergedHeight) ;
	
	NSImage* mergedImage = [[NSImage alloc] initWithSize:mergedSize] ;
	[mergedImage lockFocus] ;
	
	// Draw the images into the mergedImage
	CGFloat x = spacingX ;
	CGFloat y = spacingY ;
	for (NSImage* image in images) {
		[image drawAtPoint:NSMakePoint(x, y)
				  fromRect:NSZeroRect
				 operation:NSCompositeSourceOver
				  fraction:1.0] ;
		if (vertically) {
			y += [image size].height ;
			y += spacingY ;
		}
		else {
			x += [image size].width ;
			x += spacingX ;
		}
	}

	[mergedImage unlockFocus] ;
	
	return mergedImage;
}

- (NSImage *)resizableImageWithTopCap:(CGFloat)top bottomCap:(CGFloat)bottom {
    return [[PFImage alloc] initWithImage:self startCap:top endCap:bottom vertical:YES];
}

@end