directory = dir("~/MATLAB/geoPose3K_cyl");
folder = {};
% First two to skip the '.' and '..' fields at the start of dir (also need
% to skip the README at directory(5).name
folder{1} = directory(3).name;
folder{2} = directory(4).name;

for i = 6:length(directory)
    folder{i-3} = directory(i).name;
end

for f = 1:length(folder)
   dist = readmatrix("/media/anaru/Seagate Expansion Drive/geoPose3K_cyl/" ...
       + folder{f} + "/cyl/distance.csv");
   dist(dist < 0) = nan;
   one = ones(size(dist));
   dist = dist - (one .* min(min(dist)));
   a = max(max(dist));
   dist = dist ./ a;
   dist = dist .* 254;
   dist(isnan(dist)) = 255;
   dist = round(dist);
   dist = uint8(dist);
   imwrite(dist, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Normalised_Dist/" ...
       + folder{f} + ".jpg") 
end