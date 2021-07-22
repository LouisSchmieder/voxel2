module read

import types

[id: 0x00]
pub struct StatusRequest {}

[id: 0x01]
pub struct StatusPing {
pub:
	payload types.Long
}