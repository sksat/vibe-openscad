// マグカップの基本パラメータ
outer_diameter = 80; // 外径 (mm)
height = 100;       // 高さ (mm)
wall_thickness = 4; // 側面肉厚 (mm)
base_thickness = 6; // 底面厚み (mm)

// 内径の計算
inner_diameter = outer_diameter - 2 * wall_thickness;
inner_radius = inner_diameter / 2;
outer_radius = outer_diameter / 2;

// マグカップ本体の作成
difference() {
    // 外側の円筒
    cylinder(h = height, d = outer_diameter, center = false);

    // 内側のくり抜き
    translate([0, 0, base_thickness]) {
        cylinder(h = height - base_thickness, d = inner_diameter, center = false);
    }

    // 底面のくり抜き (底面厚み分)
    // cylinder(h = base_thickness, d = outer_diameter, center = false); // これは不要。difference()で自動的にくり抜かれる。
}

// 取手のパラメータ
handle_radius = 12;          // 取手のリングの太さ (mm)
handle_offset_from_wall = 5; // カップ外壁からの取手の開始点のオフセット (mm)
handle_height_center = height / 2; // 取手を付ける中心高さ (mm)
handle_ring_diameter = 30;  // 取手のリングの内径 (mm) (指が入るサイズ)

// 取手の作成 (リング状)
translate([0, 0, handle_height_center - (handle_ring_diameter / 2 + handle_radius)]) {
    rotate([90, 0, 0]) {
        // 取手のリング部分
        difference() {
            // 外側のリング
            cylinder(h = handle_radius * 2, d = handle_ring_diameter + 2 * handle_radius, center = true);
            // 内側のくり抜き
            cylinder(h = handle_radius * 2, d = handle_ring_diameter, center = true);
        }
    }
}

// 取手のカップへの接続部分 (簡略化のため、リング状取手はカップ本体とは別に配置)
// より洗練された接続が必要な場合は、union()やhull()などを検討してください。
// ここでは、リング状取手がカップの外側にあるだけで、直接結合されていません。
// 接続部分を表現するには、さらに複雑な形状やboolean演算が必要です。
// 今回は、リング状取手がカップの横に「ぶら下がっている」ようなイメージで作成します。

// 実際には、取手はカップ本体に接続する必要があります。
// 以下のコードは、取手がカップ本体に「付いている」ように見せるための簡略化された方法です。

// 取手の接続部分１ (カップ外壁に接するように配置)
translate([outer_radius - handle_offset_from_wall, 0, handle_height_center]) {
    rotate([0, 90, 0]) {
        cylinder(h = handle_radius * 2, d = handle_radius * 2, center = true);
    }
}

// 取手の接続部分２ (取手のリングの内側に接続するように配置)
translate([-(inner_radius + handle_offset_from_wall), 0, handle_height_center]) {
    rotate([0, 90, 0]) {
        cylinder(h = handle_radius * 2, d = handle_radius * 2, center = true);
    }
}

// 取手のリング部分をカップ本体に接続するための形状（例：TorusとHull）
// より自然な取手にするために、取手のリングとカップ本体を繋ぐ形状を追加します。

// 取手のリング（先ほど作成したもの）を再定義し、カップ本体と結合します。

// マグカップ本体の作成（再定義、取手と結合するため）
module mug_body() {
    difference() {
        // 外側の円筒
        cylinder(h = height, d = outer_diameter, center = false);

        // 内側のくり抜き
        translate([0, 0, base_thickness]) {
            cylinder(h = height - base_thickness, d = inner_diameter, center = false);
        }
    }
}

// 取手のリング部分（よりカップに一体化させる）
module handle_ring() {
    handle_ring_inner_diameter = 30; // 指が入るサイズ
    handle_ring_thickness = 4;      // 取手のリングの太さ

    // 取手がカップのどの部分に付くかの開始点と終了点
    handle_start_angle = 30; // 開始角度 (度)
    handle_end_angle = 150;  // 終了角度 (度)
    handle_arc_length = handle_end_angle - handle_start_angle;

