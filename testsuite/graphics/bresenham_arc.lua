do
    local origin = point.create(0, 0)
    local radius = 1000
    local grid = 100
    local pts = graphics.bresenham_arc(radius, grid)
    local ref = {
        point.create(1000,    0),
        point.create(1000,  100),
        point.create(1000,  200),
        point.create(1000,  300),
        point.create( 900,  400),
        point.create( 900,  500),
        point.create( 800,  600),
        point.create( 700,  700),
        point.create( 600,  800),
        point.create( 500,  900),
        point.create( 400,  900),
        point.create( 300, 1000),
        point.create( 200, 1000),
        point.create( 100, 1000),
        point.create(   0, 1000),
    }
    check_points(pts, ref)
end

-- if all test ran positively, we reach this point
return true
