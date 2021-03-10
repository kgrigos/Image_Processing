clc;
clear;
close all;
more off;

% --- INIT
if exist('OCTAVE_VERSION', 'builtin')>0
    % If in OCTAVE load the image package
    warning off;
    pkg load image;
    warning on;
end

% ------------------------------
% PART A
% ------------------------------

% --- Step A1
% read the original RGB image 
Filename='Troizina 1827.jpg';
I=imread(Filename);

% show it (Eikona 1)
figure;
image(I);
axis image off;

% --- Step A2
% convert the image to grayscale
A=any_image_to_grayscale_func('Troizina 1827.jpg');

% --- Step B5 
% apply gamma correction (a value of 1.0 doesn't change the image)
GammaValue=1.0; 
A=imadjust(A,[],[],GammaValue); 

% show the grayscale image (Eikona 2)
figure;
image(A);
colormap(gray(256));
axis image off;
title('Grayscale image');

% --- Step A3
% convert the grayscale image to black-and-white 
Threshold= graythresh(A);
BW = ~im2bw(A,Threshold);

% show the black-and-white image (Eikona 3)
figure;
image(~BW);
colormap(gray(2));
axis image;
set(gca,'xtick',[],'ytick',[]);
title('Binary image');

% --- Step A4

% make morphological operations to clean the image ...

% get statistical information from connected components ...

% find connected components that are statistical outliers
% (too small or too big)
% and remove them (make their pixel value = 0) ...
BW2=bwmorph(BW,'clean',inf);%Καθαρισμός διάσπαρτων pixel 
BW2=bwmorph(BW2,'dilate',3);%3 φορές διαστολή
BW2=imclearborder(BW2);%Καθαρισμός θορύβου περιγράμματος
BW2=bwmorph(BW2,'erode',3);%3 φορές συστολή
BW2=bitand(BW2,BW); %Λογικό και,ένωση των εικόνων για την επαναφορά των κειμένων που έχουν αλλοιωθεί
BW2=bwmorph(BW2,'clean',inf);
figure;
image(~BW2);
colormap(gray(2));
axis image off;

% show cleaned image (Eikona 4) ...

% --- Step A5

% make morphological operations for word segmentation ...

% find the connected components (using bwlabel) ...

% show word segmentation (Eikona 5) ...
BW3=bwmorph(BW2,'erode');
BW3=bwmorph(BW3,'clean');
se=strel('rectangle',[2 22]);%Επιλογή μορφοποίησης με βάση το ορθογώνιο και διαστάσεις 2x22
BW3=imdilate(BW3,se);%Διαστολή με βάση το se
[L1,m1]=bwlabel(BW3,4);%4-συνδεσιμότητα και m1 για μετρητή λέξεων 
[L2,m2]=bwlabel(BW3,8);%8-συνδεσιμότητα μαι m2 για μετρητή λέξεων 
rgb=label2rgb(L1,'lines');
rgb2=label2rgb(L2,'lines');
figure;
imshowpair(rgb,rgb2,'montage');
axis image ;

% --- Step A6

% show the original image ...

% and show the final bounding boxes (Eikona 6) ...
figure;
imshowpair(I,I,'montage');
axis image ;
matrix=zeros(m2,4);%Δημιουργία πίνακα για το A7
for i=1:m2
[r,c]=find(L2==i);
xmin=min(c);
xmax=max(c);
ymin=min(r);
ymax=max(r);

line([xmin-0.5 xmax+0.5 xmax+0.5 xmin-0.5 xmin-0.5],[ymin-7 ymin-7 ymax ymax ymin-7],'color',rand(1,3),'linewidth',3);% Αλλαγή ymin σε -7 από +5

 for y=1:4%γραμμές και στήλες του πίνακα
     if y==1
         matrix(i,y)=xmin;
     elseif y==2
         matrix(i,y)=ymin;
     elseif y==3
         matrix(i,y)=xmax;
     else
         matrix(i,y)=ymax;
     end
 end
end



% --- Step A7
% save the bounding boxes in a text file results.txt ...
writematrix(matrix,'results.txt','Delimiter','\t');
% ------------------------------
% PART B
% ------------------------------

% --- Step B1
% load the ground truth
GT=dlmread('Troizina 1827_ground_truth.txt');
% load our results
R=readmatrix('results.txt');
matrixIOU=zeros(m2,87);%Αρχικοποίηση πίνακα για τις τιμές ΙΟU
for i=1:m2
    for x=1:87
winter=min(R(i,3),GT(x,3))-max(R(i,1),GT(x,1));%Aφαιρώ το min του Xmax και gxam απλο τo max τoυ xmin και του gxm(επιλογή τομής μεταξύ των κουτιών στον άξονα x)
hinter=min(R(i,4),GT(x,4))-max(R(i,2),GT(x,2));%Αφαιρώ το min του Xmax και gxam από το max του xmin και του gxm(επιλογηή τομής μεταξύ των κουτιών στον άξονα y)
if winter<=0%αν δεν συνδέονται στον άξονα x τότε 0
    IOU=0;
elseif hinter<=0%αν δεν συνδέονται στον άξονα y τότε 0
    IOU=0;
else
    I=winter*hinter;%κουτί της τομής
    U=(R(i,3)-R(i,1))*(R(i,4)-R(i,2))+(GT(x,3)-GT(x,1))*(GT(x,4)-GT(x,2))-I;%enosi twn 2 koutiwn
    IOU=I/U;
end
if matrixIOU(i,x)<IOU %επιλογή του καλύτερου IOU όταν η εντοπισμένη λέξη υπαρκαλύπτει 2 πραγματικές
matrixIOU(i,x)=IOU;
end
    end
end
% --- Step B2
% calculate IOU for all the results ...
IOUth=0.3;
matrixIOUth=zeros(m2,87);
TP=0;
for i=1:m2
    for x=1:87
        if matrixIOU(i,x)>IOUth
            matrixIOUth=1;
           TP=TP+1;
        end
    end
end
FP=m2-TP;
FN=87-TP;
Recall=TP/(TP+FN);
Precision=TP/(TP+FP);
F_Measure=2*(Recall*Precision)/(Recall+Precision);
% --- Step B3
%IOUThreshold=0.5; % or 0.3 or 0.7

% calculate the Score for this pair of (GammaValue,IOUThreshold) ...












