module packet

import types
import net
import vnet.io
import vnet.packet.read

type Packet = read.Handshake | read.StatusRequest

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
	eprintln(pm.state)
	match pm.state {
		.handshake {
			match pkd_id {
				0x00 {
					data := pm.serialize_packet<read.Handshake>(len) ?
					return data
				}
				else {}
			}
		}
		.status {
			match pkd_id {
				0x00 {
					data := pm.serialize_packet<read.StatusRequest>(len) ?
					return data
				}
				else {}
			}
		}
		.play {}
	}
	return error('error')
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
