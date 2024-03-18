clear; close all;

num_layer = 5;
Texture_Num = 59;

Ii = cell(Texture_Num, 100);
feature_vectors = cell(Texture_Num, 100);
classification = cell(Texture_Num, 100);
Ti = cell(Texture_Num, 1);
Texture_Library = cell(Texture_Num, 1);
fname = "Burt";

%% Initialization of Extreme Value Normalization values 
max_features = ones(4, num_layer)*-100;
min_features = ones(4, num_layer).*100;


%% Image Feature Vectors
for i=1:Texture_Num
    N = num2str(i);
    Ti{i} = imread(['D', N, '.bmp']);
    Ti{i} = double(Ti{i})/256;
    [t, y] = lpd(Ti{i}, fname, num_layer); % harr db1 db2 coif1 coif2
    Texture_Library{i} = y;
end

%% Minimum and Maximum Values for Extreme Value Normalization
for i = 1:Texture_Num
    for j = 1:4
        for k = 1:num_layer
            if Texture_Library{i}(j, k) > max_features(j, k)
                max_features(j, k) = Texture_Library{i}(j, k);
            end
            if Texture_Library{i}(j, k) < min_features(j, k)
                min_features(j, k) = Texture_Library{i}(j, k);
         
            end
        end
    end
end

%% Extreme Value Normalization
for i = 1:Texture_Num
    for j = 1:4
        for k = 1:num_layer
            Texture_Library{i}(j,k) = (Texture_Library{i}(j,k) - min_features(j,k)) / (max_features(j,k) - min_features(j,k));
        end
    end
end

%% Block Image Slicing
for i=1:Texture_Num
    N = num2str(i);
    I = imread(['D', N, '.bmp']);
    I = double(I)/256;
    for j = 1:10
        for k = 1:10
            Ii{i, ((j-1)*10+k)} = I(64*(j-1)+1:64*j, 64*(k-1)+1:64*k);
        end
    end
end

%% Block Feature Vectors
for i = 1:Texture_Num
    for j = 1:100
        [t, y] = lpd(Ii{i, j}, fname, num_layer);
        for k = 1:4
            for l = 1:num_layer
                y(k,l) = (y(k,l) - min_features(k,l)) / (max_features(k,l) - min_features(k,l));
            end
        end
        feature_vectors{i, j} = y;
    end
end

%% Texture Classification
for i = 1:Texture_Num
    for j = 1:100
        classed_val = 1000;
        classed_num = 1;
        for k = 1:Texture_Num
            temp = Texture_Library{k} - feature_vectors{i, j};
            sum = temp(1,1)^2 + temp(2,2)^2 + temp(2,3)^2 + temp(2,4)^2 + temp(2,5)^2;
            sum = sqrt(sum);
            if sum < classed_val
                    classed_num = k;
                    classed_val = sum;
            end
        end
        classification{i,j} = classed_num;
    end
end

%% PCC
num_correct = 0;
for i = 1:Texture_Num
    for j = 1:100
        if classification{i,j} == i
            num_correct = num_correct + 1;
        end
    end
end
PCC = num_correct / 5900 * 100;



