direct = "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/Labels_2";
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
% 12, 246
for f = 12%%:length(folder)   % This will take forever trying to do every scene at once.
    label = imread(direct + "/" + folder{f} + ".png");
    dist = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" + ...
        "Results/geoPose3K_Trimmed_Dist_4Batch/test_latest/images/" + ...
        "synthesized_image/"+ folder{f} + ".png");
%     dist = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" + ...
%         "BMD_for_SPADE/Processed_LeRes_Trimmed_4Batch/" + folder{f} + ".png");
    image = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" + ...
        "Results/geoPose3K_Trimmed_4Batch/test_latest/images/synthesized_image/" + ...
        folder{f} + ".png");
%     dist = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" + ...
%         "Normalised_Dist/" + folder{f} + ".jpg");
%     image = imread("/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" + ...
%         "Images/" + folder{f} + ".jpg");
    label = imresize(label, [256 256]);
%     dist = imresize(dist, [256 256]);
%     image = imresize(image, [256 256]);
    dist = rgb2gray(dist);
    
    for i = 1:length(label(:,1,1))
        for j = 1:length(label(1,:,1))
            if label(i,j,1) == 0 && label(i,j,2) == 0 && label(i,j,3) == 0
                dist(i,j) = 255;
            end
        end
    end

    %Creating the xyz vectors for 3D plotting
    count = 0;
    modVal = 1;    %Spacing between points behind provided depth data
    for i = 1:length(dist(:,1))
        for j = 1:length(dist(1,:))
            if dist(i,j) ~= 256
                check = 0;
                testLen = 0;
                if i == 1 || j == 1 || i == length(dist(:,1)) || j == length(dist(1,:))
                    testLen = dist(i,j);
                elseif i == -1 || i == length(dist(:,1)) || j == -1 || ...
                        j == length(dist(1,:)) || dist(i-1,j) == 255
                    testLen = 255;
                elseif dist(i-1,j) > dist(i,j)
                    testLen = dist(i-1,j);
                else
                    testLen = dist(i,j);
                end
                for k = dist(i,j):testLen
                    if mod(check, modVal) == 0 || k == testLen
                        count = count + 1;
                    end
                    check = check + 1;
                end
            end
        end
    end
    x = zeros(count, 1, 'int16');
    y = zeros(count, 1, 'int16');
    z = zeros(count, 1, 'int16');
    c = ones(count, 3, 'single') .* 255;
    
    count = 0;
    for i = 1:length(dist(:,1))
        for j = 1:length(dist(1,:))
            if dist(i,j) ~= 256
                check = 0;
                testLen = 0;
                if i == 1 || j == 1 || i == length(dist(:,1)) || j == length(dist(1,:))
                    testLen = dist(i,j);
                elseif i == -1 || i == length(dist(:,1)) || j == -1 || ...
                        j == length(dist(1,:)) || dist(i-1,j) == 255
                    testLen = 255;
                elseif dist(i-1,j) > dist(i,j)
                    testLen = dist(i-1,j);
                else
                    testLen = dist(i,j);
                end
                for k = dist(i,j):testLen
                    if mod(check, modVal) == 0 || k == testLen
                        count = count + 1;
                        x(count) = j;
                        y(count) = i;
                        z(count) = k;
                        c(count,1) = image(i,j,1);
                        c(count,2) = image(i,j,2);
                        c(count,3) = image(i,j,3);
                    end
                    check = check + 1;
                end
            end
        end
    end
    % Writing xyz vectors and c colour vector to hard drive
%     writematrix(x, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" ...
%         + "Scenes/geoPose3K_Trimmed_ImageDist_1Batch/" + folder{f} + "/x_1.csv");
%     writematrix(y, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" ...
%         + "Scenes/geoPose3K_Trimmed_ImageDist_1Batch/" + folder{f} + "/y_1.csv");
%     writematrix(z, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" ...
%         + "Scenes/geoPose3K_Trimmed_ImageDist_1Batch/" + folder{f} + "/z_1.csv");
%     writematrix(c, "/media/anaru/Seagate Expansion Drive/geoPose3K_SPADE/" ...
%         + "Scenes/geoPose3K_Trimmed_ImageDist_1Batch/" + folder{f} + "/c_1.csv");
end

% To visualise (make modVal/'VALUE' 'VALUE smaller for more edge (black))
% scatter3(x,z,-y,modVal/100,'LineWidth',0.1,'MarkerEdgeColor','k',...
%     'MarkerFaceColor','b')
% To visualise using the semantic image colours
scatter3(x,z,-y,2,c/255, '.')
% scatter3(x,z,-y,2,c/255, 'LineWidth', 2)
set(gca, 'Color', 'k')
set(gcf,'unit','norm','position',[0 0 1 1])
axis([0 260 0 260 -260 0])
pbaspect([1 1 1])
view(0,0)