module read

import types

[id: 0x00]
pub struct Handshake {
pub:
	version types.VarInt
	address types.String
	port    types.UShort
	next    types.VarInt
}
