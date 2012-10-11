
@class GridView;

@interface ViewController : UIViewController {
   GridView *grid;
   
   int verticalCost, horizontalCost, diagonalCost;
   float movementSpeed, weightData, weightSmooth;
   
   NSMutableArray *touchesCache;
}

@property (retain, nonatomic) IBOutlet UIButton *planButton;
@property (retain, nonatomic) IBOutlet UIButton *smoothButton;
@property (retain, nonatomic) IBOutlet UIButton *moveButton;

- (IBAction)plan:(id)sender;
- (IBAction)smooth:(id)sender;
- (IBAction)move:(id)sender;

@property (retain, nonatomic) IBOutlet UIView *settingsView;
@property (retain, nonatomic) IBOutlet UIButton *settingsButton;
- (IBAction)showSettings:(id)sender;

@property (retain, nonatomic) IBOutlet UILabel *verticalCostLabel;
@property (retain, nonatomic) IBOutlet UILabel *horizontalCostLabel;
@property (retain, nonatomic) IBOutlet UILabel *diagonalCostLabel;
@property (retain, nonatomic) IBOutlet UILabel *weightDataLabel;
@property (retain, nonatomic) IBOutlet UILabel *weightSmoothLabel;
@property (retain, nonatomic) IBOutlet UILabel *movementSpeedLabel;

@property (retain, nonatomic) IBOutlet UISlider *verticalCostSlider;
@property (retain, nonatomic) IBOutlet UISlider *horizontalCostSlider;
@property (retain, nonatomic) IBOutlet UISlider *diagonalCostSlider;
@property (retain, nonatomic) IBOutlet UISlider *weightDataSlider;
@property (retain, nonatomic) IBOutlet UISlider *weightSmoothSlider;
@property (retain, nonatomic) IBOutlet UISlider *movementSpeedSlider;

- (IBAction)saveSettings:(id)sender;
- (IBAction)verticalCostChanged:(id)sender;
- (IBAction)horizontalCostChanged:(id)sender;
- (IBAction)diagonalCostChanged:(id)sender;
- (IBAction)weightDataChanged:(id)sender;
- (IBAction)weightSmoothChanged:(id)sender;
- (IBAction)movementSpeedChanged:(id)sender;

@end
