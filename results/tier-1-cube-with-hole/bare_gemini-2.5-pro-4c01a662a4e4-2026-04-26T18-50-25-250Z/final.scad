// 50mm角の立方体の中央に直径20mmの貫通穴をz軸方向に開ける

difference() {
    // 50mm角の立方体を中央に配置
    cube(size = 50, center = true);
    
    // 直径20mm、高さ51mm（立方体より少し長い）の円柱を中央に配置
    // 高さを長くすることで、ブーリアン演算が確実に行われるようにする
    cylinder(h = 51, d = 20, center = true);
}