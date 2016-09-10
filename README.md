# JWCircleProgressView
一个扩展性非常强大的进度控件,利用的图片做的进度，效果有你自己的图片决定
 
= 用法 

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
 


效果图
![](https://github.com/GitHubOfJW/JWCircleProgressView/blob/master/Source/0B70FEB0F9925768ABF2F302DBEE06B9.jpg)

效果图
![](https://github.com/GitHubOfJW/JWCircleProgressView/blob/master/Source/8428556F0B9C7CB59A7867DC3AE77A46.jpg)