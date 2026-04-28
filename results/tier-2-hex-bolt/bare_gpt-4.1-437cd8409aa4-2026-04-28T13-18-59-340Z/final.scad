// M8 六角ボルト（ねじ山省略）
// 寸法：六角頭部 13mm (対辺) × 5.3mm、シャンク φ8mm × 30mm

$fn=120; // 円滑化
hex_width = 13;        // 六角対辺距離
hex_height = 5.3;      // 六角高さ
shank_dia = 8;         // シャンク直径
shank_length = 30;     // シャンク長

// 六角頭部
module hex_head() {
    rotate([0,0,30])  // 六角のフラットをX軸に揃える（オプション）
        linear_extrude(height=hex_height)
            polygon(points = [
                for(i=[0:5]) 
                    let(a=i*60)
                    [cos(a)*hex_width/2 / cos(30), sin(a)*hex_width/2 / cos(30)]
            ]);
}

// シャンク
module shank() {
    cylinder(d=shank_dia, h=shank_length, center=false);
}

// 合成
translate([0,0,0])
    hex_head();

translate([0,0,-shank_length])
    shank();