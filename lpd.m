function [t, y] = lpd(x, pfilt, nlev)
% LPD   Multi-level Laplacian pyramid decomposition
%
%	y = lpdecn(x, pfilt, nlev)
%
% Input:
%   x:      input signal (of any dimension)
%   pfilt:  pyramid filter name (see PFILTERS)
%   nlev:   number of decomposition level
%
% Output:
%   y:      output in a cell vector from coarse to fine layers
%
% See also: LPR

% Get the pyramidal filters from the filter name
[h, g] = pfilters(pfilt);

% Decide extension mode
switch pfilt
    case {'9-7', '9/7', '5-3', '5/3', 'Burt', 'haar'}
        extmod = 'sym';
        
    otherwise
        extmod = 'per';
        
end

t = cell(1, nlev);

for n = 1:nlev-1
    [x, t{nlev-n+1}] = lpdec1(x, h, g, extmod);
end

t{1} = x;

% MEAN
for n = 1:nlev
    %y(1,n) = (sum(sum(t{n})))/(size(t{n},1)^2);
    y(1,n) = mean(t{n}(:));
end

% Variance
for n = 1:nlev
    %y(2,n) = (sum(sum((t{n}-y(1,n)).^2)))/(size(t{n},1)^2);
    y(2,n) = var(t{n}(:));
end
%sigma = y(2,:).^(1/2);

% Skewness and Kurtosis
for n = 1:nlev
    %y(3,n) = (sum(sum(((t{n}-y(1,n))/sigma(:, n)).^3)))/(size(t{n},1)^2);
    %y(4,n) = (sum(sum(((t{n}-y(1,n))/sigma(:, n)).^4)))/(size(t{n},1)^2);
    y(3,n) = skewness(t{n}(:));
    y(4,n) = kurtosis(t{n}(:));
end

