import
    utils,
    std/tables


# Types
type
    PieceType * = enum
        tNone = -1,
        tKing = 0,
        tPawn,
        tRook,
        tKnight,
        tBishop,
        tQueen
    
    Piece * = object
        team        : int
        pieceType   : PieceType
        orientation : int
    
    # container to store pieces
    PieceSet * = ref object
        pieces : Table[Position, Piece]
    
    CellFlag * = enum
        cfOutOfBound = -1,
        cfEmpty = 0,
        cfEnemy,
        cfAlly


# Constants
const
    NO_TEAM  = -1
    
    NO_PIECE * = Piece(
        team        : NO_TEAM,
        pieceType   : tNone,
        orientation : 0)



### PIECE SET

# accessors
proc `[]` * (pset : PieceSet; pos : Position) : Piece {.inline.} =
    pset.pieces.getOrDefault(pos, NO_PIECE)

proc `[]=` * (pset : var PieceSet; pos : Position; piece : Piece) {.inline.} =
    pset.pieces[pos] = piece

# simply return the flag for the given cell
proc getFlag * (pset : PieceSet; pos : Position, team : int) : CellFlag {.inline.} =
    # try to find an other piece at that location
    let  other = pset[pos].team
    if   other <= NO_TEAM: cfEmpty
    elif other != team   : cfEnemy
    else                 : cfAlly

