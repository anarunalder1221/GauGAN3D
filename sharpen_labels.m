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

for f = 1:length(folder)
    semantic = imread("~/MATLAB/geoPose3K_cyl/" + folder{f} + ...
        "/cyl/labels_crop.png");
    
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
    
    imwrite(semantic, "/media/anaru/Seagate Expansion Drive/geoPose3K_minimal/" ...
        + folder{f} + "/labels_sharp.png")
end