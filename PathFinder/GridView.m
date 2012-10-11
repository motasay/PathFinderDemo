#import "GridView.h"
#import "PathView.h"

#import "Robot.h"

#import <QuartzCore/QuartzCore.h>

@implementation GridView

- (id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
   if (self) {
      cellSize = CGSizeMake(5, 5);
            
      numOfRows = self.frame.size.height / cellSize.height;
      numOfCols = self.frame.size.width  / cellSize.width;
            
      goalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
      [goalView setBackgroundColor:[UIColor clearColor]];
      goalView.layer.borderColor = GOAL_COLOR;
      goalView.layer.borderWidth = 1.0f;
      
      pathView = [[PathView alloc] initWithFrame:frame];

      // Setup the cells
      cells = malloc(numOfRows * sizeof(int *));
      touchedCells = malloc(numOfRows * sizeof(int *));
         
      int y = 0;
      for (int row = 0; row < numOfRows; row++) {
         cells[row] = malloc(numOfCols * sizeof(int));
         touchedCells[row] = malloc(numOfCols * sizeof(int));
         
         int x = 0;
         for (int col = 0; col < numOfCols; col++) {
                        
            int isBlock = isABlock(row, col, numOfRows, numOfCols);
            
            UIColor *color;
            if (isBlock)
               color = BLOCK_COLOR;
            else
               color = NON_BLOCK_COLOR;
            // Create a cell view
            UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(x, y, cellSize.width, cellSize.height)];
            [cell setBackgroundColor:color];
            [self addSubview:cell];
            [cell release];
            
            // Save it
            cells[row][col] = isBlock;
            
            touchedCells[row][col] = 0;
            
            x += cellSize.width;
         }
         y += cellSize.height;
      }
            
      robot = nil;
      robotView = nil;
      [self addSubview:pathView];
   }
   return self;
}

- (void) dealloc
{
   for (int row = 0; row < numOfRows; row++) {
      free(cells[row]);
      free(touchedCells[row]);
   }
   free(cells);
   free(touchedCells);
   
   [robot release];
   [robotView release];
   [pathView release];
   [goalView release];
   [super dealloc];
}

- (int **)world
{
   return cells;
}
- (CGSize)worldSize
{
   return CGSizeMake(numOfCols, numOfRows);
}
- (Robot *)robot
{
   return robot;
}

- (void)addRobot:(Robot *)obj
{
   if (robot) {
      [robot release];
      [goalView removeFromSuperview];
   }
   robot = [obj retain];
      
   int xPos = arc4random() % numOfCols;
   int yPos = arc4random() % numOfRows;
   // make sure this is not a block position
   while (cells[yPos][xPos]) {
      xPos = arc4random() % numOfCols;
      yPos = arc4random() % numOfRows;
   }
   [robot setLocationX:xPos andY:yPos];
   
   goal = CGPointMake(xPos, yPos);
   
   if (!robotView) {
      robotView = [[UIImageView alloc] initWithImage:[robot image]];
      [self addSubview:robotView];
   }
   [self setRobotPosition:[NSValue valueWithCGPoint:[self convertCellPositionToPoint:goal]]];
}

- (void)setRobotPosition:(NSValue *)val
{
   robotView.center = [val CGPointValue];
}

- (CGPoint)convertPointToCellPosition:(CGPoint)point
{
   int x = floorf(point.x / cellSize.width ) + 0.5;
   int y = floorf(point.y / cellSize.height) + 0.5;
   return CGPointMake(x, y);
}

- (CGPoint)convertCellPositionToPoint:(CGPoint)cellPos
{
   return CGPointMake(cellPos.x * cellSize.width + cellSize.width / 2.0f, cellPos.y * cellSize.height + cellSize.height / 2.0f);
}

