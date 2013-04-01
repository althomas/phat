%This script shows how to grade a given hand model. Follow the steps as
%specified in that file and you will get a result on the coverage of the
%specified hand model. 
%
%I also presents all functions that can be found in the package. 
%
%Copyright(c) Thomas Feix, thomas@xief.net
%Grade your Hand Toolbox downloaded available at grasp.xief.net
%
%The Toolbox is distributed under GPL3 licence. 
%Revision 2.1, 2012-12-18



%load a hand model
[robot values lbls handlength] = sensorhandmodel;

%calculate the forward kinematics
datamat = robotfkine(robot,values);


%scale the positions
%if you did create the fingertip points externally you have to continue at
%this point and supply the function with the datamat and handlength values.
datamatScaled = scaleData(datamat, handlength);

load('model.mat') %load the data of the gplvm model.

%Project the high dimensional data to 2D with the use of the Back
%Constraints of the GPLVM Model. 
latent = data2latent(model,datamatScaled);




%Given the latent locations and the values for the discretized latent space
%this function calulates the coverages. 
[areaTot area boxInds] = handMetricBox(latent,model);


RelativeArea = area/areaTot*100;  

disp('Results:')
disp(['Total Volume occupied by this latent space: ' num2str(areaTot)])
disp(['Volume covered by this hand: ' num2str(area)]);
disp(['Relative Coverage [%]: ' num2str(RelativeArea)])


plotProjection



%Check the alignment with the human datapoints
load('humMat.mat')
checkAlignment(humMat,datamat)


%Visualize the movement of the fingertips
%needs the loaded humMat 
visualizeHand(robot,values,humMat)









