// マグカップの設計パラメータ
mug_outer_radius = 40;
mug_inner_radius = 35;
mug_height = 90;
mug_bottom_thickness = 6;

handle_radius = 25;
handle_height = 30;
handle_width = 25; // 内側の空間の幅（X方向）
handle_thickness = 10; // 取っ手の厚み（Y方向）

$fn = 100;

// 本体
difference() {
    // 外側の円筒
    cylinder(h = mug_height, r = mug_outer_radius);
    
    // 内側の空洞（底面の厚みを考慮して上方向にずらす）
    translate([0, 0, mug_bottom_thickness])
        cylinder(h = mug_height, r = mug_inner_radius);
}

// 取っ手 (Handle)
union() {
    difference() {
        // 取っ手の外形 (D字形状)
        // Z軸方向（高さ方向）に伸びる円柱を、X=40の位置でカットして半円にする
        // これにより、X=40の面が直線（本体との接合部）、X>40の面が半円になる
        translate([40, 45, 45])
        rotate([0, 0, 0]) // Z軸方向の円柱
        cylinder(h = handle_height, r = handle_radius, center = true);
        
        // X軸のマイナス方向をカット（本体側を直線にする）
        // 39.5の位置でカットすることで、本体表面との重なりを確保しマニフォールドを維持
        cube([39.5, 100, 100]);
        
        // 取っ手の上下の余分な部分をカット（高さ30mmに制限）
        // 中心が45なので、30〜60の範囲を残す
        cube([100, 100, 100]) translate([0, -30, 0]); // 下側カット
        cube([100, 100, 100]) translate([0, 30, 60]); // 上側カット（※位置調整が必要な場合はここを調整）
        
        // 正確な高さ制限のための差分処理（より厳密な範囲指定）
        translate([0, -100, 30]) cube([100, 100, 60]); // 下側を30の高さで切り取る
        translate([0, -100, 60]) cube([100, 100, 90]); // 上側を60の高さで切り取る（実際は30-60の範囲）
        
        // 上記を整理したシンプルな高さ制限：
        // cylinder(h=30, r=25, center=true) は Z方向に 30〜60 の範囲を占める。
        // よって、追加の高さカットは不要。
        
        // 取っ手の内側の空間（指が入る穴）
        // 高さ30mm × 幅25mm の空間をくり抜く
        translate([40, 35, 30])
        cube([handle_width, handle_thickness * 2, handle_height]);
    }
}

// 修正後の構造を整理した最終コード
// 以下のブロックを統合して再定義
module final_mug() {
    difference() {
        // 本体
        cylinder(h = mug_height, r = mug_outer_radius);
        translate([0, 0, mug_bottom_thickness])
            cylinder(h = mug_height, r = mug_inner_radius);
    }

    union() {
        difference() {
            // 取っ手外形
            // Z軸方向に高さ30mm、中心を45に配置
            // X方向の半径25mmの円柱の半分（X>40の部分）
            translate([40, 45, 45])
            cylinder(h = handle_height, r = handle_radius, center = true);
            
            // 本体との接合部を直線にするためのカット
            cube([39.5, 100, 100]);
            
            // 内側の空間（指が入る穴）をくり抜く
            // 幅25mm (X方向)、高さ30mm (Z方向)
            translate([40, 35, 30])
            cube([handle_width, 30, handle_height]);
        }
    }
}

// 実行
final_mug();