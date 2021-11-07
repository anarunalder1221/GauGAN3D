directory = dir("~/MATLAB/geoPose3K_cyl");
folder = {};
% First two to skip the '.' and '..' fields at the start of dir (also need
% to skip the README at directory(5).name
folder{1} = directory(3).name;
folder{2} = directory(4).name;

for f = 6:length(directory)
    folder{f-3} = directory(f).name;
end

for f = 1:length(folder)
   label = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Labels/" ...
       + folder{f} + ".png");
   for i = 1:length(label(:,1,1))
       for j = 1:length(label(1,:,1))
           if label(i,j,:) == ones(3,1) * 255
               label(i,j,:) = ones(3,1) * 250;
           end
       end
   end
   imwrite(label, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Labels_2/" ...
       + folder{f} + ".png") 
end