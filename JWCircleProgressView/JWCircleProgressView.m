//
//  JWCircleProgressView.m
//  ScoreAnimation_demo
//
//  Created by 朱建伟 on 16/9/5.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//
/**
 *  提示
 */
#define JWAssert(e,reason)  assert(e)

#define KMinFontSize 12

#define KMaxFontSize 40

/**
 *  开始结束label的宽高
 */
#define KLabelW 60
#define KLabelH 20

/**
 *  中间的圆圈图 占控件的比例
 */
#define KCenterCirclePercent  0.4

/**
 *  进度的宽度 如果 圆加进度的宽度超出 侧进度宽度为 self.width/self.height ＊ （1-KCenterCirclePercent）
 */
#define KProgressWidth 30

#import "JWCircleProgressView.h"


@interface JWCircleProgressView()
/**
 *  duration
 */
@property(nonatomic,assign)CGFloat tempDuration;
/**
 *  unitPercent
 */
@property(nonatomic,assign)CGFloat unitPercent;

/**
 *  currentPercent
 */
@property(nonatomic,assign)CGFloat currentPercent;

/**
 *  totoalPercent
 */
@property(nonatomic,assign)CGFloat totalPercent;
/**
 *  CADisplayLink
 */
@property(nonatomic,strong)CADisplayLink* displayLink;


/**
 *  layerArray
 */
@property(nonatomic,strong)NSMutableArray<CAShapeLayer*>* layerArray;

/**
 *  储存每个进度的part
 */
@property(nonatomic,strong)NSMutableArray<NSNumber*>* partArray;



//+++++++++++++ 控件 +++++++++

/**
 *  开始的label
 */
@property(nonatomic,strong)UILabel* startLabel;

/**
 *  结束的Label
 */
@property(nonatomic,strong)UILabel* endLabel;

/**
 *  中间的图片
 */
@property(nonatomic,strong)UIImageView* circleImageView;


/**
 *  分数
 */
@property(nonatomic,strong)UILabel* centerLabel;


/**
 *  用来存储imageView
 */
@property(nonatomic,strong)UIView* containterView;

@end

@implementation JWCircleProgressView
/**
 *  初始化
 */
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.centerfontSize =  KMaxFontSize;
        self.labelFontSize = KMinFontSize;
        self.clockwise  =YES;
        self.startAngle =  -M_PI_4*3;
        self.centerCirclePercent =  KCenterCirclePercent;
        self.progressWidth = KProgressWidth;
        
        //开始结束的Label
        self.startLabel = [[UILabel alloc] init];
        self.startLabel.textColor = [UIColor whiteColor];
        self.startLabel.textAlignment = NSTextAlignmentCenter;
        self.startLabel.font = [UIFont systemFontOfSize:self.labelFontSize];
        self.startLabel.text =@"00:00";
        self.startLabel.backgroundColor = [UIColor clearColor];
        self.startLabel.layer.opacity = 0;
        [self addSubview:self.startLabel];
        
        self.endLabel = [[UILabel alloc] init];
        self.endLabel.textColor = [UIColor whiteColor];
        self.endLabel.textAlignment = NSTextAlignmentCenter;
        self.endLabel.text = @"11:11";
        self.endLabel.font = [UIFont systemFontOfSize:self.labelFontSize];
        self.endLabel.backgroundColor = [UIColor clearColor];
        self.endLabel.layer.opacity = 0;
        [self addSubview:self.endLabel];
        
        
        
        //控件
        self.circleImageView = [[UIImageView alloc] init];
        self.circleImageView.hidden = YES;
        [self addSubview:self.circleImageView];
        
        //分数
        self.centerLabel = [[UILabel alloc] init];
        self.centerLabel.textColor = [UIColor whiteColor];
        self.centerLabel.textAlignment = NSTextAlignmentCenter;
        self.centerLabel.font = [UIFont systemFontOfSize:self.centerfontSize];
        self.centerLabel.layer.opacity = 0;
        self.centerLabel.text =@"00";
        [self addSubview:self.centerLabel];
        
        //containerView
        self.containterView = [[UIView alloc] init];
        self.containterView.backgroundColor = [UIColor clearColor];
        self.containterView.userInteractionEnabled = NO;
        [self addSubview:self.containterView];
        
    }
    return self;
}

/**
 *  开始动画
 */
