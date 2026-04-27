// 3段階段状ピラミッド
union() {
    // 1段目 (底辺): 60mm × 60mm × 高さ 10mm
    translate([0, 0, 0])
    cube([60, 60, 10], center=true);
    
    // 2段目 (中段): 40mm × 40mm × 高さ 10mm
    translate([0, 0, 10])
    cube([40, 40, 10], center=true);
    
    // 3段目 (上段): 20mm × 20mm × 高さ 10mm
    translate([0, 0, 20])
    cube([20, 20, 10], center=true);
}