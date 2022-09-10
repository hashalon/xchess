import
    utils,
    std/tables


# Types
type
    PieceType * = enum
        none = -1,
        king = 0,
        pawn,
        rook,
        knight,
        bishop,
        queen
    
    Piece * = object
        team      : Team
        pieceType : PieceType
        rotation  : Rotation
        hasMoved  : bool
    
    # container to store pieces
    PieceSet * = ref object
        pieces : Table[Position, Piece]
    
    FlagType * = enum
        outOfBound = -1,
        empty = 0,
        enemy,
        ally


# Constants
const
    noTeam = -1
    
    noPiece * = Piece(
        team      : noTeam,
        pieceType : PieceType.none,
        rotation  : 0)



### PIECE SET

# accessors
proc `[]` * (pieceSet: PieceSet, pos: Position): Piece {.inline.} =
    pieceSet.pieces.getOrDefault(pos, noPiece)

proc `[]=` * (pieceSet: var PieceSet, pos: Position, piece: Piece) {.inline.} =
    pieceSet.pieces[pos] = piece

# simply return the flag for the given cell
proc getFlag * (pieceSet: PieceSet, pos: Position, team: Team): FlagType {.inline.} =
    # try to find an other piece at that location
    let  other = pieceSet[pos].team
    if   other <= noTeam: FlagType.empty
    elif other != team  : FlagType.enemy
    else                : FlagType.ally

# generate a deep copy of the piece set
proc clone * (pieceSet: PieceSet): PieceSet {.inline.} =
    PieceSet(pieces: pieceSet.pieces)

# move a piece from a location to another
proc move * (pieceSet: var PieceSet, fromPos: Position, toPos: Position) {.inline.} =
    pieceSet[toPos  ] = pieceSet[fromPos]
    pieceSet[fromPos] = noPiece


const 
    noMoves   * : seq[Vec2i] = @[]
    cardinals * : seq[Vec2i] = @[( 1,  0), ( 0,  1), (-1,  0), ( 0, -1)]
    ordinals  * : seq[Vec2i] = @[( 1,  1), (-1,  1), (-1, -1), ( 1, -1)]
    radials   * : seq[Vec2i] = @[( 1,  0), ( 1,  1), ( 0,  1), (-1,  1), (-1,  0), (-1, -1), ( 0, -1), ( 1, -1)]
    eques     * : seq[Vec2i] = @[( 2,  1), ( 1,  2), (-1,  2), (-2,  1), (-2, -1), (-1, -2), ( 1, -2), ( 2, -1)]


# get the list of moves for the given type of piece
proc leaperDirections * (pieceType: PieceType): seq[Vec2i] {.inline.} =
    return case pieceType:
        of PieceType.king  : radials
        of PieceType.knight: eques
        else               : noMoves


# get the list of moves for the given type of piece
proc riderDirections * (pieceType: PieceType): seq[Vec2i] {.inline.} =
    return case pieceType:
        of PieceType.queen : radials
        of PieceType.bishop: ordinals
        of PieceType.rook  : cardinals
        else               : noMoves

