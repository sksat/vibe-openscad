// L字金具（L-bracket）のOpenSCADコード

horizontal_flange = rectangle(
    x1: -3,
    y1: -40,
    x2: +3,
    y2: +40
);

vertical_flange = rectangle(
    x1: -3,
    y1: 0,
    x2: +3,
    y2: +3
);

L_shape = horizontal_flange + vertical_flange;

// フラクタルの内側の穴
horizontal_counterbottom_holes = [
    rectangle(
        x1: -3, 
        y1: -40 - 8mm, 
        x2: +3, 
        y2: -40 - 8mm
    ),
    rectangle(
        x1: -3, 
        y1: -40 + 8mm, 
        x2: +3, 
        y2: -40 + 8mm
    )
];

vertical_counterbottom_holes = [
    rectangle(
        x1: -3, 
        y1: 0 - 8mm, 
        x2: +3, 
        y2: 0 - 8mm
    ),
    rectangle(
        x1: -3, 
        y1: 0 + 8mm, 
        x2: +3, 
        y2: 0 + 8mm
    )
];

L_shape = L_shape + combine(horizontal_counterbottom_holes, vertical_counterbottom_holes);