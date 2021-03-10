function I=any_image_to_grayscale_func(ImageFilename)

% get the image data and the colormap (if exists)  
[X,Map]=imread(ImageFilename);

% get the image dimensions
ImSize=size(X);

if length(ImSize)>2 % if it is a truecolor image...
  I=rgb2gray(X); ... then convert it to grayscale

elseif isempty(Map) % if there is no associated colormap...
  I=X; % ... then the image is already grayscale

else % if there is an associate colormap...
  I=ind2gray(X,Map); % ... convert to grayscale using the colormap
  if max(max(I))<=1 % if the graylevel values are between 0..1 
    I=uint8(I*255); % ... then convert them to 0..255
  end
end

% the function returns the array I
