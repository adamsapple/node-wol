# node-wol
this is wakeup on lan program by node.js

Usage: ruby wol [options]
Version:0.9
    -m, --mac MACADDR                対象PCのMac-Address
    -b, --broadcast BROADCAST        ブロードキャスト先
    
    
Wakeup on LAN:
・マジックパケットのフォーマット
 0xff が 6 個(6 bytes)
 対象のMACアドレスが 16 個 (6×16=96 bytes)
・送信はブロードキャストアドレスに。
　(対象は電源がOFFの為、IPが確定していないから)
