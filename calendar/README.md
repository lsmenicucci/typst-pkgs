# Typst calender component

> Under development

## Usage

```typst
#import "./calendar.typ": calendar, monthweeks

// define calendar data
#let c = calendar({
    import "./calendar.typ": mark
    
    mark((day: 10, month: 4), label: "Homework assignment")
    mark((day: 6, month: 5), label: "My birthday")

}, default: (year: 2024))

// show april and may weeks
#grid(columns: (1fr, 1fr), 
    monthweeks(c, month: 4),
    monthweeks(c, month: 5)
)

// show 2018 june 
#monthweeks(c, month: 6, year: 2018)
```

