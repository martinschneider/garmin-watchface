import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class FuzzyTimeView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        var dateString = Lang.format("$1$-$2$-$3$", [now.year, now.month.format("%02d"), now.day.format("%02d")]);
        var timeString = Lang.format("$1$:$2$", [now.hour.format("%02d"), now.min.format("%02d")]);
        var fuzzyParts = getFuzzyTimeParts(now.hour, now.min);

        var bgColor = Graphics.COLOR_BLACK;
        var dateTimeColor = 0x55aaaa;
        var minuteColor = 0xff00ff;
        var connectorColor = 0xaa00ff;
        var hourColor = 0x00aaff;

        // Clear the screen
        dc.setColor(bgColor, bgColor);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        // Scale layout based on screen size (240px is base size for FR945)
        var scale = height / 240.0;
        var dateYPos = (6 * scale).toNumber();
        var timeYPos = height - (20 * scale).toNumber();
        var lineHeight = (41 * scale).toNumber();

        // Choose font size based on screen size
        var fuzzyFont = height >= 260 ? Graphics.FONT_LARGE : Graphics.FONT_MEDIUM;

        // Draw date at top (YYYY-MM-DD format) with zero-padding
        dc.setColor(dateTimeColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            dateYPos,
            Graphics.FONT_XTINY,
            dateString,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        // Draw fuzzy time - center based on number of lines
        var centerY = height / 2;

        // Check if we have 2 or 3 lines
        var has3Lines = fuzzyParts[:minute] != null;

        if (has3Lines) {
            // Three lines: minute, connector, hour
            // Draw minute part above center
            dc.setColor(minuteColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                centerY - lineHeight,
                fuzzyFont,
                fuzzyParts[:minute],
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            // Draw connector at exact center
            dc.setColor(connectorColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                centerY,
                fuzzyFont,
                fuzzyParts[:connector],
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            // Draw hour below center
            dc.setColor(hourColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                centerY + lineHeight,
                fuzzyFont,
                fuzzyParts[:hour],
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else {
            // Two lines: hour, connector (e.g., "NINE\nO'CLOCK")
            // Center both lines around centerY
            dc.setColor(hourColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                centerY - (lineHeight / 2),
                fuzzyFont,
                fuzzyParts[:hour],
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            dc.setColor(connectorColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                centerX,
                centerY + (lineHeight / 2),
                fuzzyFont,
                fuzzyParts[:connector],
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }

        // Draw actual time at bottom (HH:MM format) with zero-padding
        dc.setColor(dateTimeColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            timeYPos,
            Graphics.FONT_XTINY,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }

    // Convert time to fuzzy text representation, returning separate parts
    function getFuzzyTimeParts(hour as Number, minute as Number) as Dictionary {
        // Round to nearest 5 minutes
        var roundedMin = ((minute + 2) / 5) * 5;

        // Adjust hour if we rounded up past 60
        if (roundedMin >= 60) {
            roundedMin = 0;
            hour = (hour + 1) % 24;
        }

        // Convert to 12-hour format
        var hour12 = hour % 12;
        if (hour12 == 0) {
            hour12 = 12;
        }

        var hourText = getHourText(hour12);

        if (roundedMin == 0) {
            return { :minute => null, :connector => "O'CLOCK", :hour => hourText };
        } else if (roundedMin <= 30) {
            var minuteText = getMinuteText(roundedMin);
            return { :minute => minuteText, :connector => "PAST", :hour => hourText };
        } else {
            // For minutes past 30, say "TO" the next hour
            var nextHour = (hour12 % 12) + 1;
            if (nextHour == 13) {
                nextHour = 1;
            }
            var nextHourText = getHourText(nextHour);
            var minuteText = getMinuteTextTo(60 - roundedMin);
            return { :minute => minuteText, :connector => "TO", :hour => nextHourText };
        }
    }

    function getHourText(hour as Number) as String {
        if (hour == 1) { return "ONE"; }
        else if (hour == 2) { return "TWO"; }
        else if (hour == 3) { return "THREE"; }
        else if (hour == 4) { return "FOUR"; }
        else if (hour == 5) { return "FIVE"; }
        else if (hour == 6) { return "SIX"; }
        else if (hour == 7) { return "SEVEN"; }
        else if (hour == 8) { return "EIGHT"; }
        else if (hour == 9) { return "NINE"; }
        else if (hour == 10) { return "TEN"; }
        else if (hour == 11) { return "ELEVEN"; }
        else { return "TWELVE"; }
    }

    function getMinuteText(minute as Number) as String {
        if (minute == 5) { return "FIVE"; }
        else if (minute == 10) { return "TEN"; }
        else if (minute == 15) { return "QUARTER"; }
        else if (minute == 20) { return "TWENTY"; }
        else if (minute == 25) { return "TWENTY FIVE"; }
        else { return "HALF"; } // 30 minutes
    }

    function getMinuteTextTo(minute as Number) as String {
        if (minute == 5) { return "FIVE"; }
        else if (minute == 10) { return "TEN"; }
        else if (minute == 15) { return "QUARTER"; }
        else if (minute == 20) { return "TWENTY"; }
        else if (minute == 25) { return "TWENTY FIVE"; }
        else { return ""; }
    }

}
