import
    utils,
    board


# build a simple square board
proc makeBoard * (width, height : uint) : Board =
    let zone : Zone = (0, (VECTOR_ZERO, (width.int, height.int)))
    Board(validZones: @[zone], warpZones: @[])


# build a rollerball board
proc makeBoardRoller * (mainWidth, mainHeight, holeWidth, holeHeight : uint) : Board =
    let diffWidth  = (mainWidth  - holeWidth  ).int div 2
    let diffHeight = (mainHeight - holeHeight ).int div 2

    let sizeWidth  : Vec2i = (mainWidth.int, diffHeight    )
    let sizeHeight : Vec2i = (diffWidth    , mainHeight.int)
    let endPoint   : Vec2i = (mainWidth.int, mainHeight.int)

    Board(
        validZones: @[
            (0, ((holeWidth.int + diffWidth,   0), endPoint)), 
            (0, ((0, holeHeight.int + diffHeight), endPoint)), 
            (0, (VECTOR_ZERO, sizeHeight)), 
            (0, (VECTOR_ZERO, sizeWidth ))
        ], 
        warpZones: @[]
    )


# build a circular board
proc makeBoardCircle * (radius, perimeter : uint) : Board =
    let size : Vec2i = (perimeter.int, radius.int)
    let zone : Zone  = (0, (VECTOR_ZERO, size))

    let refLeft : Vec2i = (-perimeter.int, radius.int)
    let warpLeft = Warp(
        zone      : (0, (refLeft, refLeft + size)),
        reference : refLeft,
        toTarget  : VECTOR_ZERO,
        rotate    : 0,
        toLevel   : 0
    )

    let warpRight = Warp(
        zone      : (0, (size, size * 2)),
        reference : size,
        toTarget  : VECTOR_ZERO,
        rotate    : 0,
        toLevel   : 0
    )

    Board(
        validZones : @[zone], 
        warpZones  : @[warpLeft, warpRight]
    )


# build a polygonal board -> mostly hexagon boards
proc makeBoardPolygon * (radius, numberOfSides : uint) : Board =
    let size     : Vec2i = (radius.int, radius.int)
    let refTop   : Vec2i = (0         , radius.int)
    let refRight : Vec2i = (radius.int, 0         )

    let rectCenter : Rec2i = (VECTOR_ZERO, size)
    let rectTop    : Rec2i = (refTop     , refTop   + size)
    let rectRight  : Rec2i = (refRight   , refRight + size)

    # build each of the 6 panels
    let nbSides = numberOfSides.int
    for l in 0 ..< nbSides:

        result.warpZones.add(Warp(
            zone      : (l, rectTop),
            reference : refTop,
            toTarget  : refRight,
            rotate    : 1,
            toLevel   : (nbSides + l - 1) mod nbSides
        ))

        result.warpZones.add(Warp(
            zone      : (l, rectRight),
            reference : refRight,
            toTarget  : refTop,
            rotate    : -1,
            toLevel   : (nbSides + l + 1) mod nbSides
        ))

        result.validZones.add((l, rectCenter))



# build a singular board
# TODO implement a parameter to indicate how many rows are not affected by the singularity
proc makeBoardSingular (width, numberOfSides : uint) : Board =
    let half = width.int div 2

    # build the pyramid template first
    var pyramid = newSeq[Rec2i](width - 2)
    pyramid[0] = (VECTOR_ZERO, (width.int, 1))
    for i in 1 .. len(pyramid):
        pyramid[i] = ((i, i), (width.int - i + 1, i + 1))
    
    let centerPoint : Vec2i = (half, half)

    # generate each panel of the board (2)
    let nbSides = numberOfSides.int
    for l in 0 ..< nbSides:

        result.warpZones.add(Warp(
            zone      : (l, (VECTOR_ZERO, (half, width.int))),
            reference : centerPoint,
            toTarget  : centerPoint,
            rotate    : 1,
            toLevel   : (nbSides + l - 1) mod nbSides
        ))

        result.warpZones.add(Warp(
            zone      : (l, ((half, 0), (width.int, width.int))),
            reference : centerPoint,
            toTarget  : centerPoint,
            rotate    : -1,
            toLevel   : (nbSides + l + 1) mod nbSides
        ))

        for row in pyramid:
            result.validZones.add((l, row))