- (void)setGoal:(CGPoint)point
{
   CGPoint newPoint = [self convertPointToCellPosition:point];
   int x = newPoint.x;
   int y = newPoint.y;
   
   // Make sure it's not on a block
   if (cells[y][x] == 0) {
      goal = CGPointMake(x, y);
      if (self.isMoving)
         _stateModified = YES;
      
      [goalView removeFromSuperview];
      goalView.center = [self convertCellPositionToPoint:newPoint];
      [self addSubview:goalView];
   }
}

- (void)setBlocksForPoints:(CGPoint *)points count:(int)n
{
   // Set the cells that has been touched
   for (int i = 0; i < n; i++) {
      CGPoint touchPoint = points[i];
      CGPoint cellLocation = [self convertPointToCellPosition:touchPoint];
      int x = cellLocation.x;
      int y = cellLocation.y;
      if (x >= 0 && x < numOfCols && y >= 0 && y < numOfRows)
         touchedCells[y][x] = 1;
   }
   
   [pathView removeFromSuperview];

   // using the temp cells, reverse the blocks
   for (int row = 0; row < numOfRows; row++) {
      for (int col = 0; col < numOfCols; col++) {
         
         if (touchedCells[row][col] && (goal.y != row || goal.x != col)) // don't add a block on top of the goal
         {
            cells[row][col] = !cells[row][col];
            
            UIColor *color;
            if (cells[row][col])
               color = BLOCK_COLOR;
            else
               color = NON_BLOCK_COLOR;
            
            UIView *cell = [self hitTest:CGPointMake(col * cellSize.width, row * cellSize.height) withEvent:nil];
            [cell setBackgroundColor:color];
            
            touchedCells[row][col] = 0;
         }
      }
   }
   if (self.isMoving)
      _stateModified = YES;
   [self addSubview:pathView];
}

- (CGPoint *)getPlanPoints:(int *)numOfPoints
{
   NSArray *plan = [robot getPlanToLocation:goal inWorld:cells];
   if (!plan) {
      return NULL; // The search wasn't successfull
   }
   
   CGPoint *points = malloc([plan count] * sizeof(CGPoint));
   *numOfPoints = (int)[plan count];
   for (int i = 0; i < *numOfPoints; i++) {
      points[i] = [self convertCellPositionToPoint:[[plan objectAtIndex:i] CGPointValue]];
   }
   return points;
}

- (void)letRobotPlan
{
   [pathView setPoints:NULL count:0];
   [pathView setNeedsDisplay];
   if (goal.x != robot.x || goal.y != robot.y) {
      
      int numOfPoints;
      CGPoint *points = [self getPlanPoints:&numOfPoints];
      
      [pathView setPoints:points count:numOfPoints];
      [pathView setNeedsDisplay];
      
      [self bringSubviewToFront:robotView];
      free(points);
   }
}

