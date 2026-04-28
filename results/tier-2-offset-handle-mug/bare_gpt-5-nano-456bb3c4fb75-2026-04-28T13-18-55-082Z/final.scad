$fn = 100;

// Main mug body
module mug_body() {
    outer_r = 40;      // 外径 80mm
    inner_r = 35;      // 内径 70mm
    height  = 90;      // 高さ 90mm
    bottom_thick = 6;  // 底面厚み 6mm

    difference() {
        // 外側
        cylinder(h = height, r = outer_r, center = false);

        // 内側を中空に
        translate([0, 0, bottom_thick])
            cylinder(h = height - bottom_thick, r = inner_r, center = false);
    }
}

// D字形状の取手の2Dプロファイル（左側が直線、右側が半円）
module handle_profile(W, H) {
    // W: 左の直線部の幅、高さはH
    // 2D cross-section in XY plane
    union() {
        square([W, H], center = false);
        intersection() {
            // 右側の半円
            translate([W, H/2]) circle(H/2, $fn = 60);
            // 半円を含む領域を現すための左側の矩形との交差で、右半円を作成
            translate([W, 0]) square([H, H], center = false);
        }
    }
}

// 取手本体（+X 側に配置、現実的なD字形状＋内部空間を設ける）
module handle() {
    W = 60;      // 取手の2Dプロファイルの横幅（Y方向の範囲）
    H = 60;      // 取手の2Dプロファイルの高さ
    tX = 28;     // +X 方向の長さ（取手の厚み/長さ）
    intrude = 6; // 本体外周への浸入量（マグ本体と確実に連結するための重なり）

    // 2D profile を X 軸方向に長さ tX だけ押し出して3D化（Z軸方向に厚みを与える）
    // 2D profile は YZ 平面で定義されるが、ここでは X 軸方向に沿って押し出す形で配置
    // 最終的に rotate で +X 方向に向くようにする
    handle_outer = translate([40 - intrude, -W/2, (90 - H)/2])
                    rotate([0, 90, 0])
                    linear_extrude(height = tX)
                        handle_profile(W, H);

    // 内部空間（高さ 30 mm × 幅 25 mm）を切り取る
    // 位置は取手の内側に合わせて調整
    inner_hole = translate([40 - intrude + 6, -12.5, (90 - H)/2 + 15])
                    rotate([0, 90, 0])
                    cube([tX - 12, 25, 30], center = false);

    difference() {
        handle_outer;
        inner_hole;
    }
}

// 統合
union() {
    mug_body();
    handle();
}