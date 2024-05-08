
// Update today's date 
#let defaultDate = (d) => {
    let now = datetime.today()
    let dayArg = d.at("day", default: now.day())
    let monthArg = d.at("month", default: now.month())
    let yearArg = d.at("year", default: now.year())

    return datetime(year: yearArg, month: monthArg, day: dayArg)
}

#let monthLength(dateLike) = {
    import calc: *

    let date = dateLike
    if type(dateLike) != "datetime"{
        date = defaultDate(dateLike)
    }

    let m = date.month()
    let y = date.year()

    if m == 2 {
        if rem(y, 4) == 0 {
            return 29
        }
        return 28
    }

    if rem(m, 2) == 0 {
        return 30
    }

    return 31

}

#let weekday_names = (
    "pt_br": ("dom", "seg", "ter", "qua", "qui", "sex", "sab"),
    "en": ("sun", "mon", "tue", "wen", "thu", "fry", "sat")
)

#let inMonthDayCell = (content) => text(fill: black)[#content]
#let offMonthDayCell = (content) => text(fill: gray)[#content]

// Draw the weeks for the indicated month
// - cal (Calendar)
#let monthWeeks(cal, month: none, year: none, ..args) = {
    import calc: *

    let date = (:)
    if month != none {
        date.insert("month", month)
    }
    if year != none {
        date.insert("year", year)
    }

    if (type(date) != "datetime"){
        date = defaultDate(date)
    }

    let n = monthLength(date)
    let prevN = monthLength(( year: date.year(), month: date.month() - 1 ))

    let thisDate = datetime(year: date.year(), month: date.month(), day: 1)
    let weekStart = thisDate.weekday()
    
    let thisAnnotations = (:)

    // separate annotations by date
    for a in cal.marks {
        if a.date.month() == thisDate.month() and a.date.year() == thisDate.year() {
            let key = str(a.date.day())
            
            let existing = thisAnnotations.at(key, default: ())
            existing.push(a)
            thisAnnotations.insert(key, existing)    
        }
    }

    // draw annotations for a day
    let drawCell = annotations => day => {
        let marks = ()

        for a in annotations.at(str(day), default: ()){
            let m = circle(radius: 0.1em, fill: black)
            marks.push(m)
        }

        let offset = marks.len() / 3

        stack(dir: ttb)[
            #day
            #grid(columns: 3, gutter: 0.1em, ..marks)
        ]
    }

    let calDays = ()
    calDays = calDays + range(prevN - weekStart + 1, prevN + 1)
                .map(drawCell((:)))
                .map(offMonthDayCell)

    calDays = calDays + range(1, n + 1)
                .map(drawCell(thisAnnotations))
                .map(inMonthDayCell)

    calDays = calDays + range(1, rem(n, 7))
                .map(drawCell((:)))
                .map(offMonthDayCell)
                
    // get header
    let lang = cal.at("lang")
    let header = weekday_names.at(lang)
    let calCells = header.map(t => pad(bottom: 0.6em)[#t]) + calDays

    grid(columns: 7, align: center, inset: 0.5em, ..calCells, ..args)
}

// mark a calendar
// - date (Datetime): date
// -> (Calendar) => void
#let mark(date, label: "", type: "") = {
    ((data) => {
        data.marks.push((date: defaultDate(date), label: label))
        return data
    },)
}

#let range(start, end, label: "", type: "") = {
    ((data) => {
        data.ranges.push((
            start: defaultDate(start),
            end: defaultDate(end), 
            label: label
        ))
        return data
    },)
}

// create a calendar data
// - ..annotations: teste
// -> Calendar
#let Calendar(..args) = {
    let data = (marks: (), ranges: ())

    for aSet in args.pos(){
        for a in aSet {
            data = a(data)
        }
    }

    data.lang = args.named().at("lang", default:"en")
    data.defaultDate = args.named().at("default", default: (:))

    return data
}


#let calendar = (d, annotations: (:) ) => calendarObj(d, calendarCell)