- (void)letRobotSmoothPlanWithWeightData:(float)wd weightSmooth:(float)ws tolerance:(float)tolerance
{
   // get the plan from the pathView
   CGPoint *points = [pathView points];
   int numOfPoints = [pathView numOfPoints];
   if (numOfPoints == 0) {
      return;
   }
   
   // Convert the points to cell grids
   CGPoint *cellPoints = malloc(numOfPoints * sizeof(CGPoint));
   for (int i = 0; i < numOfPoints; i++) {
      cellPoints[i] = [self convertPointToCellPosition:points[i]];
   }
   [pathView setPoints:NULL count:0];
   [pathView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
   
   CGPoint *smoothPoints = malloc(numOfPoints * sizeof(CGPoint));
   [robot smoothPoints:cellPoints toBuffer:smoothPoints numOfPoints:numOfPoints weightData:wd weightSmooth:ws tolerance:tolerance inWorld:cells];
   free(cellPoints);

   // Convert the points back to the view's coordinates
   for (int i = 0; i < numOfPoints; i++) {
      smoothPoints[i] = [self convertCellPositionToPoint:smoothPoints[i]];
   }
   
   [pathView setPoints:smoothPoints count:numOfPoints];
   [pathView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
   
   free(smoothPoints);
}

- (void)letRobotMoveWithSleepTime:(NSNumber *)time
{
   float t = [time floatValue];
   
   if (goal.x != robot.x && goal.y != robot.y) {

      _isMoving = YES;
      
      // check if there is a path that's been planned before
      CGPoint *points = [pathView points];
      int numOfPoints = [pathView numOfPoints];
      
      int needToRelease = 0;
      if (numOfPoints == 0)
      {
         points = [self getPlanPoints:&numOfPoints];
         if (points == NULL) {
            return; // unsuccessful search
         }
         needToRelease = 1;
         [pathView setPoints:points count:numOfPoints];
         [pathView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
         [self performSelectorOnMainThread:@selector(bringSubviewToFront:) withObject:robotView waitUntilDone:YES];
      }
         
      for (int i = 0; i < numOfPoints; i++) {
         
         if (self.stateModified) {
            // replan and reset i
            if (needToRelease)
               free(points);
            points = [self getPlanPoints:&numOfPoints];
            needToRelease = 1;
            
            [pathView setPoints:points count:numOfPoints];
            [pathView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(bringSubviewToFront:) withObject:robotView waitUntilDone:YES];

            i = 0;
            _stateModified = NO;
            if (points == NULL) {
               break;
            }
         }
         
         CGPoint point = [self convertPointToCellPosition:points[i]];
         [robot setLocationX:point.x andY:point.y];
         [self performSelectorOnMainThread:@selector(setRobotPosition:) withObject:[NSValue valueWithCGPoint:points[i]] waitUntilDone:YES];
         
         [NSThread sleepForTimeInterval:t];
      }
      
      _isMoving = NO;
      
      if (points != NULL)
      {
         // maybe a subsequent search during the loop wasn't successful
         if (needToRelease)
            free(points);
      
         [goalView removeFromSuperview];
         
         [pathView setPoints:NULL count:0];
         [pathView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
      }
   }
}

int isABlock(int row, int col, int numOfRows, int numOfCols)
{
   // edges
   int isABlock = row ==0 || col == 0 || row + 1 == numOfRows || col + 1 == numOfCols;
   if (isABlock)
      return 1;
   
   // top-left room
   isABlock = (row <= 20 && col == 20) || (row == 20 && (col < 20 && (col < 7 || col > 10)));
   if (isABlock)
      return 1;
   
   // top-right roon
   isABlock = (col == 31 && row <= 11 && (row < 5 || row > 7)) || (row == 11 && col > 31 && (col < 54 || col > 57));
   if (isABlock)
      return 1;
   
   // middle-right room
   isABlock = (col == 28 && row >= 26 && row <= 45) || (row == 26 && ((col >= 28 && col <= 43) || (col >= 48))) || (col >= 44 && col <= 48 && (row == 30 || row == 31)) || (col >= 35 && col <= 39 && (row >= 39 && row <= 41)) || (row == 45 && col >= 33);
   if (isABlock)
      return 1;
   
   // mid-left 1st block
   isABlock = (row >= 25 && row <= 31 && col == 7) || (row >= 26 && row <= 30 && (col == 6 || col == 8)) || (row >= 27 && row <= 29 && (col == 9 || col == 5)) || (row == 28 && (col == 10 || col == 4));
   if (isABlock)
      return 1;
   
   // mid-left wall
   isABlock = (row == 37 && col >= 5 && col <= 22);
   if (isABlock)
      return 1;
   
   // mid-left 2nd block
   isABlock = (row >= 45 && row <= 48 && col >= 11 && col <= 18);
   if (isABlock)
      return 1;
   
   isABlock = (row == 52 && (col <= 36 || col >= 42)) || (row >= 52+5 && col == 33) || (row >= 52 && row <= numOfRows - 6 && col == 50) || (row >= 58 && row <= 62 && col >= 10 && col <= 17);
   if (isABlock)
      return 1;
      
   return 0;
}

@end
