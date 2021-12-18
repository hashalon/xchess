import
    engine/math


# Types
type
	Warp * = object
        zone : Zone
        reference, toTarget : Vec2i
        rotate   , toLevel  : int

    # define the boundaries and the warps of the board
    Board * = ref object
        validZones : seq[Zone]
        warpZones  : seq[Warp]

    Transform * = tuple[position : Position, orientation : int]



### WARP

# check if the position is inside the zone
proc `in` * (warp : Warp; pos : Position) : bool {.inline.} =
    pos in warp.zone

proc `notin` * (warp : Warp; pos : Position) : bool {.inline.} =
    pos notin warp.zone


# transform a vector based on this warp
proc warp * (warp : Warp; pos : Position; orient : int) : Transform {.inline.} =
    let newCoords = (pos.coords - warp.reference).rotate(warp.rotate) + warp.toTarget
    let newOrient = (orient + warp.rotate) mod CARDINAL
    Transform(Position(warp.level, newCoords), newOrient)



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
    for warp in warpZones:
        if pos in warp:
            return warp.warp(pos, orient)
    # else do nothing
    Transform(pos, orient)

