#import "@preview/cetz:0.2.2"

// drawing
#let vector(c1, c2) = {
  import cetz.draw: *

  set-style(mark: (end:(symbol:"stealth", fill: black)))
  cetz.draw.line(c1, c2)
  set-style(mark: (end:()))
}

// Draw a inclined plane 
// - x0, y0: point 1 
// - x1, y1: point 2 
// - angle: angle of the inclined plane
#let incl-plane(r0, r1, angle, ..extras) = {
  import cetz.draw: *
  import calc: *

  let (x0, y0) = r0
  let (x1, y1) = r1

  let dx = float(x1 - x0)

  let y2 = y1 + dx * tan(angle)

  line((x0, y0), (x1, y1))
  line((x1, y1), (x1, y2))
  line((x0, y0), (x1, y2))

  let arc_rad = 1.0
  move-to(r0)
  arc((rel:(arc_rad , 0)), start: 0deg, stop: angle, name: "angle")

  let p = arc_rad + 0.25
  let px = x0 + p*cos(angle/2)
  let py = y0 + p*sin(angle/2)  

  content((px, py), $theta$, anchor: "west")

  // draw extras 
  translate((x0, y0)) 

  // draw algle
  rotate(angle)
  for e in extras.pos() {
    e
  }
  rotate(-angle)
  translate((-x0, -y0))
}

#let measure(c1, c2, label, offset: 0.25, invert: false) = {
  import cetz.draw: *
  import calc: *


  get-ctx(ctx => {
    let (ctx, r1, r2) =  cetz.coordinate.resolve(ctx, c1, c2)

    set-style(
      mark: (end: (symbol:"stealth", fill: black),
            start: (symbol:"stealth", fill: black)))
    line(r1, r2)
    
    let (x1, y1) = (r1.at(0), r1.at(1))
    let (x2, y2) = (r2.at(0), r2.at(1))
    let mid = ((x1 + x2)/2, (y1 + y2)/2)

    let angle = cetz.vector.angle2(r1, r2) + 90deg

    if invert {
      angle = angle + 180deg
    }

    move-to(mid)
    content((rel: (radius: offset, angle:angle)), label)

    set-style(mark: (end:none, start: none))
  })
}

#let angle(c, angl, label, radius: 1.0) = {
  import cetz.draw: *
  import calc: *

  set-origin(c)
  
  let lx = (radius + 0.4)*cos(angl)
  let ly = (radius + 0.2)*sin(angl)

  arc((radius, 0), start: 0deg, stop: angl, name: "angle")
  content((lx, ly), label, anchor: "north-west")
  
}

#let coordsys(origin, x_name, y_name, angle: 0) = {
  import cetz.draw: *
  import calc: *

  translate(origin)
  rotate(angle)

  vector((0,0), (1, 0))
  content((1.1,0), x_name, anchor:"west")

  vector((0,0), (0, 1))
  content((0.0,1.15), y_name, anchor:"south")

  if angle != 0 {
    line((0,0), (1,0))  
  }

  rotate(-angle)
  
  rotate(180deg)
  translate(origin)
  rotate(180deg)

}

#let spring(c1, c2, n, width: 0.2, alpha: 0.7) = {
  import cetz.draw: *
  import calc: *

  get-ctx(ctx => {
    let (ctx, r1, r2) =  cetz.coordinate.resolve(ctx, c1, c2)

    let dx = r2.at(0) - r1.at(0)
    let dy = r2.at(1) - r1.at(1)

    let angle = atan(dy/dx)

    let dl = sqrt(dx*dx + dy*dy)/(n + 3)

    // draw spring wiggles
    let x = 2*dl
    let y = 0
    
    let points = ()
    points.push((x - 2*dl,     y))
    points.push((x - dl - alpha*dl, y))

    for i in range(n + 1) {
      let p1 = (x - dl/2    , y - width)
      let p2 = (x + alpha*dl, y)
      let p3 = (x           , y + width) 
      let p4 = (x - alpha*dl, y) 

      if i < n {
        points = points + (p1, p2, p3, p4)
      }else{
        points = points + (p1, p2) 
        points.push((x + dl, y))
      }

      x = x + dl 
    }
    
    // draw
    translate(r1)
    rotate(angle)
    hobby(..points, closed: false)
    rotate(-angle)
    translate((-r1.at(0), -r1.at(1)))
  
  })

}

// draw a pandulum
#let pendulum(c, l, angle, ..extras) = {
  import cetz.draw: *
  import calc: *

  get-ctx(ctx => {
    let (ctx, p) =  cetz.coordinate.resolve(ctx, c)

    let x = p.at(0)
    let y = p.at(1)

    let x1 = x + l*sin(angle)
    let y1 = y - l*cos(angle)

    circle((x, y), radius: 0.1em, fill: black)
    line((x, y), (x1, y1))

    
    translate((x1, y1))
    if extras.pos().len() > 0 {
      for e in extras.pos() {
        e
      }
    }else {
      // draw default ball
      circle((0, 0), radius: 0.1, fill: black)
    }
    translate((-x1, -y1))
  })

}
