#import "ViewController.h"
#import "Robot.h"
#import "GridView.h"

#define MAX_MOVE_SPEED 10

@implementation ViewController

- (void)viewDidLoad {
   [super viewDidLoad];
	
   self.settingsView.hidden = YES;
   
   // Default parameters.
   verticalCost   = 1;
   horizontalCost = 1;
   diagonalCost   = 3;
   movementSpeed  = MAX_MOVE_SPEED;
   weightData     = 0.1f;
   weightSmooth   = 0.1f;
   
   self.verticalCostSlider.minimumValue = 1;
   self.verticalCostSlider.maximumValue = 20;
   
   self.horizontalCostSlider.minimumValue = 1;
   self.horizontalCostSlider.maximumValue = 20;
      
   self.diagonalCostSlider.minimumValue = 1;
   self.diagonalCostSlider.maximumValue = 20;
   
   self.movementSpeedSlider.minimumValue = 1;
   self.movementSpeedSlider.maximumValue = MAX_MOVE_SPEED;
   
   self.weightDataSlider.minimumValue = 0.0f;
   self.weightDataSlider.maximumValue = 1.0f;
   self.weightSmoothSlider.minimumValue = 0.0f;
   self.weightSmoothSlider.maximumValue = 1.0f;
   
   grid = nil;
   [self initGrid];
   
   touchesCache = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload {
   [super viewDidUnload];
   [touchesCache release];
   [grid release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) initGrid {
   if (grid) {
      [grid removeFromSuperview];
      [grid release];
   }
   
   CGRect gridFrame    = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 100); // 100 for the controls view
   grid = [[GridView alloc] initWithFrame:gridFrame];
   
   // Listen for a double tap for setting goal locations
   UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setGoalPoint:)];
   doubleTap.numberOfTapsRequired = 2;
   [grid addGestureRecognizer:doubleTap];
   [doubleTap release];
   
   // Init a robot with the costs
   Robot *obj = [[Robot alloc] initInWorld:[grid world]
                                 worldSize:[grid worldSize]
                          withVerticalCost:verticalCost
                            horizontalCost:horizontalCost
                              diagonalCost:diagonalCost];
   

   // Add the robot to the grid.
   [grid addRobot:obj];
   [obj release];
   
   // Display the grid.
   [self.view addSubview:grid];
   [self.view bringSubviewToFront:grid];
}

- (IBAction)plan:(id)sender
{
   [grid letRobotPlan];
}

- (IBAction)smooth:(id)sender
{
   [grid letRobotSmoothPlanWithWeightData:weightData weightSmooth:weightSmooth tolerance:0.000000001f];
}

- (IBAction)move:(id)sender
{
   float ratio = (1.0f * movementSpeed / MAX_MOVE_SPEED);
   float sleepTimeBetweenSleep = (1.0f - ratio) + 0.1f;
   [grid performSelectorInBackground:@selector(letRobotMoveWithSleepTime:) withObject:[NSNumber numberWithFloat:sleepTimeBetweenSleep]];
}

- (void)setGoalPoint:(UIGestureRecognizer *)gesture {
   CGPoint goalLocation = [gesture locationInView:grid];
   [grid setGoal:goalLocation];
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
   // cache the points
   [touchesCache addObject:[NSValue valueWithCGPoint:[[touches anyObject] locationInView:grid]]];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
   // cache the points
   [touchesCache addObject:[NSValue valueWithCGPoint:[[touches anyObject] locationInView:grid]]];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
   [touchesCache removeAllObjects];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   
   int numOfTouches = [touchesCache count];
   if (numOfTouches > 0) {
      CGPoint *points  = malloc(numOfTouches * sizeof(CGPoint));
      int i = 0;
      for (NSValue *value in touchesCache) {
         points[i] = [value CGPointValue];
         i++;
      }
      
      // Send them to the grid
      [grid setBlocksForPoints:points count:numOfTouches];
      
      [touchesCache removeAllObjects];
      
      free(points);
   }
}

- (IBAction)showSettings:(id)sender {
   [self.view bringSubviewToFront:self.settingsView];

   [self.verticalCostLabel setText:[NSString stringWithFormat:@"%d", verticalCost]];
   [self.diagonalCostLabel setText:[NSString stringWithFormat:@"%d", diagonalCost]];
   [self.horizontalCostLabel setText:[NSString stringWithFormat:@"%d", horizontalCost]];
   [self.movementSpeedLabel setText:[NSString stringWithFormat:@"%.1f", movementSpeed]];
   [self.weightDataLabel setText:[NSString stringWithFormat:@"%.1f", weightData]];
   [self.weightSmoothLabel setText:[NSString stringWithFormat:@"%.1f", weightSmooth]];
   
   [self.verticalCostSlider setValue:verticalCost];
   [self.diagonalCostSlider setValue:diagonalCost];
   [self.horizontalCostSlider setValue:horizontalCost];
   [self.movementSpeedSlider setValue:movementSpeed];
   [self.weightDataSlider setValue:weightData];
   [self.weightSmoothSlider setValue:weightSmooth];
   
   self.settingsView.hidden = NO;
}

- (IBAction)saveSettings:(id)sender {
   [grid.robot setVerticalCost:verticalCost horizontalCost:horizontalCost diagonalCost:diagonalCost];
   self.settingsView.hidden = YES;
}

- (IBAction)verticalCostChanged:(id)sender {
   verticalCost = (int) ((UISlider *)sender).value;
   [self.verticalCostLabel setText:[NSString stringWithFormat:@"%d", verticalCost]];
}

- (IBAction)diagonalCostChanged:(id)sender {
   diagonalCost = ((UISlider *)sender).value;
   [self.diagonalCostLabel setText:[NSString stringWithFormat:@"%d", diagonalCost]];
}

- (IBAction)horizontalCostChanged:(id)sender {
   horizontalCost = ((UISlider *)sender).value;
   [self.horizontalCostLabel setText:[NSString stringWithFormat:@"%d", horizontalCost]];
}

- (IBAction)weightDataChanged:(id)sender
{
   weightData = ((UISlider *)sender).value;
   [self.weightDataLabel setText:[NSString stringWithFormat:@"%.1f", weightData]];
}

- (IBAction)weightSmoothChanged:(id)sender
{
   weightSmooth = ((UISlider *)sender).value;
   [self.weightSmoothLabel setText:[NSString stringWithFormat:@"%.1f", weightSmooth]];
}

- (IBAction)movementSpeedChanged:(id)sender {
   movementSpeed = ((UISlider *)sender).value;
   [self.movementSpeedLabel setText:[NSString stringWithFormat:@"%.1f", movementSpeed]];
}
@end
