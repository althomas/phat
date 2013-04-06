%Script to plot the coverage on the latent space. If gradeHand.m was run in
%adavance all relevant variables should be in the workspace.
%
%
%Copyright(c) Thomas Feix, thomas@xief.net
%Grade your Hand Toolbox downloaded available at grasp.xief.net
%
%The Toolbox is distributed under GPL3 licence. 
%Revision 2.1, 2012-12-18


%% Settings:
mSize = 13; %size of the markers of the plot
magnify.set = 1; %Plot the magnification window?
magnify.size = 100;%size of the window, smaller number has more space around the trajectory
showResults = 1; %Plot the coverage result?



%% Symbols for the plot           
symbols = {'r.' 'g.' 'b.' 'c.' 'm.'};
if size(symbols,2) < size(lbls,2) %check if there are enough symbols for the number of labels
    error('Not enough symbols, you have to add more')
end

%% 

if ~exist('fighand','var')%if no figure exist create new one
    fighand = figure;
else
    fighand = figure(fighand);
end
clf
ax = axes('Position',[0 0 1 1]);
hold on

%% Plotting of the black/white background
image(model.background.x1, model.background.x2, model.background.C,'parent',ax);
colormap gray;
axis tight



%% Plot of the trajectory


for i = 1:size(lbls,2)
   inds = find(lbls(:,i) == 1);
   plot(latent(inds,1),latent(inds,2),['-' symbols{i}],'markerSize',mSize,'lineWidth',2)    
end

%% Plot of the covered rectangles
hold on 
for ind = boxInds
    plot([model.Prob.XTest(ind,1) model.Prob.XTest(ind,1)+model.Prob.dx(1) model.Prob.XTest(ind,1)+model.Prob.dx(1) model.Prob.XTest(ind,1), model.Prob.XTest(ind,1)],...
         [model.Prob.XTest(ind,2) model.Prob.XTest(ind,2) model.Prob.XTest(ind,2)+model.Prob.dx(2) model.Prob.XTest(ind,2)+model.Prob.dx(2), model.Prob.XTest(ind,2)],'-b');
end
                    
                    

%% Plot of the magified window

magnify.location = [-2 2 -2 2];
dx = (model.background.xLim(2)-model.background.xLim(1))/magnify.size; 
dy = (model.background.yLim(2)-model.background.yLim(1))/magnify.size;

magnify.location = [min(latent(:,1))-dx*1.5 max(latent(:,1))+dx min(latent(:,2))-dy max(latent(:,2))+1.5*dy]; %location of th window

if magnify.location(1) < model.background.xLim(1)
    magnify.location(1) = model.background.xLim(1);
end
if magnify.location(2) > model.background.xLim(2)
    magnify.location(2) = model.background.xLim(2);
end
if magnify.location(3) < model.background.yLim(1)
    magnify.location(3) = model.background.yLim(1);
end
if magnify.location(4) > model.background.yLim(2)
    magnify.location(4) = model.background.yLim(2);
end


 if magnify.set
        plot([magnify.location(1) magnify.location(2) magnify.location(2) magnify.location(1) magnify.location(1)],[magnify.location(3) magnify.location(3) magnify.location(4) magnify.location(4),magnify.location(3)],'k-','lineWidth',1)
        ax1 = axes('Position',[0.001 0.5999 0.4*dy/dx 0.4]);
        hold on
        axis(magnify.location)
        image(model.background.x1, model.background.x2, model.background.C,'parent',ax1);
        lvmTwoDPlotLegend(latent,lbls,symbols,4)
        
        plot([magnify.location(1) magnify.location(2) magnify.location(2) magnify.location(1) magnify.location(1)],[magnify.location(3) magnify.location(3) magnify.location(4) magnify.location(4),magnify.location(3)],'k-','lineWidth',2)
        set(ax1,'Xtick',[])
        set(ax1,'Ytick',[])
        
        %box(ax1,'on')
 end  

 hold off
 
 
 %% Annotation of the figure
 if showResults
    annotation('textbox',[0 0 .1 .1],'String',['Relative Coverage: ' num2str(RelativeArea,'%.2f') '%'],'BackgroundColor',[1 1 1],'FontSize',9)
 end
 
%% Figure Saving
[f p] = uiputfile('*.png', 'Save Figure as');
 
if f == 0
    disp('Saving aborted')
else
   print('-dpng', '-r200',fullfile(p,f))
end
 
 
 
 
 