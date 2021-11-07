direct = "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Val_Results/LeRes_Trimmed_4Batch";
% direct = "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Val_Results/MiDas_Trimmed_4Batch";
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
    label = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Labels_Trimmed/" ...
      + folder{f} + ".png");
    BMD_dist = imread(direct + "/" + folder{f} + ".png");
    label = imresize(label, [length(BMD_dist(:,1)) length(BMD_dist(1,:))]);
    BMD_dist = im2uint8(BMD_dist); 
%     BMD_dist = imcomplement(BMD_dist);    
    
    for i = 1:length(label(:,1,1))
        for j = 1:length(label(1,:,1))
            if label(i,j,1) == 0 && label(i,j,2) == 0 && label(i,j,3) == 0
                BMD_dist(i,j) = 255;
            end
        end
    end
    
    imwrite(BMD_dist, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Val_Results/" + ...
        "Processed_LeRes_Trimmed_4Batch/" + folder{f} + ".png")
end