-(void)starAnimationWithPartCount:(NSUInteger)parCount partPercentBlock:(CGFloat (^)(NSUInteger))partPercentBlock parImageBlock:(UIImage * _Nonnull (^)(NSUInteger))parImageBlock duration:(CFTimeInterval)duration
{
    
    if(self.isAnimating)return;
    self.isAnimating = YES;
    
    if (self.circleImageView.hidden) {
        self.circleImageView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    }
    [UIView animateWithDuration:1 animations:^{
        self.circleImageView.hidden = NO;
        self.circleImageView.transform =  CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        self.tempDuration =  duration;
        
        [self.containterView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        [self.partArray removeAllObjects];
        [self.layerArray removeAllObjects];
        
        
        //1.遍历获取所有部分
        for(NSUInteger i=0;i<parCount;i++)
        {
            //(1)获取单个比例
            CGFloat partPercent = partPercentBlock(i);
            
            //(2)获取单个比例的图片
            UIImage* image = parImageBlock(i);
            
            //(3)添加imageView
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.containterView.bounds];
            imageView.backgroundColor =[UIColor clearColor];
            imageView.tag =  i+100;  // 方便获取到指定的imageView
            imageView.image = image;
            [self.containterView addSubview:imageView];
            
            //(4)添加imageView的mask
            CAShapeLayer* layer =[CAShapeLayer layer];
            layer.backgroundColor = [UIColor clearColor].CGColor;
            imageView.layer.mask = layer;
            [self.layerArray addObject:layer];
            
            //(5)存储进度单个part的进度 此处的partPercent 已经与 percent相乘
            [self.partArray addObject:@(partPercent)];
            self.totalPercent += partPercent;
        }
        
        //判断验证
        if(self.totalPercent>1.0001&&self.totalPercent<=0)
        {
            return;
        }
        
        //展示开始结束标签
        [self showStartAndEndLabelWithTotoalPercent:self.totalPercent andDuration:self.tempDuration];
        
        
        //根据时间进度计算 单位距离的动画
        self.unitPercent = self.totalPercent/self.tempDuration/60.0;
        
        //partPecent的进度和等于1
        [self startAnimationWithDuration:self.tempDuration];
    }];
    
   
}

/**
 *  展示开始和结束的标签
 */
-(void)showStartAndEndLabelWithTotoalPercent:(CGFloat)totalPercent andDuration:(CGFloat)duration
{
    CGFloat distance = self.progressWidth+20;//+sqrtf(expf(KLabelH*0.5)+expf(KLabelW*0.5));
    if (distance<KLabelW*0.5) {
        distance=KLabelW*0.5+20;
    }
    
    CGPoint center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
    
    //开始label的坐标
    CGPoint startPoint = [self getLastPointWithAngle:self.startAngle andCenter:center radius:self.circleImageView.bounds.size.width*0.5+distance];
    CGPoint startOrign =  [self getLastOriginWithCenterPoint:center start:YES andPoint:startPoint andDireBlock:^(BOOL isLeft) {
        self.startLabel.textAlignment = isLeft?NSTextAlignmentRight:NSTextAlignmentLeft;
    }];
    CGFloat startLabelX = startOrign.x;
    CGFloat startLabelY = startOrign.y;
    self.startLabel.frame =  CGRectMake(startLabelX, startLabelY, KLabelW, KLabelH);
    self.startLabel.layer.opacity = 0;
    
    //结束label的坐标
    CGPoint endPoint = [self getLastPointWithAngle:self.startAngle+(self.clockwise?M_PI*2*totalPercent:-M_PI*2*totalPercent) andCenter:center radius:self.circleImageView.bounds.size.width*0.5+distance];
    CGPoint endOrigin = [self getLastOriginWithCenterPoint:center start:NO andPoint:endPoint andDireBlock:^(BOOL isLeft) {
        self.endLabel.textAlignment = isLeft?NSTextAlignmentRight:NSTextAlignmentLeft;
    }];
    CGFloat endLabelX = endOrigin.x;
    CGFloat endLabelY = endOrigin.y;
    self.endLabel.frame =  CGRectMake(endLabelX, endLabelY, KLabelW, KLabelH);
    self.endLabel.layer.opacity = 0;
    
    //动画显示
    CABasicAnimation *startLabelAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    startLabelAnimation.removedOnCompletion = NO;
    startLabelAnimation.duration = duration*2;
    startLabelAnimation.fillMode = kCAFillModeForwards;
    startLabelAnimation.fromValue = @(0.0);
    startLabelAnimation.toValue = @(1.0);
    [self.startLabel.layer addAnimation:startLabelAnimation forKey:@"StartLabelOpacity"];
    
    //动画显示
    CABasicAnimation *endLabelAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    endLabelAnimation.removedOnCompletion = NO;
    endLabelAnimation.duration = duration*2;
    endLabelAnimation.fillMode = kCAFillModeForwards;
    endLabelAnimation.fromValue = @(0.0);
    endLabelAnimation.toValue = @(1.0);
    [self.endLabel.layer addAnimation:endLabelAnimation forKey:@"EndLabelOpacity"];
    
    //动画显示
    CABasicAnimation *centerLabelAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    centerLabelAnimation.removedOnCompletion = NO;
    centerLabelAnimation.duration = duration*2;
    centerLabelAnimation.fillMode = kCAFillModeForwards;
    centerLabelAnimation.fromValue = @(0.0);
    centerLabelAnimation.toValue = @(1.0);
    [self.centerLabel.layer addAnimation:endLabelAnimation forKey:@"centerLabelOpacity"];
    
}

