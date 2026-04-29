// マグカップ（外径80mm、厚み4mm、底6mm）＋リング状取手（半径12mm）
module cup(){
    difference(){
        // 外側の円柱
        cylinder(r=40, h=100, $fn=200);
        // 内側の穴（底面厚み6mmを考慮）
        translate([0, 0, 6])
            cylinder(r=36, h=94, $fn=200);
    }
}

module handle(){
    // 半径12mm のリング状取手（外径52mm、円柱の太さ4mm）
    rotate_extrude(angle=360, $fn=200)
        translate([52, 0, 0])
            circle(r=4, $fn=50);
}

union(){
    cup();
    // 取手をカップ中心高さに配置
    translate([0, 0, 50]) handle();
}