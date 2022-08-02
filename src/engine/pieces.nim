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
        team      : Team
        pieceType : PieceType
        rotation  : Rotation
    
    # container to store pieces
    PieceSet * = ref object
        pieces : Table[Position, Piece]
    
    FlagType * = enum
        fOutOfBound = -1,
        fEmpty = 0,
        fEnemy,
        fAlly


# Constants
const
    NO_TEAM  = -1
    
    NO_PIECE * = Piece(
        team      : NO_TEAM,
        pieceType : tNone,
        rotation  : 0)



### PIECE SET

# accessors
proc `[]` * (pset: PieceSet, pos: Position): Piece {.inline.} =
    pset.pieces.getOrDefault(pos, NO_PIECE)

proc `[]=` * (pset: var PieceSet, pos: Position, piece: Piece) {.inline.} =
    pset.pieces[pos] = piece

# simply return the flag for the given cell
proc getFlag * (pset: PieceSet, pos: Position, team: Team): FlagType {.inline.} =
    # try to find an other piece at that location
    let  other = pset[pos].team
    if   other <= NO_TEAM: fEmpty
    elif other != team   : fEnemy
    else                 : fAlly

# generate a deep copy of the piece set
proc clone * (pset: PieceSet): PieceSet {.inline.} =
    PieceSet(pieces: pset.pieces)

# move a piece from a location to another
proc move * (pset: var PieceSet, from_pos: Position, to_pos: Position) {.inline.} =
    pset[  to_pos] = pset[from_pos]
    pset[from_pos] = NO_PIECE
