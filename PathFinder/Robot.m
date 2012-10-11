#import "Robot.h"

#define NUM_OF_MOVES 8
#define NOT_EXPANDED -1
#define BLOCK_FLAG 9999 // This must be > world_y_max * world_x_max

@implementation Robot

@synthesize x, y;

- (id)initInWorld:(int **)world
        worldSize:(CGSize)aSize
 withVerticalCost:(int)vc
   horizontalCost:(int)hc
     diagonalCost:(int)dc
{
   self = [super init];
   if (self) {
      world_y_max = aSize.height;
      world_x_max = aSize.width;
      
      expandedCells = malloc(world_y_max * sizeof(int *));
      for (int row = 0; row < world_y_max; row++) {
         expandedCells[row] = malloc(world_x_max * sizeof(int));
      }
      
      moves = malloc(NUM_OF_MOVES * sizeof(int *));
      for (int i = 0; i < NUM_OF_MOVES; i++) {
         moves[i] = malloc(2 * sizeof(int));
      }

      moves[0][0] =  0; // top
      moves[0][1] = -1;
      moves[2][0] =  1; // right
      moves[2][1] =  0;
      moves[4][0] =  0; // down
      moves[4][1] =  1;
      moves[6][0] = -1; // left
      moves[6][1] =  0;

      moves[1][0] =  1; // top-right
      moves[1][1] = -1;
      moves[3][0] =  1; // down-right
      moves[3][1] =  1;
      moves[5][0] = -1; // down-left
      moves[5][1] =  1;
      moves[7][0] = -1; // top-left
      moves[7][1] = -1;
      
      moves_costs = malloc(NUM_OF_MOVES * sizeof(int));
      moves_costs[0] = vc;
      moves_costs[2] = hc;
      moves_costs[4] = vc;
      moves_costs[6] = hc;
      
      moves_costs[1] = dc;
      moves_costs[3] = dc;
      moves_costs[5] = dc;
      moves_costs[7] = dc;      
   }
   return self;
}

- (void)dealloc
{
   for (int i = 0; i < NUM_OF_MOVES; i++) {
      free(moves[i]);
   }
   free(moves);
   free(moves_costs);
   for (int row = 0; row < world_y_max; row++) {
      free(expandedCells[row]);
   }
   free(expandedCells);
   [super dealloc];
}

- (UIImage *) image
{
   return [UIImage imageNamed:@"robot.png"];
}

- (void)setLocationX:(int)aX andY:(int)aY
{
   x = aX;
   y = aY;
}

- (void) setVerticalCost:(int)vc
          horizontalCost:(int)hc
            diagonalCost:(int)dc
{
   moves_costs[0] = vc;
   moves_costs[2] = hc;
   moves_costs[4] = vc;
   moves_costs[6] = hc;
   
   moves_costs[1] = dc;
   moves_costs[3] = dc;
   moves_costs[5] = dc;
   moves_costs[7] = dc;
}

