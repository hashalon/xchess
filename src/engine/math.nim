import
    std/hashes


# Types
type
    Vec2i * = tuple[x , y  : int]
    Rec2i * = tuple[p1, p2 : Vec2i]

    Position * = tuple[level : int; coords    : Vec2i]
    Zone     * = tuple[level : int; rectangle : Rec2i]



# Constants
const
    CARDINAL =  4
    NO_LEVEL = -1
    
    VECTOR_ZERO * = Vec2i(0, 0)
    NO_POSITION * = Position(NO_LEVEL, VECTOR_ZERO)


### VECTOR

# inverse vector
proc `-` * (vec : Vec2i) : Vec2i {.inline.} =
    Vec2i(-vec.x, -vec.y)

# compare vectors
proc `==` * (u, v : Vec2i) : bool {.inline.} =
    u.x == v.x and u.y == v.y

proc `!=` * (u, v : Vec2i) : bool {.inline.} =
    u.x != v.x or u.y != v.y

proc `<`  * (u, v : Vec2i) : bool {.inline.} =
    u.x < v.x and u.y < v.y

proc `<=` * (u, v : Vec2i) : bool {.inline.} =
    u.x <= v.x and u.y <= v.y

proc `>`  * (u, v : Vec2i) : bool {.inline.} =
    u.x > v.x and u.y > v.y

proc `>=` * (u, v : Vec2i) : bool {.inline.} =
    u.x >= v.x and u.y >= v.y


# operator between vectors
proc `+`   * (u, v : Vec2i) : Vec2i {.inline.} =
    Vec2i(u.x + v.x, u.y + v.y)

proc `-`   * (u, v : Vec2i) : Vec2i {.inline.} =
    Vec2i(u.x - v.x, u.y - v.y)

proc `*`   * (u, v : Vec2i) : Vec2i {.inline.} =
    Vec2i(u.x * v.x, u.y * v.y)

proc `div` * (u, v : Vec2i) : Vec2i {.inline.} =
    Vec2i(u.x div v.x, u.y div v.y)

proc `mod` * (u, v : Vec2i) : Vec2i {.inline.} =
    Vec2i(u.x mod v.x, u.y mod v.y)


# operator between a vector and a value
proc `*`   * (vec : Vec2i; val : int) : Vec2i {.inline.} =
    Vec2i(vec.x * val, vec.y * val)

proc `div` * (vec : Vec2i; val : int) : Vec2i {.inline.} =
    Vec2i(vec.x div val, vec.y div val)

proc `mod` * (vec : Vec2i; val : int) : Vec2i {.inline.} =
    Vec2i(vec.x mod val, vec.y mod val)


# rotate the vector
proc rotate * (vec : Vec2i; rot : int) : Vec2i {.inline.} =
    case rot mod CARDINAL:
        of 1, -3: Vec2i(-vec.y,  vec.x)
        of 2, -2: Vec2i(-vec.x, -vec.y)
        of 3, -1: Vec2i( vec.y, -vec.x)
        else: vec

proc `shl` * (vec : Vec2i; rot : int) : Vec2i {.inline.} =
    vec.rotate(rot)

proc `shr` * (vec : Vec2i; rot : int) : Vec2i {.inline.} =
    vec.rotate(-rot)



### RECTANGLE

# check if the vector is inside the rectangle
proc `in` * (rec : Rec2i; vec : Vec2i) : bool {.inline.} =
    vec >= rec.p1 and vec < rec.p2

proc `notin` * (rec : Rec2i; vec : Vec2i) : bool {.inline.} =
    rec.p1 > vec or rec.2 <= vec



### POSITION

# compare positions
proc `==` * (p1, p2 : Position) : bool {.inline.} =
    p1.level == p2.level and p1.coords == p2.coords

proc `!=` * (p1, p2 : Position) : bool {.inline.} =
    p1.level != p2.level or p1.coords != p2.coords


# generate a hash value from the coordinates
proc hash * (pos : Position) : Hash {.inline.} =
    pos.level.uint shl 24 or
    (pos.coords.y.uint and 0xFFF'u) shl 12 or 
    (pos.coords.x.uint and 0xFFF'u)



### ZONE

# check if the position is inside the zone
proc `in` * (zone : Zone; pos : Position) : bool {.inline.} =
    zone.level == pos.level and pos.coords in zone.rectangle

proc `notin` * (zone : Zone; pos : Position) : bool {.inline.} =
    zone.level != pos.level or pos.coords notin zone.rectangle

