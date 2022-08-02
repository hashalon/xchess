import
    utils,
    board,
    pieces,
    std/sequtils


# check if the move is allowed according to the board and the pieces on the set
proc checkMove * (board: Board, pset: PieceSet, trs: Transform, team: Team): (FlagType, Transform, Rotation) =
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
            of fEmpty:
                trsList.add(trs2)
            of fEnemy:
                trsList.add(trs2)
                break
            of fOutOfBound, fAlly:
                break
        
        # adapt direction and move transform to next position
        dir1 = dir1.rotate(rot)
        trs1 = trs2 + dir1
    trsList


# return a list of positions
proc getLeaperMoves * (board: Board, pset: PieceSet, trs: Transform, team: Team, dirs: seq[Vec2i]): seq[Transform] =
    var trsList: seq[Transform] = @[]
    for dir in dirs:
        let (flag, trs1, _) = checkMove(board, pset, trs + dir, team)
        if flag == fEnemy or flag == fEmpty:
            trsList.add(trs1)
    trsList


# return a list of positions
proc getRiderMoves * (board: Board, pset: PieceSet, trs: Transform, team: Team, dirs: seq[Vec2i]): seq[Transform] =
    var metaList: seq[seq[Transform]] = @[]
    for dir in dirs:
        metaList.add(checkMoveRec(board, pset, trs, team, dir))
    concat(metaList)


# manage pawn moves differently
proc getPawnMoves * (board: Board, pset: PieceSet, trs: Transform, team: Team, rot: Rotation): seq[Transform] =
    # test the direction
    let (flagF, trsF, _) = checkMove(board, pset, trs + ( 0, 1).rotate(rot), team)
    let (flagL, trsL, _) = checkMove(board, pset, trs + (-1, 1).rotate(rot), team)
    let (flagR, trsR, _) = checkMove(board, pset, trs + ( 1, 1).rotate(rot), team)

    # generate the list of motions
    var trsList: seq[Transform] = @[]
    if flagF == fEmpty: trsList.add(trsF)
    if flagL == fEnemy: trsList.add(trsL)
    if flagR == fEnemy: trsList.add(trsR)
    trsList
    

# manage specific moves separately
# TODO...
