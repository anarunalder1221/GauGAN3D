directory = dir("~/MATLAB/geoPose3K_cyl");
folder = {};
% First two to skip the '.' and '..' fields at the start of dir (also need
% to skip the README at directory(5).name
folder{1} = directory(3).name;
folder{2} = directory(4).name;

for f = 6:length(directory)
    folder{f-3} = directory(f).name;
end

for f = 1%:length(folder)
   dist_og = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Normalised_Dist/" ...
       + folder{f} + ".jpg");
   dist_gen = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Results/" ...
       + "geoPose3K_DistMap_1Batch/test_latest/images/synthesized_image/" ...
       + folder{f} + ".png");
   dist_gen = rgb2gray(dist_gen);
   dist_og = imresize(dist_og, [length(dist_gen(:,1)), length(dist_gen(1,:))]);
   dist_gen(dist_og > 254) = 255;
%    dist_gen = imbinarize(dist_gen, 0.999);
%    dist_og = imbinarize(dist_og, 0.999);
end