    // 取手のリングの円周方向のオフセット（カップ外壁からの距離）
    handle_radial_offset = 8; // リングの外側がカップ外壁からどれだけ離れるか

    // 取手のリングの回転軸（カップの中心軸）
    rotate_axis = [0, 0, 1];

    // 取手のリングをカップの側面に沿わせるように配置
    // ここでは、取手のリングをカップの円周に沿って配置します。
    // より自然な取手にするために、takeoff angleなども考慮する必要があります。

    // 取手のリングをカップの円周に沿って配置する
    // torus() を利用した方法
    translate([0, 0, handle_height_center]) {
        rotate([90, 0, 0]) {
            difference() {
                // 外側のリング
                minkowski() {
                    cylinder(h = handle_ring_thickness, d = handle_ring_inner_diameter + 2 * handle_ring_thickness, center = true);
                    sphere(r = handle_ring_thickness / 2, $fn = 32);
                }
                // 内側のくり抜き
                cylinder(h = handle_ring_thickness, d = handle_ring_inner_diameter, center = true);
            }
        }
    }
}

// マグカップ全体を結合
union() {
    mug_body();

    // 取手のリング部分をカップ本体に接続する
    // ここでは、hull() を使って取手のリングとカップ本体を滑らかに接続します。
    // 取手のリングの端点とカップ本体の円周上の点を結ぶようにします。

    // 取手のリングの端点（例）
    handle_ring_attach_point_1 = [outer_radius + handle_radial_offset, 0, handle_height_center];
    handle_ring_attach_point_2 = [-(outer_radius + handle_radial_offset), 0, handle_height_center];

    // カップ本体の円周上の点
    mug_attach_point_1 = [outer_radius, 0, handle_height_center];
    mug_attach_point_2 = [-outer_radius, 0, handle_height_center];

    // 簡略化のため、単純な円筒で取手の接続部分を作成し、リングとカップ本体を結合します。
    // より高度な形状を作成するには、customizer や complex boolean operations が必要になります。

    // 取手のリング（再定義、カップ本体に統合）
    handle_ring_thickness = 4;
    handle_ring_diameter = 30; // 指が入るサイズ
    handle_part_radius = 15; // 取手のリングの円周方向の半径 (カップ中心から)

    // 取手のリング部分の形状
    rotate([90, 0, 0]) {
        translate([0, 0, handle_height_center]) {
            difference() {
                // 外側のリング
                minkowski() {
                    cylinder(h = handle_part_radius * 2, d = handle_ring_diameter + 2 * handle_ring_thickness, center = true);
                    sphere(r = handle_ring_thickness / 2, $fn = 32);
                }
                // 内側のくり抜き
                cylinder(h = handle_part_radius * 2, d = handle_ring_diameter, center = true);
            }
        }
    }

    // 取手の接続部分（カップ本体に滑らかに繋げる）
    // 取手のリングの外側とカップ本体の外側を繋ぐ
    union() {
        // 取手のリングの外側
        rotate([90, 0, 0]) {
            translate([0, 0, handle_height_center]) {
                cylinder(h = handle_part_radius * 2, d = handle_ring_diameter + 2 * handle_ring_thickness, center = true);
            }
        }
        // カップ本体の外側
        cylinder(h = height, d = outer_diameter, center = false);

        // 取手のリングの内側とカップ本体の内側を繋ぐ
        // 簡略化のため、取手のリングの外側とカップ本体の外側を直接繋いでいます。
        // より滑らかにするには、hull() や minkowski() を多用する必要があります。

        // 取手のリングの接続部分の作成
        handle_width = 20; // 取手のリングの幅 (カップの円周方向)
        handle_height = 30; // 取手のリングの高さ (カップの軸方向)

        // 取手のリングの端点
        handle_end_radius = outer_radius + handle_radial_offset;
        handle_end_height_offset = handle_height / 2;

