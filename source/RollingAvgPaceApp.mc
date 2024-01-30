import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class RollingAvgPaceApp extends Application.AppBase {
    // The total distance the activity has tracked
    var totalDistance = 0;
    //The total time the activity has tracked
    var totalTime = 0;
    // The total distance encapsulated by the window
    var windowDistance = 0;
    // The total time encapsulated by the window.
    var windowTime = 0;
    // The distance window FIFO
    var distWindow = [];
    // The time window FIFO
    var timeWindow = [];

    // The max size of the window based on distance in meters
    // Only used if isDistanceWindow is true
    var maxWindowDistance = 1609.34;
    // The max size of the window based on time in ms
    // Only used if isDistanceWindow is false
    var maxWindowTime = 5 * 60 * 1000;
    // If the window sets its max based on distance (true) or time (false) 
    var isDistanceWindow = true;

    //If the user is using km pace instead of mile pace
    var isMetric = false;
    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new RollingAvgPaceView() ] as Array<Views or InputDelegates>;
    }

}

function getApp() as SlidingAvgPaceApp {
    return Application.getApp() as SlidingAvgPaceApp;
}