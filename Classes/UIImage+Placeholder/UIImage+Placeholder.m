//
//  UIImage+Placeholder.m
//

#import "UIImage+Placeholder.h"

@implementation UIImage (Placeholder)

+ (UIImage*)placeholder:(CGSize)size
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
    label.textColor = [UIColor colorWithWhite:0.7 alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%d x %d", (int)size.width, (int)size.height];
    label.font = [UIFont systemFontOfSize:MIN(size.width, size.height) * 0.2];
    
    UIGraphicsBeginImageContext(size);
    [label.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSURL*)placekittenURL:(CGSize)size
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://placekitten.com/%i/%i", (int)(size.width), (int)(size.height)]];
}

+ (UIImage*)placekitten:(CGSize)size
{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[self placekittenURL:size]]];
}

+ (void)placekitten:(CGSize)size completionBlock:(void (^)(UIImage *image))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self placekitten:size];
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completion){
				completion(image);
			}
		});
    });
}

@end