        // 取手のリングの形状 (円筒と球の組み合わせ)
        rotate([0, 90, 0]) {
            translate([handle_end_radius, 0, handle_height_center]) {
                cylinder(h = handle_height, d = handle_ring_diameter + 2 * handle_ring_thickness, center = true);
            }
            translate([-handle_end_radius, 0, handle_height_center]) {
                cylinder(h = handle_height, d = handle_ring_diameter + 2 * handle_ring_thickness, center = true);
            }
        }

        // 取手のリングとカップ本体を滑らかに繋ぐ
        hull() {
            // 取手のリングの端点（左側）
            translate([-(outer_radius + handle_radial_offset), 0, handle_height_center]) {
                sphere(r = handle_ring_thickness, $fn = 32);
            }
            // カップ本体の円周上の点（左側）
            translate([-outer_radius, 0, handle_height_center]) {
                sphere(r = handle_ring_thickness, $fn = 32);
            }
        }
        hull() {
            // 取手のリングの端点（右側）
            translate([outer_radius + handle_radial_offset, 0, handle_height_center]) {
                sphere(r = handle_ring_thickness, $fn = 32);
            }
            // カップ本体の円周上の点（右側）
            translate([outer_radius, 0, handle_height_center]) {
                sphere(r = handle_ring_thickness, $fn = 32);
            }
        }
        // 取手のリング全体
        rotate([90, 0, 0]) {
            translate([0, 0, handle_height_center]) {
                difference() {
                    minkowski() {
                        cylinder(h = handle_ring_thickness, d = handle_ring_diameter + 2 * handle_ring_thickness, center = true);
                        sphere(r = handle_ring_thickness / 2, $fn = 32);
                    }
                    cylinder(h = handle_ring_thickness, d = handle_ring_diameter, center = true);
                }
            }
        }
    }
}

// 最終的なマグカップの形状
difference() {
    // マグカップ本体
    mug_body();

    // 取手のリング部分をくり抜く
    // 取手のリングがカップ本体と重なる部分をくり抜く
    handle_ring_height = 30;
    handle_ring_radius = outer_radius + handle_radial_offset; // 取手のリングの中心の半径
    handle_ring_thickness_actual = 4; // 取手のリングの太さ

    // 取手のリングをカップ本体に接続するために、取手のリングの形状をくり抜く
    union() {
        // 取手のリングの外側
        rotate([90, 0, 0]) {
            translate([0, 0, handle_height_center - handle_ring_height/2]) {
                cylinder(h = handle_ring_height, d = handle_ring_diameter + 2 * handle_ring_thickness_actual, center = false);
            }
        }
        // 取手のリングの内側（くり抜く部分）
        rotate([90, 0, 0]) {
            translate([0, 0, handle_height_center - handle_ring_height/2]) {
                cylinder(h = handle_ring_height, d = handle_ring_diameter, center = false);
            }
        }
    }
}


// 最終的なマグカップの形状
union() {
    // マグカップ本体
    difference() {
        cylinder(h = height, d = outer_diameter, center = false);
        translate([0, 0, base_thickness]) {
            cylinder(h = height - base_thickness, d = inner_diameter, center = false);
        }
    }

    // 取手のリング部分
    handle_diameter = 30; // 指が入るサイズ
    handle_thickness = 4; // 取手のリングの太さ
    handle_height_center = height / 2;

    // 取手のリングをカップの外側から飛び出すように配置
    // 取手のリングの中心をカップの中心から offset_from_cup_center だけ離す
    offset_from_cup_center = outer_radius + handle_thickness; // 取手のリングの円周方向の中心位置

    // 取手のリングの形状 (Torus approximation)
    rotate([90, 0, 0]) {
        translate([0, 0, handle_height_center]) {
            difference() {
                // 外側のリング
                minkowski() {
                    cylinder(h = handle_thickness, d = handle_diameter + 2 * handle_thickness, center = true);
                    sphere(r = handle_thickness / 2, $fn = 32);
                }
                // 内側のくり抜き
                cylinder(h = handle_thickness, d = handle_diameter, center = true);
            }
        }
    }

