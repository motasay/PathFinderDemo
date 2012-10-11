#define PATH_COLOR [UIColor redColor].CGColor

@interface PathView : UIView {
   CGPoint *points;
   int numOfPoints;
}

- (void)setPoints:(CGPoint *)pnts count:(int)n;
- (CGPoint *)points;
- (int)numOfPoints;
@end
