// 家具用小型バット蝶番 (180°開き)
// 3 パーツ構成：左板、右板、ピン軸

module hinge_part_left() {
    // 左板 (鉄板形状：30mm x 25mm x 2mm)
    // 縦 30mm (Y 軸) がピン軸に沿う
    // 横 25mm (X 軸) が回転で開く方向
    // 位置：X < 0 側
    difference() {
        // 本体
        union() {
            // 板
            cube([25, 30, 1], [x: -25..0, y: -15..15, z: -1..1]);
            
            // 筒部 (knuckle) 3 つ (OD 8mm, ID 4.6mm, 長さ 6mm)
            // 縦 30mm を 5 等分 (各 6mm)
            // 左板は外側 2 個 + 中央 1 個 (Y: -15..-9, -3..3, 9..15)
            for (y = [-15, -3, 9]) {
                cylinder(h = 6, r = 4, center = [x: 0, y: y + 3, z: 0]);
            }
        }
        
        // M3 皿穴 3 つ
        // 位置：X = -25mm (板の端), Y = -12, -4, 4mm
        for (y = [-12, -4, 4]) {
            // 皿穴：表面から直径 6mm x 深さ 1mm テーパ + 直径 3.2mm 貫通穴
            // Z = 0 中心，板厚 2mm
            difference() {
                // テーパ穴
                cylinder(h = 1, r1 = 3, r2 = 1.6, center = [x: -25, y: y, z: 0.5], $fn = 32);
                // 貫通穴
                cylinder(h = 2, r = 1.6, center = [x: -25, y: y, z: 0]);
            }
        }
    }
}

module hinge_part_right() {
    // 右板 (鉄板形状：30mm x 25mm x 2mm)
    // 位置：X > 0 側
    difference() {
        // 本体
        union() {
            // 板
            cube([25, 30, 1], [x: 0..25, y: -15..15, z: -1..1]);
            
            // 筒部 (knuckle) 2 つ (OD 8mm, ID 4.6mm, 長さ 6mm)
            // 右板は中間 2 個 (Y: -9..-3, 3..9)
            for (y = [-9, 3]) {
                cylinder(h = 6, r = 4, center = [x: 0, y: y + 3, z: 0]);
            }
        }
        
        // M3 皿穴 3 つ
        // 位置：X = 25mm (板の端), Y = -12, -4, 4mm
        for (y = [-12, -4, 4]) {
            // 皿穴
            difference() {
                // テーパ穴
                cylinder(h = 1, r1 = 3, r2 = 1.6, center = [x: 25, y: y, z: 0.5], $fn = 32);
                // 貫通穴
                cylinder(h = 2, r = 1.6, center = [x: 25, y: y, z: 0]);
            }
        }
    }
}

module hinge_pin() {
    // ピン軸 (直径 4mm, 長さ 32mm)
    // 両端 1mm ずつ knuckle から飛び出す
    // knuckle 全体 30mm (-15..15) なので、ピンは -16..16
    cylinder(h = 32, r = 2, center = [x: 0, y: 0, z: 0]);
}

difference() {
    union() {
        hinge_part_left();
        hinge_part_right();
        hinge_pin();
    }
}