- (NSArray *)getPlanToLocation:(CGPoint)goal inWorld:(int **)world
{
   [self resetExpandedCellsWithWorld:world];

   // A* search, start from (self.x, self.y) to goal
   // Each node have four elements:
   // 1. The g-value
   // 2. The value of the hueristic function
   // 3. The x position
   // 4. The y position
   NSMutableArray *openNodes = [[NSMutableArray alloc] initWithCapacity:5];
   [openNodes addObject:[NSArray arrayWithObjects:
                         [NSNumber numberWithFloat:0.0f],
                         [NSNumber numberWithFloat:distanceBetweenPoints(x, y, goal.x, goal.y)],
                         [NSNumber numberWithInt:x],
                         [NSNumber numberWithInt:y],
                         nil]];
   
   int found = 0, counter = 0;
   while (!found) {
      
      // Pick the element in openNodes with the lowest cost, where cost = gVal + heuristic

      NSArray *nodeWithLowestCost = nil;
      float lowestCost;
      for (NSArray *node in openNodes) {
         
         float nodeCost = [[node objectAtIndex:0] floatValue] + [[node objectAtIndex:1] floatValue];
         
         if (!nodeWithLowestCost)
         {
            nodeWithLowestCost = node;
            lowestCost = nodeCost;
         }
         else if (nodeCost < lowestCost)
         {
            nodeWithLowestCost = node;
            lowestCost = nodeCost;
         }
      }

      // Remove the picked node from openNodes
      [openNodes removeObject:nodeWithLowestCost];
      
      int nodeWithLowestCostX = [[nodeWithLowestCost objectAtIndex:2] intValue];
      int nodeWithLowestCostY = [[nodeWithLowestCost objectAtIndex:3] intValue];
      
      expandedCells[nodeWithLowestCostY][nodeWithLowestCostX] = counter++;
      
      // Add all of the adjacent cells to openNodes
      for (int i = 0; i < NUM_OF_MOVES; i++) {

         int newX = nodeWithLowestCostX + moves[i][0];
         int newY = nodeWithLowestCostY + moves[i][1];
         
         int isALegalMove = newX >= 0 && newX < world_x_max && newY >= 0 && newY < world_y_max && expandedCells[newY][newX] == NOT_EXPANDED && expandedCells[newY][newX] != BLOCK_FLAG;
         if (isALegalMove)
         {
            expandedCells[newY][newX] = counter++;
            
            // If this is the goal, stop
            if (newX == goal.x && newY == goal.y) {
               found = 1;
               break;
            }
            
            float oldGVal = [[nodeWithLowestCost objectAtIndex:0] floatValue];
            
            float gVal = oldGVal + moves_costs[i];
            float hVal = distanceBetweenPoints(newX, newY, goal.x, goal.y);
            
            [openNodes addObject:[NSArray arrayWithObjects:
                                  [NSNumber numberWithInt:gVal],
                                  [NSNumber numberWithInt:hVal],
                                  [NSNumber numberWithInt:newX],
                                  [NSNumber numberWithInt:newY],
                                  nil]];
         }
      }
      
      if ([openNodes count] == 0) {
         break;
      }      
   }

   [openNodes release];
   if (!found) {
      return nil;
   }
   
//   print(expandedCells, world_y_max, world_x_max);
   
   // Using the values in expandedCells, build the plan by starting from the goal,
   // and going to the adjacent cell with the lowest counter value, until we reach
   // the current position
   NSMutableArray *plan = [[NSMutableArray alloc] init];
   
   int currentX = goal.x;
   int currentY = goal.y;
   [plan addObject:[NSValue valueWithCGPoint:CGPointMake(currentX, currentY)]];
   int done = 0;
   while (!done)
   {
      
      int nextX, nextY;
      int counter = expandedCells[currentY][currentX];
      for (int i = 0; i < NUM_OF_MOVES; i++) {
         int *move = moves[i];
         int newX = currentX + move[0];
         int newY = currentY + move[1];
         
         int isALegalMove = newX >= 0 && newX < world_x_max && newY >= 0 && newY < world_y_max && expandedCells[newY][newX] != NOT_EXPANDED && expandedCells[newY][newX] != BLOCK_FLAG;
         if (isALegalMove && expandedCells[newY][newX] < counter)
         {
            counter = expandedCells[newY][newX];
            nextX = newX;
            nextY = newY;
         }
      }
      
      currentX = nextX;
      currentY = nextY;
      
      [plan addObject:[NSValue valueWithCGPoint:CGPointMake(currentX, currentY)]];

      if (currentX == x && currentY == y) {
         done = 1;
      }
   }
   
   NSArray* reversedPlan = [[plan reverseObjectEnumerator] allObjects];
   [plan release];
   
   return reversedPlan;
}

- (void)smoothPoints:(CGPoint *)originalPoints
            toBuffer:(CGPoint *)buffer
         numOfPoints:(int)numOfPoints
          weightData:(float)weightData
        weightSmooth:(float)weightSmooth
           tolerance:(float)tolerance
             inWorld:(int **)world
{
   // 1. deep copy the original points to the buffer
   for (int i = 0; i < numOfPoints; i++) {
      buffer[i] = CGPointMake(originalPoints[i].x, originalPoints[i].y);
   }
   
   // 2. Gradient descent
   float error = tolerance;
   while (error >= tolerance)
   {
      
      error = 0.0f;
      
      for (int i = 2; i < numOfPoints - 2; i++)
      {
         CGPoint smoothPoint   = buffer[i];
         CGPoint originalPoint = originalPoints[i];
         CGPoint nextSmoothPoint = buffer[i+1];
         CGPoint prevSmoothPoint = buffer[i-1];
         CGPoint nextNextSmoothPoint = buffer[i+2];
         CGPoint prevPrevSmoothPoint = buffer[i-2];
         
         // If this point is adjacent to a block, then don't do anything to avoid putting the path on a block
         // This could be improved by avoiding fixing points near blocks that are not in the middle of two points
         // in the path.
         int shouldSkip = 0;
         int point_x = originalPoint.x;
         int point_y = originalPoint.y;
         if (point_x > 0)
            shouldSkip = world[point_y][point_x-1];
         if (!shouldSkip && point_x < world_x_max - 1)
            shouldSkip = world[point_y][point_x+1];
         if (!shouldSkip && point_y > 0)
            shouldSkip = world[point_y-1][point_x];
         if (!shouldSkip && point_y < world_y_max - 1)
            shouldSkip = world[point_y+1][point_x];
         if (!shouldSkip && point_x > 0 && point_y > 0)
            shouldSkip = world[point_y-1][point_x-1];
         if (!shouldSkip && point_x > 0 && point_y < world_y_max - 1)
            shouldSkip = world[point_y+1][point_x-1];
         if (!shouldSkip && point_x < world_x_max - 1 && point_y > 0)
            shouldSkip = world[point_y-1][point_x-1];
         if (!shouldSkip && point_x < world_x_max - 1 && point_y < world_y_max - 1)
            shouldSkip = world[point_y+1][point_x+1];
         if (shouldSkip)
            continue;
         
         // manipulate the coordinates
         float newXCoordinate = smootherCoordinate(smoothPoint.x, originalPoint.x, prevSmoothPoint.x, nextSmoothPoint.x, prevPrevSmoothPoint.x, nextNextSmoothPoint.x, weightData, weightSmooth);
         float newYCoordinate = smootherCoordinate(smoothPoint.y, originalPoint.y, prevSmoothPoint.y, nextSmoothPoint.y, prevPrevSmoothPoint.y, nextNextSmoothPoint.y, weightData, weightSmooth);
         
         // Update the error
         float diff = smoothPoint.x - newXCoordinate;
         error += (diff * diff);
         diff = smoothPoint.y - newYCoordinate;
         error += (diff * diff);
         
         buffer[i] = CGPointMake(newXCoordinate, newYCoordinate);
      }
   }
   
}

