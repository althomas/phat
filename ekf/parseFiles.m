%For example, run: runConversion([24;4;24], [0;1;0], [24;24;4], [0;0;1])
%The code will spit out a 3-d point that corresponds to the beacon location
%Direction vector for x: [[cos(theta_y)*cos(theta_z); sin(theta_y)*cos(theta_z);
%sin(theta_z)]

%Horizontal distance: ~0.64/1 ratio of horizontal cross to distance.
        %Theta: 18.66 degrees in either direction.
        %Convert Pixel to degrees: (y - 320)*(18.66/320)
        
%Vertical distance: ~0.6/1 ratio of vertical line to distance
        %Theta: 17.5 degrees in either direction
        %Convert pixel to degrees: (z - 240)*(17.46/240)

%Takes 3 pairs of coordinates. Converts to 3d parametrized lines, then
%runs runConversion to find the position of the beacon. If one camera does
%not have data, include as (0, 0) for the respective input
%a1, a2 - from camera on x axis (points in y)
%b1, b2 - from camera on y axis (points in x)
%c1, c2 - from camera on z axis

function [returnVal] = parseFiles()

%The csv outputs from opencv
%c1 = csvread('~/Desktop/beaconLocationData1.txt');
%c2 = csvread('~/Desktop/beaconLocationData2.txt');
%c3 = csvread('~/Desktop/beaconLocationData0.txt');
c1 = csvread('~/Desktop/SD Sample Data/IMUs Clench/beaconLocationData1.txt');
c2 = csvread('~/Desktop/SD Sample Data/IMUs Clench/beaconLocationData2.txt');
c3 = csvread('~/Desktop/SD Sample Data/IMUs Clench/beaconLocationData0.txt');

%Account for mis-alignment (HARD-CODED)
for i = 1:size(c2,1)
    if(c1(i,2) ~= 0) c1(i,2) = c1(i,2) - 30; end;
    if(c1(i,4) ~= 0) c1(i,4) = c1(i,4) - 30; end;
    if(c1(i,6) ~= 0) c1(i,6) = c1(i,6) - 30; end;
    %if(c1(i,8) ~= 0) c1(i,8) = c1(i,8) - 30; end;
    if(c2(i,3) ~= 0) c2(i,3) = c2(i,3) - 20; end;
    if(c2(i,5) ~= 0) c2(i,5) = c2(i,5) - 20; end;
    if(c2(i,7) ~= 0) c2(i,7) = c2(i,7) - 20; end;
    %if(c2(i,9) ~= 0) c2(i,9) = c2(i,9) - 20; end;
    if(c3(i,3) ~= 0) c3(i,3) = c3(i,3) - 5; end;
    if(c3(i,5) ~= 0) c3(i,5) = c3(i,5) - 5; end;
    if(c3(i,7) ~= 0) c3(i,7) = c3(i,7) - 5; end;
    %if(c3(i,9) ~= 0) c3(i,9) = c3(i,9) - 5; end;
end

counter2 = 1;
counter3 = 1;
tolerance = 0.01;
includeThisOne = [0, 0, 0, 0];
finalList = [];     %Timestamp, color, x1, y1, x2, y2, x3, y3
                    %Color: 1 = red, 2 = blue, 3 = white, 4 = green
                        
%Find the 4th LED to sync up with IMU data, reset timestamps to match IMU's
startTime = 0;
startStamp = 1;
for i = size(c1,1):-1:1
    if (c1(i,8)~=0 || c1(i,9)~=0)
        startTime = c1(i,1);
        startStamp = i + 1;
    end
end
for i = size(c2,1):-1:1
    if (c2(i,8)~=0 || c2(i,9)~=0)
        if(i + 1> startStamp)
            startTime = c2(i,1);
            startStamp = i + 1;
        end
    end
end
for i = size(c3,1):-1:1
    if (c3(i,8)~=0 || c3(i,9)~=0)
        if(i + 1> startStamp)
            startTime = c3(i,1);
            startStamp = i + 1;
        end
    end
end

%Edit timestamps so that the startTime-th frame is at time 0
for i = 1:max([size(c1,1),size(c2,1),size(c3,1)])
    if(i <= size(c1,1))
        c1(i,1) = c1(i,1) - startTime;
    end
    if(i <= size(c2,1))
        c2(i,1) = c2(i,1) - startTime;
    end
    if(i <= size(c3,1))
        c3(i,1) = c3(i,1) - startTime;
    end
end

%Do the real stuff
for i = startStamp:size(c1,1)
    includeThisOne = [0, 0, 0 ,0]; %reset flag to know if this timestamp was included
    %Check file 2 - first make sure that counter2 is in range
    if (counter2 <= size(c2,1))
        while (c2(counter2) <= c1(i) + tolerance)
            if (abs(c1(i) - c2(counter2)) <= tolerance)
                %Check Red
                if(((c1(i, 2) ~= 0) || (c1(i, 3) ~=0)) && ((c2(counter2, 2) ~= 0) || (c2(counter2, 3) ~= 0)))
                    finalList = [finalList; c1(i), 1, c1(i, 2), c1(i, 3), c2(counter2, 2), c2(counter2, 3), 0, 0];
                    includeThisOne(1) = 1;
                end

                %Check Blue
                if(((c1(i, 4) ~= 0) || (c1(i, 5) ~=0)) && ((c2(counter2, 4) ~= 0) || (c2(counter2, 5) ~= 0)))
                    finalList = [finalList; c1(i), 2, c1(i, 4), c1(i, 5), c2(counter2, 4), c2(counter2, 5), 0, 0];
                    includeThisOne(2) = 1;
                end

                %Check White
                if(((c1(i, 6) ~= 0) || (c1(i, 7) ~=0)) && ((c2(counter2, 6) ~= 0) || (c2(counter2, 7) ~= 0)))
                    finalList = [finalList; c1(i), 3, c1(i, 6), c1(i, 7), c2(counter2, 6), c2(counter2, 7), 0, 0];
                    includeThisOne(3) = 1;
                end

                %Check Green
                %if(((c1(i, 8) ~= 0) || (c1(i, 9) ~=0)) && ((c2(counter2, 8) ~= 0) || (c2(counter2, 9) ~= 0)))
                %    finalList = [finalList; c1(i), 4, c1(i, 8), c1(i, 9), c2(counter2, 8), c2(counter2, 9), 0, 0];
                %    includeThisOne(4) = 1;
                %end
            end
            counter2 = counter2 + 1;
            if (counter2 >= size(c2,1)) break; end;
        end
    end
    
    %Check file 3
    if (counter3 <= size(c3,1))
        while (c3(counter3) <= c1(i) + tolerance)
            if (abs(c1(i) - c3(counter3)) <= tolerance)
                %Red
                if(((c1(i, 2) ~= 0) || (c1(i, 3) ~=0)) && ((c3(counter3, 2) ~= 0) || (c3(counter3, 3) ~= 0)))
                    if (includeThisOne(1) == 1)
                        %Add to existing row
                        for j = 1:size(finalList,1)
                            if ((finalList(j) == c1(i)) && (finalList(j, 2) == 1))
                                finalList(j, 7) = c3(counter3, 2);
                                finalList(j, 8) = c3(counter3, 3);
                            end
                        end
                    else
                        %Create new row 
                        finalList = [finalList; c1(i), 1, c1(i, 2), c1(i, 3), 0, 0, c3(counter3, 2), c3(counter3,3)];
                    end
                end

                %Blue
                if(((c1(i, 4) ~= 0) || (c1(i, 5) ~=0)) && ((c3(counter3, 4) ~= 0) || (c3(counter3, 5) ~= 0)))
                    if (includeThisOne(2) == 1)
                        %Add to existing row
                        for j = 1:size(finalList,1)
                            if ((finalList(j) == c1(i)) && (finalList(j, 2) == 2))
                                finalList(j, 7) = c3(counter3, 4);
                                finalList(j, 8) = c3(counter3, 5);
                            end
                        end
                    else
                        finalList = [finalList; c1(i), 2, c1(i, 4), c1(i, 5), 0, 0, c3(counter3, 4), c3(counter3,5)];
                    end
                end

                %White
                if(((c1(i, 6) ~= 0) || (c1(i, 7) ~=0)) && ((c3(counter3, 6) ~= 0) || (c3(counter3, 7) ~= 0)))
                    if (includeThisOne(3) == 1)
                        for j = 1:size(finalList,1)
                            if ((finalList(j) == c1(i)) && (finalList(j, 2) == 3))
                                finalList(j, 7) = c3(counter3, 6);
                                finalList(j, 8) = c3(counter3, 7);
                            end
                        end
                    else
                        finalList = [finalList; c1(i), 3, c1(i, 6), c1(i, 7), 0, 0, c3(counter3, 6), c3(counter3,7)];
                    end
                end

                %Green
                %if(((c1(i, 8) ~= 0) || (c1(i, 9) ~=0)) && ((c3(counter3, 8) ~= 0) || (c3(counter3, 9) ~= 0)))
                %    if (includeThisOne(4) == 1)
                %        for j = 1:size(finalList,1)
                %            if ((finalList(j) == c1(i)) && (finalList(j, 2) == 4))
                %                finalList(j, 7) = c3(counter3, 8);
                %                finalList(j, 8) = c3(counter3, 9);
                %            end
                %        end
                %    else
                %        %Create new row
                %        finalList = [finalList; c1(i), 4, c1(i, 8), c1(i, 9), 0, 0, c3(counter3, 8), c3(counter3,9)];
                %    end
                %end
            end
            counter3 = counter3 + 1;
            if (counter3 > size(c3,1)) break; end;
        end
    end
end


%Loop through c2 rows, compare with c3 (similar to above except with only 2 files)
%Before adding, make sure element not already included
counter3 = 1; %reset
for i = 1:size(c2,1)
    if(counter3 <= size(c3,1))
        while (c3(counter3) <= c2(i) + tolerance)
            if (abs(c2(i) - c3(counter3)) <= tolerance)
                if (notAlreadyThere(c2(i), finalList, tolerance))
                    %Check Red
                    if(((c2(i, 2) ~= 0) || (c2(i, 3) ~=0)) && ((c3(counter3, 2) ~= 0) || (c3(counter3, 3) ~= 0)))
                        finalList = [finalList; c2(i), 1, 0, 0 c2(i, 2), c2(i, 3), c3(counter3, 2), c3(counter3, 3)];
                    end

                    %Blue
                    if(((c2(i, 4) ~= 0) || (c2(i, 5) ~=0)) && ((c3(counter3, 4) ~= 0) || (c3(counter3, 5) ~= 0)))
                        finalList = [finalList; c2(i), 2, 0, 0 c2(i, 4), c2(i, 5), c3(counter3, 4), c3(counter3, 5)];
                    end

                    %White
                    if(((c2(i, 6) ~= 0) || (c2(i, 7) ~=0)) && ((c3(counter3, 6) ~= 0) || (c3(counter3, 7) ~= 0)))
                        finalList = [finalList; c2(i), 3, 0, 0 c2(i, 6), c2(i, 7), c3(counter3, 6), c3(counter3, 7)];
                    end

                    %Green
                    %if(((c2(i, 8) ~= 0) || (c2(i, 9) ~=0)) && ((c3(counter3, 8) ~= 0) || (c3(counter3, 9) ~= 0)))
                    %    finalList = [finalList; c2(i), 4, 0, 0 c2(i, 8), c2(i, 9), c3(counter3, 8), c3(counter3, 9)];
                    %end    
                end
            end
            counter3 = counter3 + 1;
            if (counter3 > size(c3,1)) break; end;
        end
    end
end

%Since rows added when looping through c2 are out of order, need to reorder finalList
finalList = sortrows(finalList);

%for each element in finalList, runConversion to get xyz coordinates
final = [];
for i = 1:size(finalList,1)
    temp = runConversion(finalList(i, 3), finalList(i, 4), finalList(i, 5), finalList(i, 6), finalList(i,7), finalList(i, 8));
    final = [final; finalList(i, 1), finalList(i, 2), temp(1), temp(2), temp(3)];
end

%To add more parsing (conversion of LED colors to actual finger joints add
%method here and set returnVal to answer;
returnVal = [];
i = 1;
while i < size(final,1)
     %New row
     returnVal = [returnVal; final(i,1), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
     if (final(i,2) == 1)
         %Red
         returnVal(size(returnVal,1),6) = final(i,3);
         returnVal(size(returnVal,1),7) = final(i,4);
         returnVal(size(returnVal,1),8) = final(i,5);
     elseif (final(i,2) == 2)
         %Blue
         returnVal(size(returnVal,1),3) = final(i,3);
         returnVal(size(returnVal,1),4) = final(i,4);
         returnVal(size(returnVal,1),5) = final(i,5);
     elseif (final(i,2) == 3)
         %White
         returnVal(size(returnVal,1),9) = final(i,3);
         returnVal(size(returnVal,1),10) = final(i,4);
         returnVal(size(returnVal,1),11) = final(i,5);
     end
     j = 1;
     while (j <= 3)
         if((i+j <= size(final,1)) && (abs(final(i+j,1) - final(i,1)) <= tolerance))
            %Add next row to same row of returnVal
            
            if(abs(final(i,1) - 8.8637) < 0.01)
                i
                j
                final(i+j,2)
            end
            i = i+1;
            if (final(i+j-1,2) == 1)
                %Red               
                returnVal(size(returnVal,1),6) = final(i,3);
                returnVal(size(returnVal,1),7) = final(1,4);
                returnVal(size(returnVal,1),8) = final(i,5);
            elseif (final(i+j-1,2) == 2)
                %Blue
                returnVal(size(returnVal,1),3) = final(i,3);
                returnVal(size(returnVal,1),4) = final(i,4);
                returnVal(size(returnVal,1),5) = final(i,5);
            elseif (final(i+j-1,2) == 3)
                %White
                returnVal(size(returnVal,1),9) = final(i,3);
                returnVal(size(returnVal,1),10) = final(i,4);
                returnVal(size(returnVal,1),11) = final(i,5);
            end
            %increase i
            %i = i+1;
            j = 0;
         end
        j = j+1;
     end
     %Go to next line
     i = i+1;
end

%Convert to coordinate system that matches with IMU data
for i = 1:size(returnVal,1)
    if(returnVal(i,3) ~= 0) returnVal(i,3) = 48 - returnVal(i,3); end
    if(returnVal(i,4) ~= 0) returnVal(i,4) = 48 - returnVal(i,4); end
    if(returnVal(i,5) ~= 0) returnVal(i,5) = 48 - returnVal(i,5); end
    if(returnVal(i,6) ~= 0) returnVal(i,6) = 48 - returnVal(i,6); end
    if(returnVal(i,7) ~= 0) returnVal(i,7) = 48 - returnVal(i,7); end
    if(returnVal(i,8) ~= 0) returnVal(i,8) = 48 - returnVal(i,8); end
    if(returnVal(i,9) ~= 0) returnVal(i,9) = 48 - returnVal(i,9); end
    if(returnVal(i,10) ~= 0) returnVal(i,10) = 48 - returnVal(i,10); end
    if(returnVal(i,11) ~= 0) returnVal(i,11) = 48 - returnVal(i,11); end
end

%Determine phase flag
for i = 1:size(returnVal,1)
    if(i ~= 1)
        if(returnVal(i,1) - returnVal(i-1,1) < 0.035 && returnVal(i,1) - returnVal(i-1,1) >= 0.03)
            returnVal(i,2) = 1 - returnVal(i-1,2);
        elseif(returnVal(i,1) - returnVal(i-1,1) < 3*0.035 && returnVal(i,1) - returnVal(i-1,1) >= 3*0.03)
            returnVal(i,2) = 1 - returnVal(i-1,2);
        elseif(returnVal(i,1) - returnVal(i-1,1) < 5*0.035 && returnVal(i,1) - returnVal(i-1,1) >= 5*0.03)
            returnVal(i,2) = 1 - returnVal(i-1,2);
        else
            %Even number of frames. Leave same flag
            returnVal(i,2) = returnVal(i-1,2);
        end
    end
end

%Error checking for flags. Sanity check in case synchronization gets messed
%up. On purpose, is hard to trigger - only goes off in extreme cases
for i = 1:size(returnVal,1)
    %Compare with previous different flag
    diffdistBlue = -1;
    diffdistRed = -1;
    diffdistWhite = -1;
    for j = (i-1):-1:1
        if(returnVal(i,2) ~= returnVal(j,2) && returnVal(i,3) ~= 0 && returnVal(j,3) ~= 0)
            diffdistBlue = distance(returnVal(i,3),returnVal(i,4),returnVal(i,5),returnVal(j,3),returnVal(j,4),returnVal(j,5));
            break;
        end;
    end;
    for j = (i-1):-1:1
        if(returnVal(i,2) ~= returnVal(j,2) && returnVal(i,6) ~= 0 && returnVal(j,6) ~= 0)
            diffdistRed = distance(returnVal(i,6),returnVal(i,7),returnVal(i,8),returnVal(j,6),returnVal(j,7),returnVal(j,8));
            break;
        end;
    end;
    for j = (i-1):-1:1
        if(returnVal(i,2) ~= returnVal(j,2) && returnVal(i,9) ~= 0 && returnVal(j,9) ~= 0)
            diffdistWhite = distance(returnVal(i,9),returnVal(i,10),returnVal(i,11),returnVal(j,9),returnVal(j,10),returnVal(j,11));
            break;
        end;
    end;    

    %Compare with previous same flag
    samedistBlue = -1;
    samedistRed = -1;
    samedistWhite = -1;
    for j = (i-1):-1:1
        if(returnVal(i,2) == returnVal(j,2) && returnVal(i,3) ~= 0 && returnVal(j,3) ~= 0)
            samedistBlue = distance(returnVal(i,3),returnVal(i,4),returnVal(i,5),returnVal(j,3),returnVal(j,4),returnVal(j,5));
            break;
        end;
    end;
    for j = (i-1):-1:1
        if(returnVal(i,2) == returnVal(j,2) && returnVal(i,6) ~= 0 && returnVal(j,6) ~= 0)
            samedistRed = distance(returnVal(i,6),returnVal(i,7),returnVal(i,8),returnVal(j,6),returnVal(j,7),returnVal(j,8));
            break;
        end;
    end;
    for j = (i-1):-1:1
        if(returnVal(i,2) == returnVal(j,2) && returnVal(i,9) ~= 0 && returnVal(j,9) ~= 0)
            samedistWhite = distance(returnVal(i,9),returnVal(i,10),returnVal(i,11),returnVal(j,9),returnVal(j,10),returnVal(j,11));
            break;
        end;
    end;
    
    
    %Check condition,if so trigger change
    flipState = 0;
    if(diffdistBlue ~= -1 && samedistBlue ~= -1)
        if(diffdistRed ~= -1 && samedistRed ~= -1)
            if(diffdistWhite ~= -1 && samedistRed ~= -1)
                %all 3 colors
                flipState = test3(diffdistBlue,diffdistRed,diffdistWhite,samedistBlue,samedistRed,samedistWhite);
            else
                %just red and blue
                flipState = test2(diffdistBlue,diffdistRed,samedistBlue,samedistRed);
            end
        elseif(diffdistWhite ~= -1 && samedistWhite ~= -1)
            %Just blue and white
            flipState = test2(diffdistBlue,diffdistWhite,samedistBlue,samedistWhite);
        else
            %Just blue
            flipState = test1(diffdistBlue, samedistBlue);
        end
        
    elseif(diffdistRed ~= -1 && samedistRed ~= -1)
        if(diffdistWhite ~= -1 && samedistWhite ~= -1)
            %Just red and white
            flipState = test2(diffdistRed,diffdistWhite,samedistRed,samedistWhite);
        else
            %Just red
            flipState = test1(diffdistRed, samedistRed);
        end
    elseif(diffdistWhite ~= -1 && samedistWhite ~= -1)
        %Just white
        flipState = test1(diffdistWhite, samedistWhite);
    end
    
    %If condition met, rearrange ALL future ones (just flip value of column 2)
    if (flipState)
        %disp('flipping');
        returnVal(i,1);
        for j = i:size(returnVal,1)
            returnVal(j,2) = 1 - returnVal(j,2);
        end
    end
end
final
%Convert phase 1 files to proper format: Instead of BRW, use WBR
for i = 1:size(returnVal,1)
    if(returnVal(i,2) == 2)
        temp1 = returnVal(i,3);
        temp2 = returnVal(i,4);
        temp3 = returnVal(i,5);
        returnVal(i,3) = returnVal(i,9);
        returnVal(i,4) = returnVal(i,10);
        returnVal(i,5) = returnVal(i,11);
        returnVal(i,9) = returnVal(i,6);
        returnVal(i,10) = returnVal(i,7);
        returnVal(i,11) = returnVal(i,8);
        returnVal(i,6) = temp1;
        returnVal(i,7) = temp2;
        returnVal(i,8) = temp3;
    end
end
%Write to file
dlmwrite('~/Desktop/finalOutput.txt', returnVal, ',');
end

%Test with 1/2/3 LED's, whether to flip the state. 0 if not, 1 if yes
function [flip] = test1(d,s)
    flip = 0;
    if (s > 1 && 2*d < s)
        flip = 1;
        %disp('1');
    end
end

function [flip] = test2(d1, d2, s1, s2)
    flip = 0;
    if ((s1 > .75 && s2 > .75 && d1*2 < s1 && d2*2 < s2) || (s1 > 1.5 && d1*2 < s1+0.25) || (s2 > 1.5 && d2*2 < s2+0.25))
        flip = 1;
        %disp('2');
    end
end

function [flip] = test3(d1, d2, d3, s1, s2, s3)
    flip = 0;
    if ((s1 > .5 && s2 > .5 && s3 > .5 && d1*2 < s1 && d2*2 < s2 && d3*2 < s3) || (test2(d1, d2, s1, s2) == 1 && d3 < s3+0.5) ...
             || (test2(d1, d3, s1, s3) == 1 && d3 < s3+0.5) || (test2(d2, d3, s2, s3) == 1 && d1 < s1 + 0.5) || ...
             (s1 > 2 && 2*d1 < s1 && d2*2 < s2 + 0.25 && d3*2 < s3 + 0.25) || (s2 > 2 && 2*d2 < s2 && d1*2 < s1 + 0.25 && d3*2 < s3 + 0.25) ...
             || (s3 > 2 && 2*d3 < s3 && d1*2 < s2 + 0.25 && d2*2 < s2 + 0.25))
        flip = 1;
        %disp('3');
    end
end

%Calculates the distance between two points
function [dist] = distance(x1, y1, z1, x2, y2, z2)
    dist = sqrt((x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2);
end

%Helper function to check if a timestamp is already included in the file
function [notIncluded] = notAlreadyThere(time1, list1, tolerance)

    notIncluded = true;
    for i = 1:size(list1,1)
        if(abs(time1 - list1(i) <= tolerance))
            notIncluded = false;
            return
        end
    end

end

function [position] = runConversion(h1, v1, h2, v2, h3, v3)

    %original xyz coordinates of the 3 cameras
    p1 = [24; 3.5; 24];
    p2 = [3.5; 24; 24];
    p3 = [24; 24; 3.5];
    
    
    %Measure theta_horiz and theta_vert angles for each of the 3 cameras
    %Note the angles for vertical values are backwards
    x_1 = (h1 - 320)*18.66/320;  %Horizontal
    z_1 = (v1 - 240)*17.46/240;  %Vertical
    y_2 = (320 - h2)*18.66/320;
    z_2 = (v2 - 240)*17.46/240;
    x_3 = (h3 - 320)*18.66/320;
    y_3 = (240 - v3)*17.46/240;
    
    %Parametrize the 3 curves. Spherical coordinate system, with "phi"
    %equivalent equally the complimentary angle to what is usually "phi" in
    %standard spherical systems
    vec1 = [sind(x_1)*cosd(z_1); cosd(x_1)*cosd(z_1); sind(z_1)];
    vec2 = [cosd(y_2)*cosd(z_2); sind(y_2)*cosd(z_2); sind(z_2)];
    vec3 = [sind(x_3)*cosd(y_3); sind(y_3); cosd(x_3)*cosd(y_3)];
    
    %Assume only called when 2 or 3 points are found (not 0 or 1)
    if(h1 == 0 && v1 == 0)
        position = runConversionHelper(p2, vec2, p3, vec3);
    elseif (h2 == 0 && v2 == 0)
        position = runConversionHelper(p1, vec1, p3, vec3);
    elseif (h3 == 0 && v3 == 0)
        position = runConversionHelper(p1, vec1, p2, vec2);
    else %All 3 points found
        position = runConversionHelper(p1, vec1, p2, vec2, p3, vec3);
    end
                
end


%function that takes 2 (or 3) lines in 3d space and returns one single
%point, the position of the beacon
function [beacon] = runConversionHelper(p1, v1, p2, v2, p3, v3)
    
%r=p1+t*v1;	- parametric representation for line 1
%r=p2+s*v2;	- line 2
%r=p3+u*v3; - line 3


if (nargin == 4)
    a = [v1,-v2];
    b = p2-p1;
    x = a\b; % least squares solution - x gives you values of t, s
    %beacon = [(p1+x(1)*v1 + p2+x(2)*v2)/2];
    beacon = [(p1+x(1)*v1 + p2+x(2)*v2)/2;p1+x(1)*v1; p2+x(2)*v2];
    test =[p1; beacon(5); p2; beacon(8)];
    
    %UNCOMMENT TO INCLUDE SHORTEST DISTANCE   
    shortestDistInches = norm(dot(p2 - p1, (cross(v1, v2)/norm(cross(v1,v2)))));
    
elseif (nargin == 6)
    beacon = (runConversionHelper(p1, v1, p2, v2) + runConversionHelper(p1, v1, p3, v3) + runConversionHelper(p2, v2, p3, v3))/3;
    
    %Values for quality assurance. To determine uncertainty bounds
    z_uncertainty = norm(dot(p2 - p1, (cross(v1, v2)/norm(cross(v1,v2)))))/2;
    x_uncertainty = norm(dot(p3 - p1, (cross(v1, v3)/norm(cross(v1,v3)))))/2;
    y_uncertainty = norm(dot(p2 - p3, (cross(v2, v3)/norm(cross(v2,v3)))))/2;
    totalUncertainty = sqrt(z_uncertainty^2 + x_uncertainty^2 + y_uncertainty^2);

else
    disp('Incorrect number of arguments')
end


end 