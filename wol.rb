#!/usr/bin/ruby

#=== REQUIRE =================================================
require 'optparse'
require "socket"

#=== REQUIRE END =============================================
#
#=== CONFIG ==================================================

$config = {
	:BROADCAST => "172.16.255.255",			# ブロードキャスト(社内はClass-B)
	:TARGETS => [
		"D8:CB:8A:97:05:F8"					# 小上がりPCのMACアドレス
	]
};

$config_wol = {
	:PORT		=> 7,						# WoLのPort
	:HEADER		=> 'ff:ff:ff:ff:ff:ff',		# WoL Header
	:NUM_ADDRESS=> 16,
	:SEPARATOR	=>':'
};

#=== CONFIG END ==============================================
=begin
#=== SPEC ====================================================
・マジックパケットのフォーマット
 0xff のデータが 6 個(6 bytes)
 対象のMACアドレスが 16 個 (6×16=96 bytes)

・送信はブロードキャストアドレスに。
　(対象は電源がOFFの為、IPが不確定)

・PORTは通常、7か9

・通信方式は、TCP/UDPどちらでも良いらしい。今回はUDPで実行している。

=end
##============================================================
#
# OptionParser初期設定
#
##============================================================
$option = {
	:method	=> :default,
	:TARGETS => [],
	:BROADCAST => '192.168.0.255'
}

OptionParser.new do |opt|
	opt.version = "0.9"
	opt.on('-m', '--mac MACADDR'		, '対象PCのMac-Address'	){|v| $option[:TARGETS].push(v)	}
	opt.on('-b', '--broadcast BROADCAST', 'ブロードキャスト先'		){|v| $option[:BROADCAST] = v }
	#opt.on_tail("-h", "--help", "このメッセージを表示します"){}
	opt.banner = "Usage: ruby #{opt.program_name} [options]\nVersion:#{opt.version}"
	
	opt.parse!(ARGV)
	
	$option[:method] = :help if !$option.has_key?(:method)
	$option[:method] = :arg	 if $option.length != 0
	print opt.help if $option[:method] == :help
end

def createMagicPackets(mac)
	#=======================================
	# マジックパケット生成
	#=======================================
	data = []
	
	$config_wol[:HEADER].split($config_wol[:SEPARATOR]).each do |ele|
		data.push(ele.to_i(16))
	end

	$config_wol[:NUM_ADDRESS].times do
		mac.split($config_wol[:SEPARATOR]).each do |ele|
			data.push(ele.to_i(16))
		end
	end

	return data.pack("C*")
end

def sendPacketsUDP(host,port,mac,packets)
	#=======================================
	# UDPで送信
	#=======================================
	udp = UDPSocket.new()
	sockaddr = Socket.pack_sockaddr_in(port, host)
	udp.send(packets, 0, sockaddr)
	udp.close()
end

#=== ENTRY ===================================================
#=======================================
# 
# TARGETSにマジックパケット送信
# 
#=======================================
def main()
	config = $config
	config = $option if $option[:method] == :arg

	macs	 = config[:TARGETS]
	broadcast= config[:BROADCAST]

	macs.each do |mac|
		packets = createMagicPackets(mac)									# MagicPackets生成
		sendPacketsUDP(broadcast,$config_wol[:PORT],mac,packets);	# 送信
	end
end


begin
	main()
rescue Interrupt

ensure

end

