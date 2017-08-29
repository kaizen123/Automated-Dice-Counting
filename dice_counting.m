
function count_dice(input_image)
count1 = 0; count2 = 0; count3 = 0; count4 = 0; count5 = 0; count6 = 0; unknown = 0;
 
%Reading the image and converting it to double.
input_image=im2double(imread(input_image));

%To remove the red noise from the image we take the red channel.
red_img=input_image(:,:,1);

%Apply median filter to remove noise from the image.
red_MF = medfilt2(red_img, [5 5]);

%Finding the right threshold to apply thresholding which uses Otsu's model.
thresh=graythresh(red_MF); 

%Convert the image to a binary image.
im_bw=imbinarize(red_MF,thresh);
imagesc(im_bw);

%Using the structure element
structure_ele=strel('disk',5);

% Using erosion to remove noise from the image.
im_erode=imerode(im_bw,structure_ele);
imagesc(im_erode);

%Using open to remove noise from the image.
im_open=imopen(im_erode,structure_ele);
imagesc(im_open);
 
%Using the function to identify different objects in the image.
[separations,n_labels]=bwlabel(im_open);

separations = medfilt2(separations, [5 5]);


%Running the for loop to identify different dice.
for ii=1:n_labels

    %To identify the various objects segmented by bwlabel.
    region=separations==ii;
    
    %Identify the area of the white region
    area = regionprops(region,'Area');

    %Case to ignore redundant data which the algorithm falsely detects as
    %a dice
    if area.Area < 20000 || area.Area > 90000
        unknown = unknown+1;
    else
    
        %Displaying the image.
        imagesc(region);

        colormap(gray);
        axis image 
        drawnow;

        %To measure properties of the image.
        polyXY=regionprops(region,'ConvexHull');

        %Cordinates for the plotting the Convex hull.
        xs=polyXY.ConvexHull(:,1);

        %Cordinates for the plotting the Convex hull.
        ys=polyXY.ConvexHull(:,2);
        
        %Taking complement of the image to count number on the dice.
        inv_img = imcomplement(region);

        %Using the structure element
        structure_ele=strel('disk',20);

        % Using erosion to remove noise from the image.
        inv_img=imerode(inv_img,structure_ele);
        imagesc(inv_img);
        hold on;

        %Plotting the convex hull around the dice
        plot(xs,ys,'m-','LineWidth',2);


        %Using bwlabel again to segregate the objects on the inverted image.
        [inv_img,no_on_dice]=bwlabel(inv_img);
        no_on_dice = no_on_dice-1;

        %Count the number of 1s, 2s, 3s, 4s, 5s and 6s in the dice.
        switch no_on_dice
            case 1
                count1 = count1+1;
            case 2
                count2 = count2+1;
            case 3
                count3 = count3+1;
            case 4
                count4 = count4+1;
            case 5
                count5 = count5+1;
            case 6
                count6 = count6+1;
            otherwise
                unknown = unknown+1;
        end

        hold off;
        pause(2);
    end
end

% To identify dice from other unknown objects.
if unknown > 0
    n_labels = n_labels - unknown;
end

%Output the values
X = [' Image Filename: ',input_image];
disp(X)
X = [' Number of Dice: ',num2str(n_labels)];
disp(X)
X = [' Number of 1s: ',num2str(count1)];
disp(X)
X = [' Number of 2s: ',num2str(count2)];
disp(X)
X = [' Number of 3s: ',num2str(count3)];
disp(X)
X = [' Number of 4s: ',num2str(count4)];
disp(X)
X = [' Number of 5s: ',num2str(count5)];
disp(X)
X = [' Number of 6s: ',num2str(count6)];
disp(X)
X = [' Number of Unknown: ',num2str(unknown)];
disp(X)

imagesc(im_erode);
colormap('gray');
end