    // 取手の接続部分 (カップ本体と取手のリングを繋ぐ)
    hull() {
        // 取手のリングの左端
        translate([-(offset_from_cup_center), 0, handle_height_center]) {
            sphere(r = handle_thickness, $fn = 32);
        }
        // カップ本体の左側円周上の点
        translate([-outer_radius, 0, handle_height_center]) {
            sphere(r = handle_thickness, $fn = 32);
        }
    }
    hull() {
        // 取手のリングの右端
        translate([offset_from_cup_center, 0, handle_height_center]) {
            sphere(r = handle_thickness, $fn = 32);
        }
        // カップ本体の右側円周上の点
        translate([outer_radius, 0, handle_height_center]) {
            sphere(r = handle_thickness, $fn = 32);
        }
    }

    // 取手のリングをカップ本体に接続するための形状を追加
    handle_connection_width = 20; // 取手の接続部分の幅 (カップの円周方向)
    handle_connection_height = 20; // 取手の接続部分の高さ (カップの軸方向)

    // 取手のリングとカップ本体を滑らかに繋ぐための追加形状
    // 左側の接続
    translate([-(outer_radius + handle_connection_width / 2), 0, handle_height_center - handle_connection_height / 2]) {
        rotate([0, 90, 0]) {
            cylinder(h = handle_connection_width, d = handle_connection_height, center = true);
        }
    }
    // 右側の接続
    translate([outer_radius + handle_connection_width / 2, 0, handle_height_center - handle_connection_height / 2]) {
        rotate([0, 90, 0]) {
            cylinder(h = handle_connection_width, d = handle_connection_height, center = true);
        }
    }

    // 取手のリング自体をカップ本体と結合
    rotate([90, 0, 0]) {
        translate([0, 0, handle_height_center]) {
            difference() {
                minkowski() {
                    cylinder(h = handle_thickness, d = handle_diameter + 2 * handle_thickness, center = true);
                    sphere(r = handle_thickness / 2, $fn = 32);
                }
                cylinder(h = handle_thickness, d = handle_diameter, center = true);
            }
        }
    }
}

// 最終的なコード
difference() {
    // マグカップ本体
    union() {
        // 外側の円筒
        cylinder(h = height, d = outer_diameter, center = false);

        // 取手の接続部分（カップ外周と取手リングを滑らかに繋ぐ）
        handle_radius_outer = outer_radius + 10; // 取手のリングの外側がカップ外壁からどれだけ離れるか
        handle_height_center = height / 2;
        handle_ring_thickness = 4; // 取手のリングの太さ
        handle_ring_diameter = 30; // 指が入るサイズ

        // 取手のリングの端点
        handle_attach_radius_outer = outer_radius + 5; // カップ外壁から取手リングの接続点までの距離

        // 取手のリングの左側接続
        hull() {
            translate([-handle_attach_radius_outer, 0, handle_height_center]) {
                sphere(r = handle_ring_thickness, $fn = 32);
            }
            translate([-outer_radius, 0, handle_height_center]) {
                sphere(r = handle_ring_thickness, $fn = 32);
            }
        }
        // 取手のリングの右側接続
        hull() {
            translate([handle_attach_radius_outer, 0, handle_height_center]) {
                sphere(r = handle_ring_thickness, $fn = 32);
            }
            translate([outer_radius, 0, handle_height_center]) {
                sphere(r = handle_ring_thickness, $fn = 32);
            }
        }

        // 取手のリング部分 (プレースホルダー)
        // 最終的な形状はunion()で本体と結合される
        rotate([90, 0, 0]) {
            translate([0, 0, handle_height_center]) {
                difference() {
                    minkowski() {
                        cylinder(h = handle_ring_thickness, d = handle_ring_diameter + 2 * handle_ring_thickness, center = true);
                        sphere(r = handle_ring_thickness / 2, $fn = 32);
                    }
                    cylinder(h = handle_ring_thickness, d = handle_ring_diameter, center = true);
                }
            }
        }
    }

    // 内側のくり抜き
    translate([0, 0, base_thickness]) {
        cylinder(h = height - base_thickness, d = inner_diameter, center = false);
    }

    // 取手のリング部分 (くり抜く対象)
    handle_ring_thickness = 4; // 取手のリングの太さ
    handle_ring_diameter = 30; // 指が入るサイズ
    handle_height_center = height / 2;
    handle_radial_offset = 10; // カップ外壁からの取手のリングの開始点のオフセット

    // 取手のリングの形状
    rotate([90, 0, 0]) {
        translate([0, 0, handle_height_center]) {
            difference() {
                // 外側のリング
                minkowski() {
                    cylinder(h = handle_ring_thickness, d = handle_ring_diameter + 2 * handle_ring_thickness, center = true);
                    sphere(r = handle_ring_thickness / 2, $fn = 32);
                }
                // 内側のくり抜き
                cylinder(h = handle_ring_thickness, d = handle_ring_diameter, center = true);
            }
        }
    }
}

