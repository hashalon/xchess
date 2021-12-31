import
    utils


# Types
type
    Warp * = object
        zone * : Zone
        reference *, toTarget * : Vec2i
        rotate    *, toLevel  * : int

    # define the boundaries and the warps of the board
    Board * = ref object
        validZones * : seq[Zone]
        warpZones  * : seq[Warp]

    Transform * = tuple[position : Position, orientation : int]



### WARP

# check if the position is inside the zone
proc `in` * (pos : Position; warp : Warp) : bool {.inline.} =
    pos in warp.zone

proc `notin` * (pos : Position; warp : Warp) : bool {.inline.} =
    pos notin warp.zone


# transform a vector based on this warp
proc warp * (warp : Warp; pos : Position; orient : int) : Transform {.inline.} =
    let newCoords = (pos.coords - warp.reference).rotate(warp.rotate) + warp.toTarget
    let newOrient = (orient + warp.rotate) mod CARDINAL
    ((warp.zone.level, newCoords), newOrient)



### BOARD

# check if the vector is inside the board
proc `in` * (board : Board; pos : Position) : bool {.inline.} =
    for zone in board.validZones:
        if pos in zone:
            return true
    false

proc `notin` * (board : Board; pos : Position) : bool {.inline.} =
    for zone in board.validZones:
        if pos in zone:
            return false
    true


# rebound the position according to warp zones
proc rebound * (board : Board; pos : Position; orient : int) : Transform {.inline.} =
    # if the position is in a warp zone warp it
    for warp in board.warpZones:
        if pos in warp:
            return warp.warp(pos, orient)
    # else do nothing
    (pos, orient)

