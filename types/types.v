module types

pub type Types = Boolean | Byte | UByte | Short | UShort | Int | Long | Float | Double | String | Chat | Identifier | VarInt | VarLong | Position | Angle

pub type Boolean = bool
pub type Byte = i8
pub type UByte = byte
pub type Short = i16
pub type UShort = u16
pub type Int = int
pub type Long = i64
pub type Float = f32
pub type Double = f64
pub type String = string
pub type Chat = string
pub type Identifier = string
pub type VarInt = int
pub type VarLong = i64
pub type Position = u64
pub type Angle = byte
pub type UUID = [2]u64

pub type Optional = Types
pub type Array = []Types