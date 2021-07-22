module main

import vnet.packet
import net

fn main() {
	mut listener := net.listen_tcp(.ip, 'localhost:25565') or { panic(err) }

	for {
		client := listener.accept() or { panic(err) }
		eprintln('test')
		mut manager := packet.setup_packet_manager(client, {})
		go handle_manager(mut manager)
	}
}

fn handle_manager(mut manager packet.PacketManager) {
	mut packet := manager.get_packet() or { panic(err) }
	manager.next_status(1)
	packet = manager.get_packet() or { panic(err) }
}