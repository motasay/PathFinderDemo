
#define BLOCK_COLOR [UIColor colorWithRed:205/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:255.0/255.0f]
#define NON_BLOCK_COLOR [UIColor colorWithRed:20.0f/255.0f green:80.0f/255.0f blue:130.0f/255.0f alpha:255.0/255.0f]
#define GOAL_COLOR [UIColor redColor].CGColor

@class Robot;
@class PathView;

@interface GridView : UIView {
   
   int **cells;
   int **touchedCells; // used in setBlocksForPoints:count: for manipulating the blocks
   CGSize cellSize;
   int numOfRows;
   int numOfCols;
   
   Robot *robot;
   UIImageView *robotView;
   PathView *pathView;
   
   CGPoint goal;
   UIView *goalView;
}

@property (readonly) BOOL isMoving;
@property (readonly) BOOL stateModified;

- (int **)world;
- (CGSize)worldSize;
- (void)addRobot:(Robot *)obj;
- (Robot *)robot;

- (void)setGoal:(CGPoint)point;
- (void)setBlocksForPoints:(CGPoint *)points count:(int)n;

- (void)letRobotPlan;
- (void)letRobotSmoothPlanWithWeightData:(float)wd weightSmooth:(float)ws tolerance:(float)tolerance;
- (void)letRobotMoveWithSleepTime:(NSNumber *)time;
@end
