import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class FuzzyTimeApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new FuzzyTimeView() ];
    }

}

function getApp() as FuzzyTimeApp {
    return Application.getApp() as FuzzyTimeApp;
}
