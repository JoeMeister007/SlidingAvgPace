import Toybox.Activity;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;
import Toybox.WatchUi;

class RollingAvgPaceView extends WatchUi.SimpleDataField {
    //the app
    var app;

    //the number of compute iterations without updating the pace
    var iterationsWOUpdate = 0;
    //the max number of compute iterations without updating the pace
    var maxIterationsWOUpdate = 6;

    var previousValue = "";

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Rolling Avg.";
        app = Application.getApp();
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        // See Activity.Info in the documentation for available information.

        //null check (for when things haven't been initialized yet)
        if (info.elapsedDistance == null || info.elapsedTime == null) {
            return "--:--";
        }

        //This bit is weird, but the distance doesn't always update every second
        //unlike time which causes some oscillations
        //a hasty observation identified 6 iterations as a decent upperbound of the
        //number of same distances before an update
        if (info.elapsedDistance == app.totalDistance) {
            iterationsWOUpdate++;
            //If this would be our 7th iteration without an update, assume
            //standing still
            if (iterationsWOUpdate > maxIterationsWOUpdate) {
                iterationsWOUpdate = 0;
            }
            else { //otherwise return what we did last time
                return previousValue;
            }
        }

        

        System.println("hi");

        //find distance gained this iteration
        var stepDist = info.elapsedDistance - app.totalDistance; //this is in m
        app.totalDistance = info.elapsedDistance;

        //Add that distance to our window/queue
        app.windowDistance += stepDist;
        app.distWindow.add(stepDist);

        //find time gained this iteration
        var stepTime = info.timerTime - app.totalTime; //this is in km
        app.totalTime = info.timerTime;//timeTime instead of elapsed time so pausing works

        //Add that time to our window/queue
        app.windowTime += stepTime;
        app.timeWindow.add(stepTime);


        //If we're dictating window size by a certain distance
        //remove the oldest data points from the front until we're under that
        //distance
        while (app.isDistanceWindow && app.windowDistance > app.maxWindowDistance) {
            //get the removed distance and time
            var removedDist = app.distWindow[0];
            var removedTime = app.timeWindow[0];

            //remove them from their queues
            //(should keep track of how many elements we need to remove and remove out
            //of the loop for better efficiency)
            app.distWindow = app.distWindow.slice(1, null);
            app.timeWindow = app.timeWindow.slice(1, null);

            app.windowDistance -= removedDist;
            app.windowTime -= removedTime;
        }

        //If we're dictating window size by a certain time
        //remove the oldest data points from the front until we're under that
        //time
        while (!app.isDistanceWindow && app.windowTime > app.maxWindowTime) {
            //get the removed distance and time
            var removedDist = app.distWindow[0];
            var removedTime = app.timeWindow[0];

            //remove them from their queues
            //(should keep track of how many elements we need to remove and remove out
            //of the loop for better efficiency)
            app.distWindow = app.distWindow.slice(1, null);
            app.timeWindow = app.timeWindow.slice(1, null);

            app.windowDistance -= removedDist;
            app.windowTime -= removedTime;
        }


        //We're now at the desired window size (or still building up to it)
        //Calculate the pace
        System.println(app.windowTime);
        System.println(app.windowDistance);

        if (app.windowDistance <= 0) {
            return "--:--";
        }
        var pace = app.windowTime / 1000 / app.windowDistance; //seconds per meter

        //convert seconds per meter to seconds per kilometer or seconds per mile
        if (app.isMetric) {
            pace *= 1000;
        }
        else {
            pace *= 1609.34;
        }
        // round the pace to match actual average
        pace = Math.round(pace); 
        // get the minutes part of the pace
        var minutesPart = Math.floor(pace / 60);
        //get the seconds part of the pace
        var secondsPart = pace.toNumber() % 60;

        //return a formatted string representing the pace
        previousValue = Lang.format("$1$:$2$",[minutesPart.format("%02d"), secondsPart.format("%02d")]);
        return previousValue;
    }

}