- (void) resetExpandedCellsWithWorld:(int **)world
{
   for (int row = 0; row < world_y_max; row++) {
      for (int col = 0; col < world_x_max; col++) {
         if (world[row][col])
            expandedCells[row][col] = BLOCK_FLAG;
         else
            expandedCells[row][col] = NOT_EXPANDED;
      }
   }
}

float distanceBetweenPoints(int x1, int y1, int x2, int y2)
{
   int xDiff = x1 - x2;
   int yDiff = y1 - y2;
   
   return sqrtf(xDiff * xDiff + yDiff * yDiff);
}

float smootherCoordinate(float originalCoordinate, float smoothCoordinate, float prevSmoothCoord, float nextSmoothCoord, float prevPrevSmoothCoord, float nextNextSmoothCoord, float weightData, float weightSmooth)
{
   float newCoordinate = smoothCoordinate + weightData * (originalCoordinate - smoothCoordinate);
   newCoordinate = newCoordinate + weightSmooth * (prevSmoothCoord + nextSmoothCoord - (2.0f * newCoordinate));
   
   newCoordinate = newCoordinate + 0.5f * weightSmooth * (2.0f * prevSmoothCoord - prevPrevSmoothCoord - newCoordinate);
   newCoordinate = newCoordinate + 0.5f * weightSmooth * (2.0f * nextSmoothCoord - nextNextSmoothCoord - newCoordinate);
   return newCoordinate;
}

void print(int **arr, int y, int x)
{
   for (int i = 0; i < y; i++) {
      for (int j = 0; j < x; j++) {
         printf("%-5d", arr[i][j]);
      }
      printf("\n");
   }
}

//int numOfBlocksOnLine(int x1, int y1, int x2, int y2, int **world)
//{
//   int blocksCounter = 0;
//   
//   if (x1 != x2)
//   {
//      // 5 is the size of each cell
//      float xReal1 = x1 * 5.0f + 5.0f / 2.0f;
//      float yReal1 = y1 * 5.0f + 5.0f / 2.0f;
//      float xReal2 = x2 * 5.0f + 5.0f / 2.0f;
//      float yReal2 = y2 * 5.0f + 5.0f / 2.0f;
//      
//      // go from (x1,y1) to (x2, y2) by changing x
//      float slope = (yReal1 - yReal2) / (xReal1 - xReal2);
//      float intercept = yReal1 - slope * xReal1;
//      
//      float xChange = 5.0f;
//      if (xReal1 > xReal2)
//         xChange = -5.0f;
//      
//      xReal1 += xChange;
//      yReal1 = slope * xReal1 + intercept;
//      
//      int xIndex = floorf(xReal1 / 5.0f) + 0.5f;
//      int yIndex = floorf(yReal1 / 5.0f) + 0.5f;
//      while (xIndex != x2 || yIndex != y2)
//      {
//         if (world[yIndex][xIndex]) {
//            blocksCounter++;
//         }
//         
//         xReal1 += xChange;
//         yReal1 = slope * xReal1 + intercept;
//         
//         xIndex = floorf(xReal1 / 5.0f) + 0.5f;
//         yIndex = floorf(yReal1 / 5.0f) + 0.5f;
//      }
//   }
//   else
//   {
//      // vertical line, slope==0.0f, x is fixed.
//      
//      int yChange = 1;
//      if (y1 > y2)
//         yChange = -1;
//      
//      int yIndex = y1 + yChange;
//      
//      while (yIndex != y2)
//      {
//         if (world[yIndex][x1]) {
//            blocksCounter++;
//         }
//         yIndex += yChange;
//      }
//   }
//   
//   
//   return blocksCounter;
//}

@end
