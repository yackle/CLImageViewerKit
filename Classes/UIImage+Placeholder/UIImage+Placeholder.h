//
//  UIImage+Placeholder.h
//

#import <UIKit/UIKit.h>

@interface UIImage (Placeholder)

+ (UIImage*)placeholder:(CGSize)size;

// for http://placekitten.com/
+ (NSURL*)placekittenURL:(CGSize)size;
+ (UIImage*)placekitten:(CGSize)size;
+ (void)placekitten:(CGSize)size completionBlock:(void (^)(UIImage *image))completion;

@end
