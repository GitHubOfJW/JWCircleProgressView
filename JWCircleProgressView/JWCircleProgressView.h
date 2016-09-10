//
//  JWCircleProgressView.h
//  ScoreAnimation_demo
//
//  Created by 朱建伟 on 16/9/5.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface JWCircleProgressView : UIControl

/**
 *  isAnimating
 */
@property(nonatomic,assign)BOOL isAnimating;
/**
 *  默认为 30
 */
@property(nonatomic,assign)CGFloat progressWidth;

/**
 *  中间图片的比例
 */
@property(nonatomic,assign)CGFloat centerCirclePercent;

NS_ASSUME_NONNULL_BEGIN
/**
 *  图片
 */
@property(nonatomic,strong)UIImage* centerImage;


/**
 *  初始角度 默认 -M_PI_4*3
 */
@property(nonatomic,assign)CGFloat startAngle;

/**
 *  clockwise YES 顺时针 NO 逆时针
 */
@property(nonatomic,assign)BOOL clockwise;

/**
 *  结束label的文字
 */
@property(nonatomic,copy)NSString* startText;


/**
 *  开始label的文字
 */
@property(nonatomic,copy)NSString* endText;


/**
 *  中间label的文字
 */
@property(nonatomic,copy)NSString* centerText;

 
/**
 *  中间label的字体
 */
@property(nonatomic,assign)CGFloat centerfontSize;

/**
 *  开始结束标签label的字体
 */
@property(nonatomic,assign)CGFloat labelFontSize;


/**
 *  开始动画  
 *  第一个参数：整个进度的百分比
 *  第二个参数：整个进度有多少段
 *  第三个参数：block 遍历每一段，参数为 每一段的index  返回该段 占整个进度的百分
 
    注意：进度总和 必须 <= 1 否则无效
 */
-(void)starAnimationWithPartCount:(NSUInteger)parCount partPercentBlock:( CGFloat(^)(NSUInteger partIndex))partPercentBlock parImageBlock:(nonnull UIImage*(^)(NSUInteger partIndex))parImageBlock  duration:(CFTimeInterval)duration;


NS_ASSUME_NONNULL_END

@end
