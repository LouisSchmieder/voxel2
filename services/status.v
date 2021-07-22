module services

pub struct ListPing {
pub mut:
	version Version
	players Players
	description Description
	favicon string
}

pub struct Version {
pub mut:
	name string
	protocol int
}

pub struct Players {
pub mut:
	max int
	online int
	sample []PlayerData
}

pub struct PlayerData {
pub:
	name string
	id string
}

pub struct Description {
pub:
	text string
}