direct = "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/BMD_";
directory = dir(direct);
folder = {};
% First two to skip the '.' and '..' fields at the start of dir (also need
% to skip the README at directory(5).name
% folder{1} = directory(3).name;
% folder{2} = directory(4).name;

for f = 3:length(directory)
    [~, name, ~] = fileparts(directory(f).name);
    folder{f-2} = name;
end

for f = 1:length(folder)
   image = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Images_Trimmed/" ...
      + folder{f} + ".jpg");
   dist = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Normalised_Dist_Trimmed/" ...
      + folder{f} + ".jpg");
   label = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Labels_Trimmed/" ...
      + folder{f} + ".png");
  
   if length(image(1,:,1)) >= length(image(:,1,1))
       imwrite(image, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Reduced_Images_Trimmed/" ...
           + folder{f} + ".jpg") 
       imwrite(dist, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Reduced_Dist_Trimmed/" ...
           + folder{f} + ".jpg") 
       imwrite(label, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Reduced_Labels_Trimmed/" ...
           + folder{f} + ".png") 
   end
end