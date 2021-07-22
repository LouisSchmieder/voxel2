module write

import types

[id: 0x00]
pub struct StatusResponse {
	json types.String
}

[id: 0x01]
pub struct StatusPong {
	payload types.Long
}