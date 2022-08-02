import
    utils,
    board,
    pieces


# check if the move is allowed according to the board and the pieces on the set
proc checkMove * (board: Board, pset: PieceSet, trs: Transform, team: Team): (FlagType, Transform, Rotation) {.inline.} =
    let (newtrs, rot) = board.rebound(trs)
    if newtrs.position in board:
        return (pset.getFlag(newtrs.position, team), newtrs, rot)
    (fOutOfBound, trs, 0)


# check recursively for valid position in the given direction
proc checkMoveRec * (board: Board, pset: PieceSet, trs: Transform, team: Team, dir: Vec2i): seq[Transform] =
    var trsList: seq[Transform] = @[]
    
    # prepare values that will be updated as we iterate the board
    var dir1 = dir
    var trs1 = trs + dir

    # iterate until we are out of bound, we encounter an ally or we encounter an enemy
    while true:
        let (flag, trs2, rot) = checkMove(board, pset, trs1, team)
        case flag:
            of fOutOfBound, fAlly:
                break
            of fEnemy:
                trsList.add(trs2)
                break
            of fEmpty:
                trsList.add(trs2)
        
        # adapt direction and move transform to next position
        dir1 = dir1.rotate(rot)
        trs1 = trs2 + dir1
    
    trsList
