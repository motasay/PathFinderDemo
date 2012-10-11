
@interface Robot : NSObject {
   int world_y_max;
   int world_x_max;
   
   int x, y;
      
   int **moves;
   int *moves_costs;
   
   int **expandedCells;
}

@property (readonly) int x;
@property (readonly) int y;

- (id)initInWorld:(int **)world
        worldSize:(CGSize)aSize
 withVerticalCost:(int)vc
   horizontalCost:(int)hc
     diagonalCost:(int)dc;

- (void) setVerticalCost:(int)vc
          horizontalCost:(int)hc
            diagonalCost:(int)dc;

- (void)setLocationX:(int)aX andY:(int)aY;

- (UIImage *)image;




- (NSArray *)getPlanToLocation:(CGPoint)goal inWorld:(int **)world;

- (void)smoothPoints:(CGPoint *)originalPoints
            toBuffer:(CGPoint *)buffer
         numOfPoints:(int)numOfPoints
          weightData:(float)weightData
        weightSmooth:(float)weightSmooth
           tolerance:(float)tolerance
             inWorld:(int **)world;

@end
