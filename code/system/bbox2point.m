function point = bbox2point(tmp_bbox)

point = [tmp_bbox(1), tmp_bbox(2); tmp_bbox(1)+tmp_bbox(3), tmp_bbox(2); ...
                tmp_bbox(1) + tmp_bbox(3), tmp_bbox(2) + tmp_bbox(4); tmp_bbox(1), tmp_bbox(2)+tmp_bbox(4)];