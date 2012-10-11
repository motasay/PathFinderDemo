#import "PathView.h"

@implementation PathView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       [self setBackgroundColor:[UIColor clearColor]];
       points = NULL;
       numOfPoints = 0;
    }
    return self;
}

- (void) dealloc
{
   if (points != NULL)
      free(points);
   [super dealloc];
}

- (void)setPoints:(CGPoint *)pnts count:(int)n
{
   if (points != NULL)
      free(points);
   
   if (pnts == NULL)
   {
      points = NULL;
      numOfPoints = 0;
   }
   else
   {
      points = malloc(n * sizeof(CGPoint));
      for (int i = 0; i < n; i++) {
         points[i] = pnts[i];
      }
      numOfPoints = n;
   }
}

- (int)numOfPoints
{
   return numOfPoints;
}

- (CGPoint *)points
{
   return points;
}

- (void)drawRect:(CGRect)rect
{
   if (numOfPoints > 0) {
      
      CGContextRef context = UIGraphicsGetCurrentContext();
      
      CGContextSetLineWidth(context, 2.0f);
      CGContextSetStrokeColorWithColor(context, PATH_COLOR);

      CGContextBeginPath(context);
      CGContextMoveToPoint(context, points[0].x, points[0].y);
      for (int i = 1; i < numOfPoints; i++) {
         CGContextAddLineToPoint(context, points[i].x, points[i].y);
      }
      
      CGContextDrawPath(context, kCGPathStroke);
   }
}

@end
