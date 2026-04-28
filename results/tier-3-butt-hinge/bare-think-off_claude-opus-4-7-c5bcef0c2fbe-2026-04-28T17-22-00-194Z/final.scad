// 小型バット蝶番 (butt hinge) - 180°開いた状態

$fn = 64;

// パラメータ
leaf_w = 25;       // 板の横幅(回転で開く方向)
leaf_h = 30;       // 板の縦(ヒンジ軸方向)
leaf_t = 2;        // 板厚
pin_d = 4;         // ピン直径
pin_len = 32;      // ピン長
knuckle_od = 8;    // knuckle外径
knuckle_id = 4.6;  // knuckle内径(クリアランス込み)
seg_h = 6;         // knuckle各セグメント高さ
n_seg = 5;         // 分割数

// 皿穴
csk_outer = 6;
csk_depth = 1;
hole_d = 3.2;

// セグメントY位置(中心)
function seg_y(i) = -leaf_h/2 + seg_h/2 + i*seg_h;

// 皿穴付き貫通(板厚方向 z)
module screw_hole() {
    // 貫通穴
    translate([0,0,-0.1])
        cylinder(d=hole_d, h=leaf_t+0.2);
    // 皿テーパ(上面 z=leaf_t/2 から下に depth)
    translate([0,0,leaf_t/2 - csk_depth])
        cylinder(d1=hole_d, d2=csk_outer, h=csk_depth + 0.01);
}

// 左板(knuckle: セグメント 0, 2, 4)
module left_leaf() {
    color("silver")
    difference() {
        union() {
            // 板本体: x<0 側に伸びる
            // knuckle と接する側は X=0 から少し内側まで
            // 板の x=0 側端は knuckle 中心に届く
            translate([-leaf_w, -leaf_h/2, -leaf_t/2])
                cube([leaf_w, leaf_h, leaf_t]);
            
            // knuckle 3個 (i=0,2,4)
            for (i = [0, 2, 4]) {
                translate([0, seg_y(i) - seg_h/2, 0])
                    rotate([-90, 0, 0])
                        cylinder(d=knuckle_od, h=seg_h);
            }
        }
        
        // ピン穴
        translate([0, -leaf_h/2 - 1, 0])
            rotate([-90, 0, 0])
                cylinder(d=knuckle_id, h=leaf_h + 2);
        
        // ネジ穴3個(板の縦方向 8mm 間隔、knuckleから離れた側)
        // 横方向: knuckle側から離れた位置
        screw_x = -leaf_w + 8;
        for (i = [-1, 0, 1]) {
            translate([screw_x, i*8, 0])
                screw_hole();
        }
    }
}

// 右板(knuckle: セグメント 1, 3)
module right_leaf() {
    color("silver")
    difference() {
        union() {
            translate([0, -leaf_h/2, -leaf_t/2])
                cube([leaf_w, leaf_h, leaf_t]);
            
            for (i = [1, 3]) {
                translate([0, seg_y(i) - seg_h/2, 0])
                    rotate([-90, 0, 0])
                        cylinder(d=knuckle_od, h=seg_h);
            }
        }
        
        translate([0, -leaf_h/2 - 1, 0])
            rotate([-90, 0, 0])
                cylinder(d=knuckle_id, h=leaf_h + 2);
        
        screw_x = leaf_w - 8;
        for (i = [-1, 0, 1]) {
            translate([screw_x, i*8, 0])
                screw_hole();
        }
    }
}

// ピン軸
module pin() {
    color("gold")
    translate([0, -pin_len/2, 0])
        rotate([-90, 0, 0])
            cylinder(d=pin_d, h=pin_len);
}

// 配置
left_leaf();
right_leaf();
pin();