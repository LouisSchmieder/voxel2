module main

import vnet.packet
import vnet.packet.write
import net
import services
import json

fn main() {
	mut listener := net.listen_tcp(.ip, 'localhost:25565') or { panic(err) }

	mut listping := services.ListPing{
		version: services.Version{
			name: '1.17.1'
			protocol: 765
		}
		players: services.Players{
			max: 100
			online: 5
			sample: [
				services.PlayerData{
					name: 'Test123'
					id: 'dthgfsdhfdsbfius'
				},
			]
		}
		description: services.Description{
			text: 'Test1234'
		}
	}

	settings := packet.ProtocolSettings{
		version: 10
	}
	for {
		client := listener.accept() or { panic(err) }
		mut manager := packet.setup_packet_manager(client, settings)
		go handle_manager(mut manager, listping)
	}
}

fn handle_manager(mut manager packet.PacketManager, list services.ListPing) {
	handshake := manager.get_packet() or { eprintln(err) }
	manager.next_status(1)
	status_request := manager.get_packet() or { eprintln(err) }

	str := json.encode(list)
	manager.write_packet<write.StatusResponse>(write.StatusResponse{ json: str }) or { panic(err) }

	ping := manager.get_packet() or { eprintln(err) }
}
