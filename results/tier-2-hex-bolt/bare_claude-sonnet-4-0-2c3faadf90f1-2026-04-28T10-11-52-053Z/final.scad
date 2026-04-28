// M8六角ボルト
// 頭部：六角柱（対辺距離13mm、高さ5.3mm）
// シャンク：円柱（直径8mm、長さ30mm）

module hex_bolt_m8() {
    // 六角頭部
    translate([0, 0, 0]) {
        cylinder(d=13/cos(30), h=5.3, $fn=6);
    }
    
    // シャンク部
    translate([0, 0, -30]) {
        cylinder(d=8, h=30, $fn=32);
    }
}

hex_bolt_m8();