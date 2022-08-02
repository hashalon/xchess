import
    utils


# Types
type
    Warp * = object
        zone      * : Zone
        reference * : Vec2i 
        toTarget  * : Vec2i
        rotate    * : Rotation 
        toLevel   * : Level

    # define the boundaries and the warps of the board
    Board * = ref object
        validZones * : seq[Zone]
        warpZones  * : seq[Warp]


### WARP

# check if the position is inside the zone
proc `in`    * (pos: Position, warp: Warp): bool {.inline.} =
    pos in    warp.zone

proc `notin` * (pos: Position, warp: Warp): bool {.inline.} =
    pos notin warp.zone


# transform a vector based on this warp
proc warp * (warp: Warp, pos: Vec2i, rot: Rotation): Transform {.inline.} =
    let newPos = (pos - warp.reference).rotate(warp.rotate) + warp.toTarget
    let newRot = (rot + warp.rotate) mod CARDINAL
    ((warp.zone.level, newPos), newRot)



### BOARD

# check if the vector is inside the board
proc `in`    * (pos: Position, board: Board): bool {.inline.} =
    for zone in board.validZones:
        if pos in zone:
            return true
    false

proc `notin` * (pos: Position, board: Board): bool {.inline.} =
    for zone in board.validZones:
        if pos in zone:
            return false
    true


# rebound the position according to warp zones
proc rebound * (board: Board, trs: Transform): (Transform, Rotation) {.inline.} =
    # if the position is in a warp zone warp it
    for warp in board.warpZones:
        if trs.position in warp:
            return (warp.warp(trs.position.coords, trs.rotation), warp.rotate)
    # else do nothing
    (trs, 0)

