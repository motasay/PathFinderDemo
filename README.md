This simple demo has been built during Udacity's CS373 "Programming A Robotic Car" class. It illustrates two algorithms: 

1. A-star for building a path to a goal location.
2. A path smoothing algorithm.

You can set the goal point by double-tapping the screen, and - although somewhat difficult - you can also manipulate the maze (putting new blocks or removing existing ones) by touching the screen or sliding your finger across the screen.

### Details:

##### Parameters:
You can play with many parameters in the settings. The following is a simple description of each one:

* *Vertical/Horizontal/Diagonal cost:* These motion costs will influence the final path. In particular, they influence the path-cost function (known as the g-value or g-function), which is the cost of going from the robot's current position to another position.
* *Weigth data/smooth:* These parameters are used in the path smoothing algorithm.

##### A* Note:
* The g value is incremental, meaning that if we're moving from point *a* to point *b*, then the g-value of *b* equals the g-value of *a* plus the cost of moving from *a* to *b* in a particular direction (i.e. vertical, horizontal or diagonal).
* The hueristic function between two points *a* and *b* equals the euclidean distance between *a* and *b*.

##### Path smoothing note:
For more details on this algorithm, please see [Udacity's CS373 course](http://www.udacity.com/view#Course/cs373/CourseRev/apr2012/Unit/513063/Nugget/508048), unit 5, sections 1 through 6.

### Screenshot:

![Screenshot 1](https://dl.dropbox.com/u/1693311/udacity/pathfinder1.png)

