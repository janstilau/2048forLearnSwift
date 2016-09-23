//
//  main.m
//  countD
//
//  Created by jansti on 16/9/21.
//  Copyright © 2016年 jansti. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        
        NSString *text = [NSString stringWithContentsOfFile:@"/Users/jansti/Downloads/2016.09.21@17_30_59-2.log" encoding:NSUTF8StringEncoding error:nil];
        NSArray *textArray = [text componentsSeparatedByString:@"\n"];
        NSMutableString *textM = [NSMutableString string];
        NSLog(@"%@",@(textArray.count));
        for (NSString *text  in textArray) {
            if ([text containsString:@"耗时："] && [text containsString:@"接口"] ) {
                [textM appendString:text];
                [textM appendString:@"\n"];
            }
        }
        
        
        [textM writeToFile:@"/Users/jansti/Downloads/2016.09.21@17_30_59-3.log" atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    }
    return 0;
}
