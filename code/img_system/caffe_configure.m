function caffe_configure

model_def_file = '../ext_feature/model/deploy.prototxt';
model_file = '../ext_feature/model/bvlc_reference_caffenet.caffemodel';

matcaffe_init(1, model_def_file, model_file);

