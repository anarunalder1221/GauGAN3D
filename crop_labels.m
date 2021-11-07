directory = dir("~/MATLAB/geoPose3K_cyl");
folder = {};
% First two to skip the '.' and '..' fields at the start of dir (also need
% to skip the README at directory(5).name
folder{1} = directory(3).name;
folder{2} = directory(4).name;

for f = 6:length(directory)
    folder{f-3} = directory(f).name;
end

% skip = [];
% for f = 1:length(folder)
for f = [494, 1029, 1119, 1353, 1573, 1574, 1622, 1685, 1893, 1976, 1977]
   label = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Labels_2/" ...
       + folder{f} + ".png");
   dist = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Normalised_Dist/" ...
       + folder{f} + ".jpg");
   image = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Images/" ...
       + folder{f} + ".jpg");
%    if ndims(image) == 2
%        skip = [skip, f];
%        continue;
%        image = rgb2gray(image);
%    end
   for i = 1:length(label(:,1,1))
       for j = 1:length(label(1,:,1))
%            if image(i,j,1) > 9 && image(i,j,2) > 9 && image(i,j,3) > 9
           if image(i,j) > 9
               break;
           end
           label(i,j,:) = ones(3,1) * 255;
           dist(i,j) = 255;
       end
       m = length(label(1,:,1));
       for k = 0:(length(label(1,:,1)) - 1)
%            if image(i,m-k,1) > 9 && image(i,m-k,2) > 9 && image(i,m-k,3) > 9
           if image(i,j) > 9
               break;
           end
           label(i,m-k,:) = ones(3,1) * 255;
           dist(i,m-k) = 255;
       end
   end
   imwrite(label, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Labels_Cropped/" ...
       + folder{f} + ".png") 
   imwrite(dist, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Normalised_Dist_Cropped/" ...
       + folder{f} + ".jpg") 
end