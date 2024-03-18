% gabor_texture_analysis.m

clear; close all;

Ns=4; No=4;			                        % Number of scales and orientations
Texture_Num = 59;                           % Number of Texture Images

Ti = cell(Texture_Num, 1);                  % Texture Image Cell
Ii = cell(Texture_Num, 100);                % Block Texture Image Cell

feature_bank = cell(Texture_Num,1);         % Texture Image Feature Vectors
block_bank = cell(Texture_Num, 100);        % Block Image Feature Vectors
classification = cell(Texture_Num, 100);    % Classification Cell

%% Texture Feature Extraction
for i = 1:Texture_Num
    N = num2str(i);
    Ti{i} = double(imread(['D', N, '.bmp']));
    Texture_Conv = gaborconvolve(Ti{i},Ns,No,3,2,0.65,1.5);
    for j = 1:Ns
        for k = 1:No
            Texture_Conv{j,k} = abs(Texture_Conv{j,k});

            mn = mean(Texture_Conv{j,k}(:));            % Mean
            vr = var(Texture_Conv{j,k}(:));             % Variance
            sk = skewness(Texture_Conv{j,k}(:));        % Skewness
            kt = kurtosis(Texture_Conv{j,k}(:));        % Kurtosis

            feature_bank{i}{j,k} = [mn; vr; sk; kt];
        end
    end
end

%% Minimum and Maximum Values for Extreme Value Normalization
max_vector = feature_bank{1}{1,1};
min_vector = feature_bank{1}{1,1};
for i = 1:Texture_Num
    for j = 1:Ns
        for k = 1:No
            for l = 1:4
                if max_vector(l) < feature_bank{i}{j,k}(l)
                    max_vector(l) = feature_bank{i}{j,k}(l);
                end
                if min_vector(l) > feature_bank{i}{j,k}(l)
                    min_vector(l) = feature_bank{i}{j,k}(l);
                end
            end
        end
    end
end

%% Extreme Value Normalization
for i = 1:Texture_Num
    for j = 1:Ns
        for k = 1:No
            for l = 1:4
                feature_bank{i}{j,k}(l) = (feature_bank{i}{j,k}(l) - min_vector(l)) / (max_vector(l) - min_vector(l));
            end
        end
    end
end

%% Image Slicing
for i=1:Texture_Num
    N = num2str(i);
    I = double(imread(['D', N, '.bmp']));
    for j = 1:10
        for k = 1:10
            Ii{i, ((j-1)*10+k)} = I(64*(j-1)+1:64*j, 64*(k-1)+1:64*k);
        end
    end
end

%% Block Feature Vectors
for i = 1:Texture_Num
    for j = 1:100
        Block_Conv = gaborconvolve(Ii{i,j},Ns,No,3,2,0.65,1.5);
        for k = 1:Ns
            for l = 1:No
                Block_Conv{k,l} = abs(Block_Conv{k,l});

                mn = mean(Block_Conv{k,l}(:));          % Block Mean
                vr = var(Block_Conv{k,l}(:));           % Block Variance
                sk = skewness(Block_Conv{k,l}(:));      % Block Skewness
                kt = kurtosis(Block_Conv{k,l}(:));      % Block Kurtosis
                block_bank{i,j}{k,l} = [mn vr sk kt];

                % Block Feature Vector Normalization
                for m = 1:4
                    block_bank{i,j}{k,l}(m) = (block_bank{i,j}{k,l}(m) - min_vector(m)) / (max_vector(m) - min_vector(m));
                end
            end
        end
    end
end

%% Texture Classification
for i = 1:Texture_Num
    for j = 1:100
        classed_val = 10000000;
        classed_num = 1;
        for m = 1:Texture_Num
            class_arg = 0;
            for k = 1:Ns
                for l = 1:No
                    temp = feature_bank{m}{k,l}(1) - block_bank{i,j}{k,l}(1);
                    class_arg = class_arg + sum(temp^2);           
                end
            end
            class_arg = sqrt(class_arg);
            if class_arg < classed_val
                class_num = m;
                classed_val = class_arg;
            end   
        end  
        classification{i,j} = class_num;
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
PCC = num_correct / (Texture_Num * 100) * 100;











