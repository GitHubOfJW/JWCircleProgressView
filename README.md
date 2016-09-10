# JWCircleProgressView
一个扩展性非常强大的进度控件,利用的图片做的进度，效果有你自己的图片决定

\\\
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
\\\

= 用法
\\\
self.circleProgressView.startText =  @"🌞 00:00";//☼

self.circleProgressView.endText = @"🌛 11:11";//☽

self.circleProgressView.centerText = @"88";

[self.circleProgressView starAnimationWithPartCount:5 partPercentBlock:^CGFloat(NSUInteger partIndex) {
switch (partIndex%4) {
case 0:
return 0.1;
break;
case 1:
return 0.18;
break;
case 2:
return 0.1;
break;
case 3:
return 0.15;
break;
default:
return 0.2;
break;
}

} parImageBlock:^UIImage * _Nonnull(NSUInteger partIndex) {
switch (partIndex%6) {
case 0:
return [UIImage imageNamed:@"p_blue"];
break;
case 1:
return [UIImage imageNamed:@"p_orange"];
break;
case 2:
return [UIImage imageNamed:@"p_purple"];
break;
case 3:
return [UIImage imageNamed:@"p_red"];
break;
case 4:
return [UIImage imageNamed:@"p_lightBlue"];
break;
case 5:
return [UIImage imageNamed:@"p_green"];
break;
default:
return [UIImage imageNamed:@"p_green"];
break;
}
} duration:0.5];
\\\


效果图
![](https://github.com/GitHubOfJW/JWCircleProgressView/blob/master/Source/0B70FEB0F9925768ABF2F302DBEE06B9.jpg)

效果图
![](https://github.com/GitHubOfJW/JWCircleProgressView/blob/master/Source/8428556F0B9C7CB59A7867DC3AE77A46.jpg)