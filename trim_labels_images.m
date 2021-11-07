directory = dir("~/MATLAB/geoPose3K_cyl");
folder = {};
% First two to skip the '.' and '..' fields at the start of dir (also need
% to skip the README at directory(5).name
folder{1} = directory(3).name;
folder{2} = directory(4).name;

for f = 6:length(directory)
    folder{f-3} = directory(f).name;
end

for f = 2265:length(folder)
   image = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Images/" ...
      + folder{f} + ".jpg");
   dist = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Normalised_Dist/" ...
      + folder{f} + ".jpg");
   label = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Labels_2/" ...
      + folder{f} + ".png");
  if ndims(image) == 2
      disp([folder{f}, ' f = ', f, ' 2D image'])
      continue;
  end
   imageBW = rgb2gray(image);
   
   i_density = zeros(1,length(imageBW(:,1)));
   j_density = zeros(1,length(imageBW(1,:)));
   for i = 1:length(i_density)
       for j_i = 1:length(j_density)
           if imageBW(i, j_i) > 9
               i_density(i) = i_density(i) + 1;
           end
       end
   end
   for j = 1:length(j_density)
       for i_j = 1:length(i_density)
           if imageBW(i_j,j) > 9
               j_density(j) = j_density(j) + 1;
           end
       end
   end
   % Assuming that the lenght of j (the horizontal) will always be larger
   i_offset = 1;
   j_offset = 1;
   iB_offset = length(i_density);
   jB_offset = length(j_density);
   i_change = 0;
   j_change = 0;
   while(true)
       temp = [(i_density(i_offset))/(length(image(1,:,1)) - j_change), ...
           (j_density(j_offset))/(length(image(:,1,1)) - i_change), ...
           (i_density(iB_offset))/(length(image(1,:,1)) - j_change), ...
           (j_density(jB_offset))/(length(image(:,1,1)) - i_change)];
       min_val = min(temp);
       if min_val >= 1
           break
       end
       if min_val == temp(1)
           image(i_offset,:,:) = 0;
           i_offset = i_offset + 1;
           i_change = i_change + 1;
       elseif min_val == temp(2)
           image(:,j_offset,:) = 0;
           j_offset = j_offset + 1;
           j_change = j_change + 1;
       elseif min_val == temp(3)
           image(iB_offset,:,:) = 0;
           iB_offset = iB_offset - 1;
           i_change = i_change + 1;
       elseif min_val == temp(4)
           image(:,jB_offset,:) = 0;
           jB_offset = jB_offset - 1;
           j_change = j_change + 1;
       end
   end
   
   xmin = 0;
   ymin = 0;
   xmax = 0;
   ymax = 0;
   i_len = length(image(:,1,1));
   j_len = length(image(1,:,1));
   imageBW = rgb2gray(image);
   for i = 1:i_len
       for j = 1:j_len
           % We do the > 9 again just to get stragglers after the first pass
           if imageBW(i,j) > 9 && ~xmin
               ymin = i;
               xmin = j;
           end
           if imageBW(i_len - i + 1, j_len - j + 1) > 9 && ~xmax
               ymax = i_len - i;
               xmax = j_len - j;
           end
           if xmin && ymin && xmax && ymax
               break
           end
       end
       if xmin && ymin && xmax && ymax
           break
       end
   end
   image = imcrop(image, [xmin, ymin, xmax - xmin, ymax - ymin]);
   dist = imcrop(dist, [xmin, ymin, xmax - xmin, ymax - ymin]);
   label = imcrop(label, [xmin, ymin, xmax - xmin, ymax - ymin]);
   
   imwrite(image, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Images_Trimmed/" ...
       + folder{f} + ".jpg") 
   imwrite(dist, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Normalised_Dist_Trimmed/" ...
       + folder{f} + ".jpg") 
   imwrite(label, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Labels_Trimmed/" ...
       + folder{f} + ".png") 
end