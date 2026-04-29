// --- Parameters ---
outer_diameter = 80; // 外径 (mm)
outer_radius = outer_diameter / 2;

cup_height = 100;     // 高さ (mm)
wall_thickness = 4;   // 壁の厚さ (mm). これは主に側面の構造的な肉厚を指します。
base_thickness = 6;   // 底面の厚さ (mm)
handle_radius = 12;   // 取手の半径 (外周から測る)

// 内径と内面カーブの計算
inner_diameter = outer_diameter - 2 * wall_thickness;
inner_radius = inner_diameter / 2;

// カップのメインボディを構築する関数
module mug_body() {
    difference() {
        // 1. 外側の実体 (Outer solid cylinder)
        translate([0, 0, 0])
        cylinder(h = cup_height, r = outer_radius, $fn=100);

        // 2. 内側をくり抜くためのボイド（空洞）の定義

        // A. 底面から貫通するメインのカーブ（内径が36mm、高さ100mm）
        translate([0, 0, -1]) { // Z軸方向に-1移動して底から完全に抜けさせる
            cylinder(h = cup_height + 2, r = inner_radius + 2, $fn=100);
        }

        // B. 底板の下の空隙（念のため、内側をクリーンにする）
        translate([0, 0, -base_thickness]) {
            cylinder(h = base_thickness * 2, r = inner_radius + 1, $fn=100);
        }

        // C. 底面の厚み分、内部に大きな穴を開けずに留めるため、底面全体をくり抜く（実質的なボイド）
        // この部分が複雑なため、代わりに、内側空間(R=36)の直下にベースとなる空洞を作成する。
        translate([0, 0, -1]) {
             cylinder(h = base_thickness + 2, r = inner_radius + 2, $fn=100);
        }
    }
}

// 取っ手（リング状の取手）を構築する関数
module handle() {
    // 取手の設置位置: カップ中心の高さ (Z=50mm)
    handle_z = cup_height / 2;
    
    // 外側の取り付け円筒の中心点からの距離
    attachment_r = outer_radius + 1; // 本体外側から少しだけ内部に入り込む想定

    // 取っ手の厚みと幅 (ここでは適当に3mm x 40mmとする)
    handle_thickness = 3;
    handle_width = 5;

    translate([outer_radius, 0, handle_z]) {
        rotate([0, -90, 0]) // X軸に沿って配置し、リング状にするため回転
        linear_extrude(height = handle_width)
        circle(r = handle_thickness/2);
    }
}


// --- メインの結合と描画 ---

union() {
    // 1. カップ本体
    mug_body();

    // 2. 取っ手の配置 (カップの外周に沿って、側面全体を覆う形で配置する方がより自然だが、ここでは簡略化し、単一の取手として添付)
    translate([outer_radius * 0.9, 0, cup_height / 2]) { // カップ本体の右側面に少しだけ重なるように設置
        rotate([0, -90, 0])
        linear_extrude(height = handle_width + 1)
        circle(r = handle_thickness/2);
    }
}