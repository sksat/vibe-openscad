// ======================================================================
// マグカップ設計
// 本体: 外径80mm, 内径70mm(肉厚5mm), 高さ90mm, 底面厚み6mm
// 取手: +X軸側面にD字形状で取り付け、内側の空間30mm x 25mm
// ======================================================================

// --- パラメータ定義 ---
// マグ本体寸法
D_out = 80;   // 外径 (mm)
D_in = 70;    // 内径 (mm)
T_wall = 5;   // 壁の厚み (mm)
H_mug = 90;   // 高さ (mm)
T_bottom = 6; // 底面の厚み (mm)

// 取手寸法
H_handle = 30; // 取手の高さ (指が入る空間の高さ)
W_handle = 25; // 取手の幅 (内側の空間の幅)
T_handle = 8;  // 取手の厚み (設定値。適宜調整可能)

// --- 本体設計 ---

// 1. マグ本体の定義（外形）
mug_body = cylinder(r = D_out / 2, h = H_mug);

// 2. 内側の空洞を定義（肉厚T_wallで内径D_inを作る）
inner_cavity = cylinder(r = D_in / 2, h = H_mug);

// 3. 底面の厚みを追加
bottom = cylinder(r = D_in / 2, h = T_bottom);

// 本体を組み立てる（外側と内側の差分で肉厚を確保）
mug_base = difference(mug_body, inner_cavity);
mug_final = union(mug_base, bottom);


// --- 取手設計 ---

// 取手の位置決め
// マグの高さの中央付近に配置。ここではZ軸の中心 (H_mug / 2) を基準とする。
handle_z_start = H_mug / 2 - H_handle / 2; // Z座標の開始点
handle_z_end = handle_z_start + H_handle;

// 取手の外側半径 R_out (マグの外径/2) から始まる
R_outer = D_out / 2;

// 取手形状を計算する際に、D字形（外側半円）を考慮し、内部空間W_handle=25mmを持つように配置する。
// 外側の曲線半径 R_handle_out は、中心からの距離が W_handle/2 + T_handle になるように設定する。
R_handle_out = R_outer - (W_handle / 2) - T_handle; // D字の最も外側の円弧の半径

// 取手本体（D字形状）
handle = union(
    // 外側の半円部分 (X軸に沿って伸びる)
    cylinder(r = R_handle_out, h = H_handle),
    // 内側の直線部分
    cube([T_wall, W_handle, H_handle], center = true) // 内部空間を確保するためのブロック
);


// --- 結合と出力 ---

// 取手をマグ本体の外側に接続する。
// 取手はX軸方向（+X側）に配置されるため、Z座標の中心で配置し、Y軸方向に幅を取る必要がある。
handle_position = [R_outer, 0, (H_mug / 2) - (H_handle / 2)];

final_mug = union(mug_final, handle);

// 表示設定（オプション）
// color("blue")
// color("red")
// enable_animation = false;

// 実行
// 座標系を調整して、取手がマグの+X側に配置されるようにオフセットを適用する。
translate([R_outer, 0, 0]) {
    // 取手を配置するための修正（ここでは単純なUnionでマニフォールドを確保）
    // 注: 上記のhandle定義は相対的な形状であり、最終的にmug_finalに結合されるため、
    // handleがマグ本体の表面と確実に接続するように位置関係を調整する。

    // マグ本体 (中心(0,0)を原点とする)
    // mug_final は既に計算済み

    // 取手は外側から追加されるため、X軸方向にオフセットして配置する
    handle_attached = translate([R_outer - T_handle/2, 0, 0]) {
        // D字形状の定義 (中心をマグの外周に合わせる)
        // 外側の半円: R_outer から始まる。内部空間 W_handle=25 を確保。
        // 今回、取手を+X側面に付けるため、Y軸方向が厚みになるように設計する。

        // 1. 本体側の直線部分 (外壁に接する)
        cube([T_wall, W_handle, H_handle], center = true); // Y軸方向に幅を確保

        // 2. 外側の半円部分
        // R_handle_out の形状で、マグの外側に向かってカーブを形成する。
        // 今回は、取手が+X側に付けられるため、Y方向の広がりとX方向の長さが重要。
    };

    // シンプルなマニフォールド確保のため、本体と取手をUnionする。
    final_mug = union(mug_final, handle_attached);
}


// 最終的な出力（上記計算結果を適用）
// 座標系調整後の再実行
translate([R_outer - T_handle/2, 0, 0]) {
    // 本体 (Y軸方向に幅を持つように設定)
    mug_final = union(mug_final, handle); // Handleの定義は上記で既に実行済み
}

// 最終的な結果を出力
// （コードブロック全体を一つの出力としてまとめます）