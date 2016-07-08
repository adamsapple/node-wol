
//== CONFIG ==================================================

var config = {
	HOST : "172.16.255.255",			// ブロードキャスト(社内はClass-B)
	TARGETS: [
		"D8:CB:8A:97:05:F8"				// 小上がりPCのMACアドレス
	]
};

var config_wol = {
	PORT : 7,							// WoLのPort
	HEADER : 'ff:ff:ff:ff:ff:ff',		// WoL Header
	NUM_ADDRESS: 16,
	SEPARATOR:':'
};

//== CONFIG END ==============================================

/*== SPEC ====================================================
・マジックパケットのフォーマット
 0xff のデータが 6 個(6 bytes)
 対象のMACアドレスが 16 個 (6×16=96 bytes)

・送信はブロードキャストアドレスに。
　(対象は電源がOFFの為、IPが不確定)

・PORTは通常、7か9

・通信方式は、TCP/UDPどちらでも良いらしい。今回はUDPで実行している。
*/

//== REQUIRE =================================================

var dgram = require('dgram');			// UDP通信

//== REQUIRE END =============================================


function createMagicPackets(mac){
	//======================================
	// マジックパケット生成
	//======================================
	var packets = new Buffer(6+(6*16));
	var offs = 0;

	config_wol.HEADER.split(config_wol.SEPARATOR).forEach(function(ele){
		packets.writeUInt8(parseInt(ele,16),offs++);
	});

	var num = config_wol.NUM_ADDRESS;
	while(num--){
		mac.split(config_wol.SEPARATOR).forEach(function(ele){
			packets.writeUInt8(parseInt(ele,16),offs++);
		});
	}

	return packets;
}

function sendUDP(host,mac,packets){
	//======================================
	// UDPで送信
	//======================================
	var socket = dgram.createSocket('udp4');
	socket.send(packets, 0, packets.length, config_wol.PORT, host, function(err, bytes){
	    if (err) throw err;
	    console.log('UDP message sent to ' + host);
	    socket.close();
	});

	socket.unref();
	//socket.close();
}

//== ENTRY ===================================================

//======================================
// 
// TARGETSにマジックパケット送信
// 
//======================================
config.TARGETS.forEach(function(mac){
	var packets = createMagicPackets(mac);	// MagicPackets生成
	sendUDP(config.HOST,mac,packets);		// 送信
});

