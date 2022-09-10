import
    utils,
    board,
    pieces,
    std/sequtils


# check if the move is allowed according to the board and the pieces on the set
proc checkMove * (board: Board, pieceSet: PieceSet, trs: Transform, team: Team): (FlagType, Transform, Rotation) =
    let (newTrs, rot) = board.rebound(trs)
    if newTrs.position in board:
        return (pieceSet.getFlag(newTrs.position, team), newTrs, rot)
    (FlagType.outOfBound, trs, 0)


# check recursively for valid position in the given direction
proc checkMoveRec * (board: Board, pieceSet: PieceSet, trs: Transform, team: Team, dir: Vec2i): seq[Transform] =
    var trsList: seq[Transform] = @[]
    
    # prepare values that will be updated as we iterate the board
    var dir1 = dir
    var trs1 = trs + dir

    # iterate until we are out of bound, we encounter an ally or we encounter an enemy
    while true:
        let (flag, trs2, rot) = checkMove(board, pieceSet, trs1, team)
        case flag:
            of FlagType.empty:
                trsList.add(trs2)
            of FlagType.enemy:
                trsList.add(trs2)
                break
            of FlagType.outOfBound, FlagType.ally:
                break
        
        # adapt direction and move transform to next position
        dir1 = dir1.rotate(rot)
        trs1 = trs2 + dir1
    trsList


# return a list of positions
proc getLeaperMoves * (board: Board, pieceSet: PieceSet, trs: Transform, team: Team, dirs: seq[Vec2i]): seq[Transform] =
    var trsList: seq[Transform] = @[]
    for dir in dirs:
        let (flag, trs1, _) = checkMove(board, pieceSet, trs + dir, team)
        if flag == FlagType.enemy or flag == FlagType.empty:
            trsList.add(trs1)
    trsList


# return a list of positions
proc getRiderMoves * (board: Board, pieceSet: PieceSet, trs: Transform, team: Team, dirs: seq[Vec2i]): seq[Transform] =
    var metaList: seq[seq[Transform]] = @[]
    for dir in dirs:
        metaList.add(checkMoveRec(board, pieceSet, trs, team, dir))
    concat(metaList)


# manage pawn moves differently
proc getPawnMoves * (board: Board, pieceSet: PieceSet, trs: Transform, team: Team, rot: Rotation): seq[Transform] =
    # test the direction
    let (flagF, trsF, _) = checkMove(board, pieceSet, trs + ( 0, 1).rotate(rot), team)
    let (flagL, trsL, _) = checkMove(board, pieceSet, trs + (-1, 1).rotate(rot), team)
    let (flagR, trsR, _) = checkMove(board, pieceSet, trs + ( 1, 1).rotate(rot), team)

    # generate the list of motions
    var trsList: seq[Transform] = @[]
    if flagF == FlagType.empty: trsList.add(trsF)
    if flagL == FlagType.enemy: trsList.add(trsL)
    if flagR == FlagType.enemy: trsList.add(trsR)
    trsList
    

# manage specific moves separately
# TODO...


proc getEnPassant * (board: Board, pieceSet: PieceSet, trs: Transform, team: Team): seq[Transform] =
    return

proc getCastling * (board: Board, pieceSet: PieceSet, trs: Transform, team: Team): seq[Transform] =
    return

proc getPromotion * (board: Board, pieceSet: PieceSet, trs: Transform, team: Team): seq[Transform] =
    return


proc getMoves * (board: Board, pieceSet: PieceSet, trs: Transform, team: Team, pieceType: PieceType): seq[Transform] =
    if pieceType == PieceType.pawn:
        return @[]
    
    # get moves for the other types of pieces
    let movesLeaper = getLeaperMoves(board, pieceSet, trs, team, leaperDirections(pieceType))
    let movesRider  =  getRiderMoves(board, pieceSet, trs, team,  riderDirections(pieceType))

    return movesLeaper & movesRider



