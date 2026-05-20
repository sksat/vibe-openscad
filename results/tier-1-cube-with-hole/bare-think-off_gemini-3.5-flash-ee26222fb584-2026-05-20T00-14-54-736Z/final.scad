$fn = 100;

difference() {
    // 50mm角の立方体（中央配置）
    cube(50, center = true);
    
    // z軸方向の貫通穴（直径20mm、高さは貫通させるために少し長めの52mmに設定）
    cylinder(h = 52, d = 20, center = true);
}