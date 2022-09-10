import
    std/hashes


# Types
type
    Vec2i     * = tuple[x , y : int]
    Rec2i     * = tuple[p1, p2: Vec2i]
    Team      * = int
    Rotation  * = int
    Level     * = int
    Position  * = tuple[level: Level, coords   : Vec2i]
    Zone      * = tuple[level: Level, rectangle: Rec2i]
    Transform * = tuple[position: Position, rotation: Rotation]


# Constants
const
    cardinality * =  4
    noLevel     * = -1
    
    vecZero    * : Vec2i = (0, 0)
    noPosition * : Position = (noLevel, vecZero)


### VECTOR

# inverse vector
proc `-` * (vec: Vec2i): Vec2i {.inline.} =
    (-vec.x, -vec.y)

# compare vectors
proc `==` * (u, v: Vec2i): bool {.inline.} =
    u.x == v.x and u.y == v.y

proc `!=` * (u, v: Vec2i): bool {.inline.} =
    u.x != v.x or u.y != v.y

proc `<`  * (u, v: Vec2i): bool {.inline.} =
    u.x < v.x and u.y < v.y

proc `<=` * (u, v: Vec2i): bool {.inline.} =
    u.x <= v.x and u.y <= v.y

proc `>`  * (u, v: Vec2i): bool {.inline.} =
    u.x > v.x and u.y > v.y

proc `>=` * (u, v: Vec2i): bool {.inline.} =
    u.x >= v.x and u.y >= v.y


# operator between vectors
proc `+`   * (u, v: Vec2i): Vec2i {.inline.} =
    (u.x + v.x, u.y + v.y)

proc `-`   * (u, v: Vec2i): Vec2i {.inline.} =
    (u.x - v.x, u.y - v.y)

proc `*`   * (u, v: Vec2i): Vec2i {.inline.} =
    (u.x * v.x, u.y * v.y)

proc `div` * (u, v: Vec2i): Vec2i {.inline.} =
    (u.x div v.x, u.y div v.y)

proc `mod` * (u, v: Vec2i): Vec2i {.inline.} =
    (u.x mod v.x, u.y mod v.y)


# operator between a vector and a value
proc `*`   * (vec: Vec2i, val: int): Vec2i {.inline.} =
    (vec.x * val, vec.y * val)

proc `div` * (vec: Vec2i, val: int): Vec2i {.inline.} =
    (vec.x div val, vec.y div val)

proc `mod` * (vec: Vec2i, val: int): Vec2i {.inline.} =
    (vec.x mod val, vec.y mod val)


# rotate the vector
proc rotate * (vec: Vec2i, rot: Rotation): Vec2i {.inline.} =
    case rot mod cardinality:
        of 1, -3: (-vec.y,  vec.x)
        of 2, -2: (-vec.x, -vec.y)
        of 3, -1: ( vec.y, -vec.x)
        else: vec

proc `shl` * (vec: Vec2i, rot: Rotation): Vec2i {.inline.} =
    vec.rotate(rot)

proc `shr` * (vec: Vec2i, rot: Rotation): Vec2i {.inline.} =
    vec.rotate(-rot)



### RECTANGLE

# check if the vector is inside the rectangle
proc `in`    * (vec: Vec2i, rec: Rec2i): bool {.inline.} =
    vec >= rec.p1 and vec < rec.p2

proc `notin` * (vec: Vec2i, rec: Rec2i): bool {.inline.} =
    rec.p1 > vec or rec.p2 <= vec



### POSITION

# compare positions
proc `==` * (p1, p2: Position): bool {.inline.} =
    p1.level == p2.level and p1.coords == p2.coords

proc `!=` * (p1, p2: Position): bool {.inline.} =
    p1.level != p2.level or p1.coords != p2.coords

# sum two positions together
proc `+` * (p1, p2: Position): Position {.inline.} =
    (p1.level + p2.level, p1.coords + p2.coords)

proc `-` * (p1, p2: Position): Position {.inline.} =
    (p1.level - p2.level, p1.coords - p2.coords)

# move position using a vector
proc `+` * (p: Position, v: Vec2i): Position {.inline.} =
    (p.level, p.coords + v)

proc `-` * (p: Position, v: Vec2i): Position {.inline.} =
    (p.level, p.coords - v)

# change level of position
proc `+` * (p: Position, l: Level): Position {.inline.} =
    (p.level + l, p.coords)

proc `-` * (p: Position, l: Level): Position {.inline.} =
    (p.level + l, p.coords)


# generate a hash value from the coordinates
proc hash * (pos: Position): Hash {.inline.} =
    (pos.level.uint shl 24 or
    (pos.coords.y.uint and 0xFFF'u) shl 12 or 
    (pos.coords.x.uint and 0xFFF'u)).int



### ZONE

# check if the position is inside the zone
proc `in`    * (pos: Position, zone: Zone): bool {.inline.} =
    zone.level == pos.level and (pos.coords in    zone.rectangle)

proc `notin` * (pos: Position, zone: Zone): bool {.inline.} =
    zone.level != pos.level or  (pos.coords notin zone.rectangle)


### TRANSFORM

# compare transform
proc `==` * (t1, t2 : Transform): bool {.inline.} =
    t1.position == t2.position and t1.rotation == t2.rotation

proc `!=` * (t1, t2 : Transform): bool {.inline.} =
    t1.position != t2.position or  t1.rotation != t2.rotation

# sum two transform together
proc `+` * (t1, t2 : Transform): Transform {.inline.} =
    (t1.position + t2.position, t1.rotation + t2.rotation)


proc `-` * (t1, t2 : Transform): Transform {.inline.} =
    (t1.position - t2.position, t1.rotation - t2.rotation)

# move transform using a vector
proc `+` * (t: Transform, v: Vec2i): Transform {.inline.} =
    (t.position + v, t.rotation)

proc `-` * (t: Transform, v: Vec2i): Transform {.inline.} =
    (t.position - v, t.rotation)

# change level of transform
proc `+` * (t: Transform, l: Level): Transform {.inline.} =
    (t.position + l, t.rotation)

proc `-` * (t: Transform, l: Level): Transform {.inline.} =
    (t.position - l, t.rotation)

# change orientation of transform
proc `+` * (t: Transform, r: Rotation): Transform {.inline.} =
    (t.position, t.rotation + r)

proc `-` * (t: Transform, r: Rotation): Transform {.inline.} =
    (t.position, t.rotation - r)