/**
 *  根据中心判断 偏移方向
 */
-(CGPoint)getLastOriginWithCenterPoint:(CGPoint)center  start:(BOOL)isStart andPoint:(CGPoint)point andDireBlock:(void(^)(BOOL isLeft))direBlock
{
    
    CGFloat x  = point.x-KLabelW*0.5;
    CGFloat y  = point.y-KLabelH*0.5;
    return  CGPointMake(x, y);
    
}


/**
 *  刷新UI
 */
-(void)refreshUI
{
    BOOL flag = NO;
    //1.60次是一秒
    if (self.currentPercent<=self.totalPercent) {
        CGFloat value =  self.unitPercent; 
        self.currentPercent+= value;
        [self displayWithCurrentPercent:self.currentPercent>self.totalPercent?self.totalPercent:self.currentPercent];
        if (self.totalPercent<=0) {
            flag = YES;
        }
    }else
    {
        flag = YES;
    }
    
    if (flag) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        self.currentPercent = 0;
        self.totalPercent = 0;
        self.isAnimating = NO;
    }
}

/**
 *  跟进进度刷新
 */
-(void)displayWithCurrentPercent:(CGFloat)currentPercent
{
    
    //1.遍历
    __block CGFloat startPercent = 0;
    __block NSUInteger preIndex = 0;
    __block CGFloat prePart = 0;
    [self.partArray enumerateObjectsUsingBlock:^(NSNumber * _Nonnull value, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        @autoreleasepool {
         
        // 获取 单个片段的比例
        CGFloat partPercent = value.floatValue;
        
        //判断范围
        if (currentPercent>=startPercent&&currentPercent<startPercent+partPercent) {
            CAShapeLayer* shapeLayer = self.layerArray[idx];
            shapeLayer.path =  [self getPathWithStartPercent:startPercent partPercent:currentPercent-startPercent].CGPath;
            UIImageView* progressImageView = [self.containterView viewWithTag:idx+100];
            if (progressImageView) {
                progressImageView.layer.mask =  shapeLayer;
            }
            
            //防上一段跳格
            if (idx!=preIndex) {
                CAShapeLayer* preShapeLayer = self.layerArray[idx-1];
                preShapeLayer.path =  [self getPathWithStartPercent:startPercent-prePart partPercent:prePart].CGPath;
                UIImageView* preProgressImageView = [self.containterView viewWithTag:idx-1+100];
                if (preProgressImageView) {
                    preProgressImageView.layer.mask =  preShapeLayer;
                }
            }
            
            *stop = YES;
        }
        
        preIndex=idx;
        
        prePart =  partPercent;
       
        
        //记录进度
        startPercent  += partPercent;
            
       }
    }];

}

/**
 *  开始动画
 */
-(void)startAnimationWithDuration:(CFTimeInterval)duration
{
    if (!self.displayLink) {
        self.isAnimating = YES;
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshUI)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}


/**
 *  计算path
 */
-(UIBezierPath*)getPathWithStartPercent:(CGFloat)startPercent partPercent:(CGFloat)partPercent
{
    // 1.启示角度 和 结束角度
    CGFloat startAngle = self.startAngle + (self.clockwise?M_PI*2*startPercent:-M_PI*2*startPercent);
    CGFloat endAngle =  startAngle +(self.clockwise?M_PI*2*partPercent:-M_PI*2*partPercent);
    
    // 2.创建path
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    CGPoint center = CGPointMake(self.containterView.bounds.size.width*0.5, self.containterView.bounds.size.height*0.5);
    
    [path moveToPoint:center];
    
    // 3.启示点
    CGPoint startPoint =  [self getLastPointWithAngle:startAngle andCenter:center radius:self.circleImageView.bounds.size.width*0.5];
    [path addLineToPoint:startPoint];
    
    // 4.内半弧
    [path addArcWithCenter:center radius:self.circleImageView.bounds.size.width*0.5 startAngle:startAngle endAngle:endAngle clockwise:self.clockwise];
     
    // 5.添加线到外半弧
    CGPoint outerStarPoint =  [self getLastPointWithAngle:endAngle andCenter:center radius:self.containterView.bounds.size.width*0.5];
    [path addLineToPoint:outerStarPoint];
    
    // 6.外半弧
    [path addArcWithCenter:center radius:self.containterView.bounds.size.width*0.5 startAngle:endAngle endAngle:startAngle clockwise:!self.clockwise];
    
    // 7.闭合
    [path closePath];
    
    return path;
}


