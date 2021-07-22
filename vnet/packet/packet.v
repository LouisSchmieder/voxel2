module packet

import types
import net
import vnet.io
import vnet.packet.read

type Packet = read.Handshake | read.StatusRequest | read.StatusPing

pub enum ConnectionState {
	handshake
	status
	play
}

pub struct PacketManager {
	protocol_settings ProtocolSettings
mut:
	sock    &net.TcpConn
	packets u64 // all handled packets
	nis     &io.NetInStream
	nos     &io.NetOutStream
	state   ConnectionState
}

pub fn setup_packet_manager(sock &net.TcpConn, protocol_settings ProtocolSettings) &PacketManager {
	return &PacketManager{
		protocol_settings: protocol_settings
		sock: sock
		nis: io.new_net_input_stream(sock)
		nos: io.new_net_output_stream(sock)
		state: .handshake
	}
}

pub fn (mut pm PacketManager) next_status(id int) {
	pm.state = ConnectionState(id)
}

pub fn (mut pm PacketManager) get_packet() ?Packet {
	mut len := pm.nis.read_pure_var_int()
	pm.nis.clear_len()
	pkd_id := pm.nis.read_pure_var_int()
	len -= pm.nis.len

	pm.packets++

	match pm.state {
		.handshake {
			match pkd_id {
				0x00 {
					data := pm.serialize_packet<read.Handshake>(len) ?
					return data
				}
				else {
					return error('Packet id 0x${pkd_id.hex()} was not found in state ${pm.state}')
				}
			}
		}
		.status {
			match pkd_id {
				0x00 {
					data := pm.serialize_packet<read.StatusRequest>(len) ?
					return data
				}
				0x01 {
					data := pm.serialize_packet<read.StatusPing>(len) ?
					return data					
				}
				else {
					return error('Packet id 0x${pkd_id.hex()} was not found in state ${pm.state}')
				}
			}
		}
		.play {}
	}
}

pub fn (mut pm PacketManager) serialize_packet<T>(len int) ?T {
	mut data := T{}
	$for field in T.fields {
		$if field.typ is types.Boolean {
			data.$(field.name) = pm.nis.read_bool() ?
		} $else $if field.typ is types.Byte {
			data.$(field.name) = pm.nis.read_i8() ?
		} $else $if field.typ is types.UByte {
			data.$(field.name) = pm.nis.read_byte() ?
		} $else $if field.typ is types.Short {
			data.$(field.name) = pm.nis.read_i16() ?
		} $else $if field.typ is types.UShort {
			data.$(field.name) = pm.nis.read_u16() ?
		} $else $if field.typ is types.Int {
			data.$(field.name) = pm.nis.read_int() ?
		} $else $if field.typ is types.Long {
			data.$(field.name) = pm.nis.read_i64() ?
		} $else $if field.typ is types.Float {
			data.$(field.name) = pm.nis.read_f32() ?
		} $else $if field.typ is types.Double {
			data.$(field.name) = pm.nis.read_f64() ?
		} $else $if field.typ is types.String {
			data.$(field.name) = pm.nis.read_mc_string() ? // add specifications
		} $else $if field.typ is types.Chat {
			data.$(field.name) = pm.nis.read_mc_string() ? // add specifications
		} $else $if field.typ is types.Identifier {
			data.$(field.name) = pm.nis.read_mc_string() ? // add specifications
		} $else $if field.typ is types.VarInt {
			data.$(field.name) = pm.nis.read_pure_var_int()
		} $else $if field.typ is types.VarLong {
			data.$(field.name) = pm.nis.read_pure_var_long()
		} $else $if field.typ is types.Position {
			data.$(field.name) = pm.nis.read_u64() ?
		} $else $if field.typ is types.Angle {
			data.$(field.name) = pm.nis.read_byte() ?
		} $else $if field.typ is types.UUID {
			d := pm.nis.read_u64s(2) ?
			mut ad := [2]u64{}
			ad[0] = d[0]
			ad[1] = d[1]
			data.$(field.name) = ad
		} $else $if field.typ is types.Optional {
		} $else $if field.typ is types.Array {
		}
	}
	return data
}

pub fn (mut pm PacketManager) write_packet<T>(packet T) ? {
	mut pkg_id := byte(0x00)
	$for attr in T.attributes {
		if attr.name == 'id' && attr.has_arg && attr.kind == .number {
			pkg_id = byte(attr.arg.i8())
		}
	}

	pm.packets++
	pm.output_packet<T>(packet, pkg_id) ?
	pm.nos.flush(pkg_id)
	pm.nos.write_packet() ?
}

pub fn (mut pm PacketManager) output_packet<T>(packet T, id byte) ? {
	$for field in T.fields {
		$if field.typ is types.Boolean {
			pm.nos.write_bool(packet.$(field.name))
		} $else $if field.typ is types.Byte {
			pm.nos.write_i8(packet.$(field.name))
		} $else $if field.typ is types.UByte {
			pm.nos.write_byte(packet.$(field.name))
		} $else $if field.typ is types.Short {
			pm.nos.write_i16(packet.$(field.name))
		} $else $if field.typ is types.UShort {
			pm.nos.write_u16(packet.$(field.name))
		} $else $if field.typ is types.Int {
			pm.nos.write_int(packet.$(field.name))
		} $else $if field.typ is types.Long {
			pm.nos.write_i64(packet.$(field.name))
		} $else $if field.typ is types.Float {
			pm.nos.write_f32(packet.$(field.name))
		} $else $if field.typ is types.Double {
			pm.nos.write_f64(packet.$(field.name))
		} $else $if field.typ is types.String {
			pm.nos.write_var_string(packet.$(field.name))
		} $else $if field.typ is types.Chat {
			pm.nos.write_var_string(packet.$(field.name))
		} $else $if field.typ is types.Identifier {
			pm.nos.write_var_string(packet.$(field.name))
		} $else $if field.typ is types.VarInt {
			pm.nos.write_var_int(packet.$(field.name))
		} $else $if field.typ is types.VarLong {
			pm.nos.write_var_long(packet.$(field.name))
		} $else $if field.typ is types.Position {
			pm.nos.write_u64(packet.$(field.name))
		} $else $if field.typ is types.Angle {
			pm.nos.write_byte(packet.$(field.name))
		} $else $if field.typ is types.UUID {
			uuid := packet.$(field.name)
			pm.nos.write_u64(uuid[0])
			pm.nos.write_u64(uuid[1])
		} $else $if field.typ is types.Optional {
			opt := packet.$(field.name)
			if opt !is types.Types {
				// write type
			}
		} $else $if field.typ is types.Array {
		}
	}
}