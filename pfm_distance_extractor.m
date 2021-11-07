% This extractor might not be necessary, might be more beneficial to
% process the data in MATLAB first before extracting data for learning
% (this is due to .pfm files being almost half the size of .csv or .txt
% files.

directory = dir("~/MATLAB/geoPose3K_cyl");
folder = {};
% First two to skip the '.' and '..' fields at the start of dir (also need
% to skip the README at directory(5).name
folder{1} = directory(3).name;
folder{2} = directory(4).name;

for i = 6:length(directory)
    folder{i-3} = directory(i).name;
end

% Semantic images are blurred, will need to redefine these points as one of
% the labels listed below, probably by using what is closest out of the
% labels around the point that are defined.
labels = [0.00, 0.00, 0.00;     % Sky
    0.46, 0.86, 0.39;     % Forest / Wood
    0.61, 0.85, 0.86;     % Glacier
    0.01, 0.53, 0.86;     % Water
    0.38, 0.35, 0.34;     % Cliff
    0.94, 0.95, 0.78;     % Bare Rock / Moor
    0.82, 0.95, 0.78;     % Scree
    0.80, 0.73, 0.74;     % Fell
    0.72, 0.86, 0.41;     % Grassland
    0.90, 0.95, 0.53;     % Shingle
    0.38, 0.38, 0.38;     % Sinkhole (is close to Cliff code)
    1.00, 1.00, 1.00] ... % Unknown (could justify snow/rock maybe? but is probably just no layer data)
    * 255;                % To convert to 0-255 RGB scale
labels = round(labels);

% for j = 1:length(folder)
%     temp = pfs_read_image("~/MATLAB/geoPose3K_cyl/" + folder{j} + ...
%         "/cyl/distance_crop.pfm");
%     %For local PC
%     writematrix(temp, "~/MATLAB/geoPose3K_cyl/" + folder{j} + ...
%         "/cyl/distance.csv");
%     delete("~/MATLAB/geoPose3K_cyl/" + folder{j} + ...
%         "/cyl/distance_crop.pfm");
%     %For hard drive (Seagate Expansion Drive)
%     writematrix(temp, "/media/anaru/Seagate Expansion Drive/geoPose3K_cyl/" ...
%         + folder{j} + "/cyl/distance.csv");
% end

%Note: Use assume FOV is VFOV, if it looks wrong, try HFOV instead
%Aspect ratio = HFOV/VFOV for fisheye lens (might be incorrect for this)
%Aspect ratio = tan(HFOV*0.5)/tan(VFOV*0.5)
%Use cropped image aspect ratio for now, change to original image aspect
%ratio if this looks weird [using original image AR now]
%Probably will have to assign the semantic labels to the pixels before
%extrapalating them out into meters

%Folder flickr_sge_8419452403_8c4f8225cb_8370_38349404@N02 is missing some
%data (something weird happened when copying). This is at f = 1925. Come
%back to this later when it is fixed.
% for f = 1926:length(folder)
f = 1925;
    dist = pfs_read_image("~/MATLAB/geoPose3K_cyl/" + folder{f} + ...
        "/cyl/distance_crop.pfm");
    info_struct = importdata("~/MATLAB/geoPose3K_cyl/" + folder{f} + "/info.txt");
    info = info_struct.data;
    semantic = imread("~/MATLAB/geoPose3K_cyl/" + folder{f} + ...
        "/cyl/labels_crop.png");
    
    %Semantic image preprocessing
    %Initial attempt by making unknown colours white (i.e. missing data). This
    %is crude but a start.
    % for i = 1:length(semantic(:,1,1))
    %     for j = 1:length(semantic(1,:,1))
    %         colourCheck = false;
    %         for c = 1:length(labels(:,1))
    %             if transpose(squeeze(semantic(i,j,:))) == labels(c,:)
    %                 colourCheck = true;
    %                 break
    %             end
    %         end
    %         if ~colourCheck
    %             semantic(i,j,:) = [255 255 255];
    %         end
    %     end
    % end
    %Better "Nearest Neighbour" approach where only vaild labels that elsewhere
    %exist in the image are used to fill blurred sections.
    imColours = zeros(1, 3);
    for i = 1:length(semantic(:,1,1))
        for j = 1:length(semantic(1,:,1))
            colourCheck = false;
            colour = transpose(squeeze(semantic(i,j,:)));
            for c = 1:length(labels(:,1))
                if colour == labels(c,:)
                    for v = 1:length(imColours(:,1))
                        if imColours(v,:) == colour
                            colourCheck = true;
                            break
                        end
                    end
                    if ~colourCheck
                        imColours = [imColours; colour];
                    end
                end
            end
        end
    end
    for i = 1:length(semantic(:,1,1))
        for j = 1:length(semantic(1,:,1))
            colourCheck = false;
            colour = transpose(squeeze(semantic(i,j,:)));
            for c = 1:length(imColours(:,1))
                if colour == imColours(c,:)
                    colourCheck = true;
                    break
                end
            end
            if ~colourCheck
                cNorm = 999999999;
                index = 0;
                for p = 1:length(imColours(:,1))
                    if norm(single(colour) - single(imColours(p,:))) < cNorm
                        cNorm = norm(single(colour) - single(imColours(p,:)));
                        index = p;
                    end
                end
                semantic(i,j,:) = imColours(index,:);
            end
        end
    end
    
    %Using original image with provided fov as it seems it is for the original
    %image, then scaling it down by the same ratio that the size of the cropped
    %image is compared to the original image to get the cropped image fov.
    orig = imread("~/MATLAB/geoPose3K_cyl/" + folder{1} + "/photo.jpeg");
    aspectRatio = length(orig(1,:,1))/length(orig(:,1,1));
    vfovOrig = info(5,1);       %in radians
    hfovOrig = atan(aspectRatio * tan(vfovOrig * 0.5))/0.5;
    vfov = vfovOrig * (length(dist(:,1))/length(orig(:,1,1)));
    hfov = hfovOrig * (length(dist(1,:))/length(orig(1,:,1)));
    
    hozAngles = zeros(1, length(dist(1,:)));
    hozSpace = linspace(hfov/2, 0, (length(hozAngles)+1)/2);
    for i = 1:(length(hozSpace) - 1)    % Never have to write zero in as hozAngles is initialised with zeros
        hozAngles(i) = hozSpace(i);
        hozAngles(length(hozAngles) - i + 1) = hozSpace(i);
    end
    hozDist = zeros(length(dist(:,1)), length(dist(1,:)), 'single');
    for i = 1:length(hozDist(:,1))
        for j = 1:length(hozDist(1,:))
            if dist(i,j) == -1
                hozDist(i,j) = -1;
            else
                hozDist(i,j) = dist(i,j)/tan(hozAngles(j));
            end
        end
    end
    
    vertAngles = zeros(1, length(dist(:,1)));
    vertSpace = linspace(vfov/2, 0, (length(vertAngles)+1)/2);
    for i = 1:(length(vertSpace) -1)
        vertAngles(i) = vertSpace(i);
        vertAngles(length(vertAngles) - i + 1) = vertSpace(i);
    end
    vertDist = zeros(length(dist(:,1)), length(dist(1,:)), 'single');
    for i = 1:length(vertDist(:,1))
        for j = 1:length(vertDist(1,:))
            if dist(i,j) == -1
                vertDist(i,j) = -1;
            else
                vertDist(i,j) = tan(vertAngles(i)) * dist(i,j);
            end
        end
    end
    
    % Worry about the resizing of pixels to meters using the above later, other
    % things are more important than it. Using FOV to convert pixels to meters
    % may be not viable to do with the geoPose3K dataset and would also lead to
    % having the user define an FOV/aspect ratio in their design which could be
    % more complex than it should be. The overal proof of concept for GauGAN3D
    % can be made without this conversion.
    
    testDist = round(dist);
    for i = 1:length(testDist(:,1))
        for j = 1:length(testDist(1,:))
            if testDist(i,j) == -1
                testDist(i,j) = NaN;
            end
        end
    end
    
    %TEST: Have x and y as pixel units for now instead of in meters.
    % scene = zeros(length(testDist(:,1)), length(testDist(1,:)), ...
    %     (max(max(testDist)) - min(min(testDist)) + 1), 'uint16');
    
    minDist = min(min(testDist));
    for i = 1:length(testDist(:,1))
        for j = 1:length(testDist(1,:))
            if ~isnan(testDist(i,j))
                testDist(i,j) = testDist(i,j) - minDist + 1;
            end
        end
    end
    
    %Creating the xyz vectors for 3D plotting
    count = 0;
    sceneLen = (max(max(testDist)) - min(min(testDist)) + 1);
    modVal = 32;    %Spacing between points behind provided depth data
    for i = 1:length(testDist(:,1))
        for j = 1:length(testDist(1,:))
            if ~isnan(testDist(i,j))
                check = 0;
                testLen = 0;
                if i == 1 || i == length(testDist(:,1)) || j == 1 || ...
                        j == length(testDist(1,:)) || isnan(testDist(i-1,j))
                    testLen = sceneLen;
                elseif testDist(i-1,j) > testDist(i,j)
                    testLen = testDist(i-1,j);
                end
                for k = testDist(i,j):testLen
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
    c = zeros(count, 3, 'single');
    count2 = 0;
    for i = 1:length(testDist(:,1))
        for j = 1:length(testDist(1,:))
            if ~isnan(testDist(i,j))
                check = 0;
                testLen = 0;
                if i == 1 || i == length(testDist(:,1)) || j == 1 || ...
                        j == length(testDist(1,:)) || isnan(testDist(i-1,j))
                    testLen = sceneLen;
                elseif testDist(i-1,j) > testDist(i,j)
                    testLen = testDist(i-1,j);
                end
                for k = testDist(i,j):testLen
                    if mod(check, modVal) == 0 || k == testLen
                        count2 = count2 + 1;
                        x(count2) = j;
                        y(count2) = i;
                        z(count2) = k;
                        c(count2,1) = semantic(i,j,1);
                        c(count2,2) = semantic(i,j,2);
                        c(count2,3) = semantic(i,j,3);
                    end
                    check = check + 1;
                end
            end
        end
    end
    
    %Writing xyz vectors and c colour vector to hard drive
    writematrix(x, "/media/anaru/Seagate Expansion Drive/geoPose3K_cyl/" ...
        + folder{f} + "/cyl/x_32.csv");
    writematrix(y, "/media/anaru/Seagate Expansion Drive/geoPose3K_cyl/" ...
        + folder{f} + "/cyl/y_32.csv");
    writematrix(z, "/media/anaru/Seagate Expansion Drive/geoPose3K_cyl/" ...
        + folder{f} + "/cyl/z_32.csv");
    writematrix(c, "/media/anaru/Seagate Expansion Drive/geoPose3K_cyl/" ...
        + folder{f} + "/cyl/c_32.csv");
% end

%To visualise (make modVal/'VALUE' 'VALUE smaller for more edge (black))
% scatter3(x,z,-y,modVal/100,'LineWidth',0.1,'MarkerEdgeColor','k',...
%     'MarkerFaceColor','b')
%To visualise using the semantic image colours
% scatter3(x,z,-y,36,c/255)
% set(gca, 'Color', 'k')