/**
 *  获取圆上的点坐标
 */
-(CGPoint)getLastPointWithAngle:(CGFloat)angle andCenter:(CGPoint)center radius:(CGFloat)radius
{
    //算出圆上的点
    CGFloat  y = center.y + sinf(angle)*radius ;
    CGFloat  x = center.x + cosf(angle)*radius;
    return CGPointMake(x, y);
}

/**
 *  设置图片比例
 */
-(void)setCenterCirclePercent:(CGFloat)centerCirclePercent
{
    if (centerCirclePercent>1) {
        _centerCirclePercent =  KCenterCirclePercent;
    }else
    {
        _centerCirclePercent = centerCirclePercent;
    }
}

/**
 *  设置开始文字
 */
-(void)setStartText:(NSString *)startText
{
    if (startText) {
        _startText = startText;
        self.startLabel.text =  startText;
    }
}

/**
 *  设置中间文字
 */
-(void)setCenterText:(NSString *)centerText
{
    if (centerText) {
        _centerText = centerText;
        self.centerLabel.text = centerText;
    }
}

/**
 *  设置结束文字
 */
-(void)setEndText:(NSString *)endText
{
    if (endText) {
        _endText = endText;
        self.endLabel.text =  endText;
    }
}

/**
 *  设置图片
 */
-(void)setCenterImage:(UIImage *)centerImage
{
    if (centerImage) {
        _centerImage =  centerImage;
        self.circleImageView.image = centerImage;
    }
}


/**
 *  设置labelSize
 */
-(void)setLabelFontSize:(CGFloat)labelFontSize
{
    _labelFontSize =  labelFontSize;
    
    UIFont* font =  [UIFont systemFontOfSize:labelFontSize];
    self.startLabel.font = font;
    self.endLabel.font = font;
}

/**
 *  设置文字大小
 */
-(void)setCenterfontSize:(CGFloat)centerfontSize
{
    _centerfontSize =  centerfontSize;
    self.centerLabel.font = [UIFont systemFontOfSize:centerfontSize];
}


/**
 *  partArray
 */
-(NSMutableArray<NSNumber *> *)partArray
{
    if (_partArray == nil) {
        _partArray = [NSMutableArray array];
    }
    return _partArray;
}

/**
 *  layerArray
 */
-(NSMutableArray<CAShapeLayer *> *)layerArray
{
    if (_layerArray==nil) {
        _layerArray = [NSMutableArray array];
    }
    return _layerArray;
}

/**
 *  布局
 */
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat lastWH = self.bounds.size.height>self.bounds.size.width?self.bounds.size.width:self.bounds.size.height;
    
    CGFloat circleW  = lastWH * self.centerCirclePercent;
    CGFloat circleH  = circleW;
    CGFloat circleX  = (self.bounds.size.width-circleW)*0.5;
    CGFloat circleY  = (self.bounds.size.height-circleH)*0.5;
    self.circleImageView.frame = CGRectMake(circleX, circleY, circleW, circleH);
    
    
    CGFloat centerLabelW = circleW/sqrtf(2)*0.8;
    CGFloat centerLabelH = centerLabelW;
    CGFloat centerLabelX = (self.bounds.size.width-centerLabelW)*0.5;
    CGFloat centerLabelY = (self.bounds.size.height-centerLabelH)*0.5;
    self.centerLabel.frame =  CGRectMake(centerLabelX, centerLabelY, centerLabelW, centerLabelH);
    
    CGFloat containerW = circleW+2*self.progressWidth;
    CGFloat containerH = circleH+2*self.progressWidth;
    CGFloat containerX = (self.bounds.size.width-containerW)*0.5;
    CGFloat containerY = (self.bounds.size.height-containerH)*0.5;
    self.containterView.frame= CGRectMake(containerX, containerY, containerW, containerH);
}


@end
