direct = "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Val_Results/" ...
    + "Processed_MiDas_Trimmed_4Batch";
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

% For images generated at 256x256 pixels
dist_4Batch_diff = 0;
imageDist_1Batch_diff = 0;
imageDist_4Batch_diff = 0;
LeRes_4Batch_diff = 0;
MiDas_4Batch_diff = 0;
for f = 10:20    %%:length(folder)
    orig_dist = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" + ...
        "Normalised_Dist_Trimmed/" + folder{f} + ".jpg");
    dist_4Batch = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" + ...
        "Val_Results/geoPose3K_Trimmed_Dist_4Batch/test_latest/images/" + ...
        "synthesized_image/" + folder{f} + ".png");
    imageDist_1Batch = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" + ...
        "Val_Results/geoPose3K_Trimmed_ImageDist_1Batch/test_latest/images/" + ...
        "synthesized_image/" + folder{f} + ".png");
    imageDist_4Batch = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" + ...
        "Val_Results/geoPose3K_Trimmed_ImageDist_4Batch/test_latest/images/" + ...
        "synthesized_image/" + folder{f} + ".png");
    LeRes_4Batch = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" + ...
        "Val_Results/Processed_LeRes_Trimmed_4Batch/" + folder{f} + ".png");
    MiDas_4Batch = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" + ...
        "Val_Results/Processed_MiDas_Trimmed_4Batch/" + folder{f} + ".png");
    orig_dist = imresize(orig_dist, [256 256]);
    dist_4Batch = rgb2gray(dist_4Batch);
    imageDist_1Batch = rgb2gray(imageDist_1Batch);
    imageDist_4Batch = rgb2gray(imageDist_4Batch);
    LeRes_4Batch = imresize(LeRes_4Batch, [256 256]);
    MiDas_4Batch = imresize(MiDas_4Batch, [256 256]);
    
    dist_4Batch_diff = dist_4Batch_diff + ...
        sum(sum(abs(single(orig_dist) - single(dist_4Batch))));
    imageDist_1Batch_diff = imageDist_1Batch_diff + ...
        sum(sum(abs(single(orig_dist) - single(imageDist_1Batch))));
    imageDist_4Batch_diff = imageDist_4Batch_diff + ...
        sum(sum(abs(single(orig_dist) - single(imageDist_4Batch))));
    LeRes_4Batch_diff = LeRes_4Batch_diff + ...
        sum(sum(abs(single(orig_dist) - single(LeRes_4Batch))));
    MiDas_4Batch_diff = MiDas_4Batch_diff + ...
        sum(sum(abs(single(orig_dist) - single(MiDas_4Batch))));
end
display(sort([dist_4Batch_diff, imageDist_1Batch_diff, imageDist_4Batch_diff, ...
    LeRes_4Batch_diff, MiDas_4Batch_diff]))