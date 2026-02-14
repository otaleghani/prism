import QtQuick

QtObject {
    id: logic

    property var viewDate: new Date()
    property var realToday: new Date()

    function nextMonth() {
        viewDate = new Date(viewDate.getFullYear(), viewDate.getMonth() + 1, 1);
    }

    function prevMonth() {
        viewDate = new Date(viewDate.getFullYear(), viewDate.getMonth() - 1, 1);
    }

    function thisMonth() {
        viewDate = realToday;
    }

    property var currentDays: {
        const totalSlots = 42; // 6 rows * 7 cols
        let year = viewDate.getFullYear();
        let month = viewDate.getMonth(); // 0 = Jan, 11 = Dec

        // Calculate Start Offset (Monday based)
        let firstDayIndex = new Date(year, month, 1).getDay();
        // Convert Sunday (0) to 7 so Monday (1) becomes index 0
        let startOffset = (firstDayIndex === 0 ? 7 : firstDayIndex) - 1;

        let daysInMonth = new Date(year, month + 1, 0).getDate();
        let daysInPrevMonth = new Date(year, month, 0).getDate();

        let arr = [];

        // Previous Month Padding
        for (let i = 0; i < startOffset; i++) {
            let dayNum = daysInPrevMonth - startOffset + 1 + i;

            // strict check to see if this "neighborhood" day is actually today
            // Note: 'month - 1' handles year rollover automatically in JS Date comparisons logic
            // but for simple integer comparison we need to be careful.
            // Simplest way for "isToday" on neighborhood days is full Date comparison:
            let thisDateObj = new Date(year, month - 1, dayNum);
            let isToday = (thisDateObj.toDateString() === realToday.toDateString());

            arr.push({
                day: dayNum.toString(),
                isToday: isToday,
                isCurrentMonth: false,
                neighborhoodDay: true
            });
        }

        // Current Month
        for (let i = 1; i <= daysInMonth; i++) {
            let isToday = (i === realToday.getDate() && month === realToday.getMonth() && year === realToday.getFullYear());

            arr.push({
                day: i.toString(),
                isToday: isToday,
                isCurrentMonth: true,
                neighborhoodDay: false
            });
        }

        // Next Month Padding
        // Fill the remaining slots until we hit 42
        let filledSoFar = startOffset + daysInMonth;
        let remaining = totalSlots - filledSoFar;

        for (let i = 1; i <= remaining; i++) {
            let thisDateObj = new Date(year, month + 1, i);
            let isToday = (thisDateObj.toDateString() === realToday.toDateString());

            arr.push({
                day: i.toString(),
                isToday: isToday,
                isCurrentMonth: false,
                neighborhoodDay: true
            });
        }

        return arr;
    }
}
