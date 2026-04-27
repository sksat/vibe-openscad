// 3段階の階段状ピラミッド
bottom_box = [60, 60, 10];
middle_box = [40, 40, 10];
top_box = [20, 20, 10];

union() {
  // 底段
  translate([-bottom_box[0]/2, -bottom_box[1]/2, 0])
    cube(bottom_box);
  // 中段
  translate([-middle_box[0]/2, -middle_box[1]/2, bottom_box[2]])
    cube(middle_box);
  // 上段
  translate([-top_box[0]/2, -top_box[1]/2, bottom_box[2] + middle_box[2]])
    cube(top_box);
}