// 最終的なマグカップの形状
union() {
    // マグカップ本体
    difference() {
        cylinder(h = height, d = outer_diameter, center = false);
        // 底面のくり抜き
        translate([0, 0, base_thickness]) {
            cylinder(h = height - base_thickness, d = inner_diameter, center = false);
        }
    }

    // 取手のリング部分
    handle_ring_radius_outer = outer_diameter / 2 + 12; // 取手のリングの外側がカップ外壁からどれだけ飛び出すか
    handle_height_center = height / 2;
    handle_ring_thickness = 4; // 取手のリングの太さ
    handle_ring_diameter_inner = 30; // 指が入るサイズ

    // 取手のリングの形状
    rotate([90, 0, 0]) {
        translate([0, 0, handle_height_center]) {
            difference() {
                // 外側のリング
                minkowski() {
                    cylinder(h = handle_ring_thickness, d = handle_ring_diameter_inner + 2 * handle_ring_thickness, center = true);
                    sphere(r = handle_ring_thickness / 2, $fn = 32);
                }
                // 内側のくり抜き
                cylinder(h = handle_ring_thickness, d = handle_ring_diameter_inner, center = true);
            }
        }
    }

    // 取手の接続部分（カップ本体と取手のリングを繋ぐ）
    hull() {
        // 取手のリングの左端
        translate([-(outer_radius + 10), 0, handle_height_center]) { // カップ外壁から少し離した位置
            sphere(r = handle_ring_thickness, $fn = 32);
        }
        // カップ本体の左側円周上の点
        translate([-outer_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
    }
    hull() {
        // 取手のリングの右端
        translate([outer_radius + 10, 0, handle_height_center]) { // カップ外壁から少し離した位置
            sphere(r = handle_ring_thickness, $fn = 32);
        }
        // カップ本体の右側円周上の点
        translate([outer_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
    }
}


// 最終的なマグカップの形状
union() {
    // マグカップ本体
    difference() {
        cylinder(h = height, d = outer_diameter, center = false);
        // 内側のくり抜き
        translate([0, 0, base_thickness]) {
            cylinder(h = height - base_thickness, d = inner_diameter, center = false);
        }
    }

    // 取手のリング部分
    handle_ring_thickness = 4;       // 取手のリングの太さ
    handle_ring_diameter = 30;       // 指が入るサイズ
    handle_height_center = height / 2;
    handle_outer_radius = outer_diameter / 2 + 12; // 取手のリングの外側がカップ外壁からどれだけ飛び出すか

    // 取手のリングの形状
    rotate([90, 0, 0]) {
        translate([0, 0, handle_height_center]) {
            difference() {
                // 外側のリング
                minkowski() {
                    cylinder(h = handle_ring_thickness, d = handle_ring_diameter + 2 * handle_ring_thickness, center = true);
                    sphere(r = handle_ring_thickness / 2, $fn = 32);
                }
                // 内側のくり抜き
                cylinder(h = handle_ring_thickness, d = handle_ring_diameter, center = true);
            }
        }
    }

    // 取手の接続部分（カップ本体と取手のリングを繋ぐ）
    hull() {
        // 取手のリングの左端
        translate([-(outer_radius + 10), 0, handle_height_center]) { // カップ外壁から少し離した位置
            sphere(r = handle_ring_thickness, $fn = 32);
        }
        // カップ本体の左側円周上の点
        translate([-outer_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
    }
    hull() {
        // 取手のリングの右端
        translate([outer_radius + 10, 0, handle_height_center]) { // カップ外壁から少し離した位置
            sphere(r = handle_ring_thickness, $fn = 32);
        }
        // カップ本体の右側円周上の点
        translate([outer_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
    }
}

// 最終的なマグカップの形状
union() {
    // マグカップ本体
    difference() {
        cylinder(h = height, d = outer_diameter, center = false);
        // 内側のくり抜き
        translate([0, 0, base_thickness]) {
            cylinder(h = height - base_thickness, d = inner_diameter, center = false);
        }
    }

    // 取手のリング部分
    handle_ring_thickness = 4;       // 取手のリングの太さ
    handle_ring_diameter = 30;       // 指が入るサイズ
    handle_height_center = height / 2;
    handle_connection_offset = 10;   // カップ外壁からの取手接続部のオフセット

    // 取手のリングの円周方向の中心位置
    handle_ring_center_radius = outer_radius + handle_connection_offset + handle_ring_thickness;

    // 取手のリングの形状
    rotate([90, 0, 0]) {
        translate([0, 0, handle_height_center]) {
            difference() {
                // 外側のリング
                minkowski() {
                    cylinder(h = handle_ring_thickness, d = handle_ring_diameter + 2 * handle_ring_thickness, center = true);
                    sphere(r = handle_ring_thickness / 2, $fn = 32);
                }
                // 内側のくり抜き
                cylinder(h = handle_ring_thickness, d = handle_ring_diameter, center = true);
            }
        }
    }

    // 取手の接続部分（カップ本体と取手のリングを繋ぐ）
    hull() {
        // 取手のリングの左端
        translate([-(handle_ring_center_radius), 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
        // カップ本体の左側円周上の点
        translate([-outer_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
    }
    hull() {
        // 取手のリングの右端
        translate([handle_ring_center_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
        // カップ本体の右側円周上の点
        translate([outer_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
    }
}

// 最終的なマグカップの形状
union() {
    // マグカップ本体
    difference() {
        cylinder(h = height, d = outer_diameter, center = false);
        // 内側のくり抜き
        translate([0, 0, base_thickness]) {
            cylinder(h = height - base_thickness, d = inner_diameter, center = false);
        }
    }

    // 取手のリング部分
    handle_ring_thickness = 4;       // 取手のリングの太さ
    handle_ring_diameter = 30;       // 指が入るサイズ
    handle_height_center = height / 2;
    handle_outer_offset = 12;        // カップ外壁からの取手のリング外側の飛び出し量

    // 取手のリングの円周方向の中心半径
    handle_ring_center_radius = outer_radius + handle_outer_offset;

    // 取手のリングの形状
    rotate([90, 0, 0]) {
        translate([0, 0, handle_height_center]) {
            difference() {
                // 外側のリング
                minkowski() {
                    cylinder(h = handle_ring_thickness, d = handle_ring_diameter + 2 * handle_ring_thickness, center = true);
                    sphere(r = handle_ring_thickness / 2, $fn = 32);
                }
                // 内側のくり抜き
                cylinder(h = handle_ring_thickness, d = handle_ring_diameter, center = true);
            }
        }
    }

    // 取手の接続部分（カップ本体と取手のリングを繋ぐ）
    hull() {
        // 取手のリングの左端
        translate([-(handle_ring_center_radius), 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
        // カップ本体の左側円周上の点
        translate([-outer_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
    }
    hull() {
        // 取手のリングの右端
        translate([handle_ring_center_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
        // カップ本体の右側円周上の点
        translate([outer_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
    }
}