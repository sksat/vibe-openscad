// 小型バット蝶番 (butt hinge) - 180° 開状態
// 単位: mm

$fn = 96;

// 基本寸法
leaf_w = 25;            // 板の横幅 (X)
leaf_h = 30;            // 板の縦高さ (Y)
leaf_t = 2;             // 板厚 (Z)

knuckle_od = 8;         // knuckle 外径
knuckle_r  = knuckle_od/2;
knuckle_id = 4.6;       // ピン + 0.3mm クリアランス

seg_len = 6;            // knuckle セグメント長
y_centers = [-12,-6,0,6,12]; // 30mm を 5 等分した中心位置

// knuckle 所有: 左(外側2 + 中央1), 右(中間2)
left_idx  = [0,2,4];
right_idx = [1,3];

pin_d  = 4;
pin_L  = 32;            // 両端 1mm ずつ突出 (knuckle計30mm -> 30+2)
z_mid  = 1;             // Z の中心 (板厚中央に合わせる)

// 皿穴寸法 (M3 用)
screw_d   = 3.2;        // 貫通穴
cs_d      = 6;          // 皿頭外径
cs_depth  = 1;          // 皿部深さ
hole_ys   = [-8,0,8];   // ピッチ 8mm
hole_x_L  = -leaf_w/2;  // 左板の穴 X
hole_x_R  =  leaf_w/2;  // 右板の穴 X

//======================== ユーティリティ ========================//
module pin_hole(len=40) {
    // knuckle 内のピン用の貫通空間 (削り取り用)
    translate([0,0,z_mid]) rotate([90,0,0])
        cylinder(d=knuckle_id, h=len, center=true);
}

module knuckle_segment(yc, d=knuckle_od, h=seg_len) {
    // Y 軸向きの円筒 (中心 Y=yc, Z は z_mid を中心)
    translate([0,yc,z_mid]) rotate([90,0,0])
        cylinder(d=d, h=h, center=true);
}

module knuckle_union(y_idxs) {
    union() {
        for(i = y_idxs) knuckle_segment(y_centers[i], d=knuckle_od, h=seg_len);
    }
}

module knuckles_with_bore(y_idxs) {
    difference() {
        knuckle_union(y_idxs);
        pin_hole(40);
    }
}

module countersunk_hole(xc, yc) {
    // 皿穴 (上面Z=leaf_tから深さ1mmのテーパ) + 3.2mm 貫通
    // 皿部 (上:直径6, 下:直径3.2, 高さ1)
    translate([xc,yc,leaf_t - cs_depth])
        cylinder(h=cs_depth, d1=cs_d, d2=screw_d, center=false);
    // 貫通穴
    translate([xc,yc,0])
        cylinder(h=leaf_t + 0.2, d=screw_d, center=false);
}

//======================== 左右の板 ========================//
module left_plate_core() {
    // 左板ベース: x ∈ [-25,0], y ∈ [-15,15], z ∈ [0,2]
    translate([-leaf_w, -leaf_h/2, 0])
        cube([leaf_w, leaf_h, leaf_t], center=false);
}

module right_plate_core() {
    // 右板ベース: x ∈ [0,25], y ∈ [-15,15], z ∈ [0,2]
    translate([0, -leaf_h/2, 0])
        cube([leaf_w, leaf_h, leaf_t], center=false);
}

module left_plate_with_cutouts_and_holes() {
    difference() {
        // ベース
        left_plate_core();
        // 右側が持つ knuckle の外径で左板を逃がす (Y = -6, +6 の位置)
        for (i = right_idx)
            knuckle_segment(y_centers[i], d=knuckle_od, h=seg_len);
        // 皿穴 3 個 (X は板の中央)
        for (yy = hole_ys)
            countersunk_hole(hole_x_L, yy);
    }
}

module right_plate_with_cutouts_and_holes() {
    difference() {
        // ベース
        right_plate_core();
        // 左側が持つ knuckle の外径で右板を逃がす (Y = -12, 0, +12 の位置)
        for (i = left_idx)
            knuckle_segment(y_centers[i], d=knuckle_od, h=seg_len);
        // 皿穴 3 個 (X は板の中央)
        for (yy = hole_ys)
            countersunk_hole(hole_x_R, yy);
    }
}

module left_leaf() {
    union() {
        // 板本体 (カットアウト + 皿穴)
        left_plate_with_cutouts_and_holes();
        // 左側 knuckle (内径 4.6mm でくり抜き)
        knuckles_with_bore(left_idx);
    }
}

module right_leaf() {
    union() {
        // 板本体 (カットアウト + 皿穴)
        right_plate_with_cutouts_and_holes();
        // 右側 knuckle (内径 4.6mm でくり抜き)
        knuckles_with_bore(right_idx);
    }
}

module hinge_pin() {
    // ピン軸: 直径4, 長さ32 (Y方向), Z中心は z_mid
    translate([0,0,z_mid]) rotate([90,0,0])
        cylinder(d=pin_d, h=pin_L, center=true);
}

//======================== アセンブリ ========================//
// 180° 開いた状態: 左板は x<0 側、右板は x>0 側。板面は Z=0..2 で共面。
left_leaf();
right_leaf();
hinge_pin();