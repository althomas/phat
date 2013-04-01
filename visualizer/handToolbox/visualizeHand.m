function varargout = visualizeHand(varargin)
%function visualizeHand(robot, values, humMat)
%
%Visualizes a robot hand model. Requires the robotic toolbox of P. Corke. 
%
%   input:
%       - robot: Robot hand model struct. For example sensorhandmodel.m creates
%       such a struct.
%       - values: Joint values for the robot hand.
%       - humMat: Matrix of the human hand movements
%
%
%Copyright(c) Thomas Feix, thomas@xief.net
%Grade your Hand Toolbox downloaded available at grasp.xief.net
%
%The Toolbox is distributed under GPL3 licence. 
%Revision 2.1, 2012-12-18


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualizeHand_OpeningFcn, ...
                   'gui_OutputFcn',  @visualizeHand_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before visualizeHand is made visible.
function visualizeHand_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to visualizeHand (see VARARGIN)

% Choose default command line output for visualizeHand
handles.output = hObject;




handles.robot = cell2mat(varargin(1));
handles.values = cell2mat(varargin(2));
handles.humMat = scaleData(cell2mat(varargin(3)),-1); %move human mcp to (0,0,0)
handles.plotHumanFingertips = 0;
handles.plotRobotFingertips = 1;

if handles.plotHumanFingertips
    set(handles.radioFingertipHuman,'Value',1);
else
    set(handles.radioFingertipHuman,'Value',0);
end

if handles.plotRobotFingertips
    set(handles.radioFingertipRobot,'Value',1);
    handles.robMat = robotfkine(handles.robot,handles.values);
else
    set(handles.radioFingertiprobot,'Value',0);
end


handles.length = size(handles.values,1);
set(handles.slider,'Max',handles.length);
set(handles.slider,'Value',1);
set(handles.slider,'Min',1);
set(handles.slider,'SliderStep',[1/handles.length 1/handles.length*10]);

set(handles.textFrame, 'String', ['Frame: ' num2str(floor(get(handles.slider,'Value'))) '/' num2str(handles.length)]);

initializeBigPlot(handles)

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = visualizeHand_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


%################# SLIDER CALLBACK #######################################
function slider_Callback(hObject, eventdata, handles)
set(handles.textFrame, 'String', ['Frame: ' num2str(floor(get(handles.slider,'Value'))) '/' num2str(handles.length)]);

updatePlot(handles)


function slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



%######################## INITIALIZE BIG PLOT ###########################
function initializeBigPlot(handles)

frame = floor(get(handles.slider,'value'));
%set(handles.label,'string',num2str(frame));

axes(handles.bigdiag)
cla
hold on


set(handles.tableValues,'Data',rad2deg(handles.values(frame,:)'));
fingerdistance(handles);
ind = 1;
for f = 1:size(handles.robot.finger,2)

plot(handles.robot.finger{f}, handles.values(frame,ind:ind+handles.robot.dof(f)-1),'noshadow','nobase','delay',0);
    ind = ind + handles.robot.dof(f);
end

if handles.plotHumanFingertips
    symbolHum = {'r.' 'g.' 'b.' 'y.' 'c.'};
    for i = 1:5
        tempHum = handles.humMat(:,(i-1)*12+1:i*12);
        plot3(tempHum(:,1),tempHum(:,2),tempHum(:,3),symbolHum{i},'MarkerSize',1)
    end
end

if handles.plotRobotFingertips
    symbolRob = {'r.' 'g.' 'b.' 'y.' 'c.'};
    for i = 1:5
        tempRob = handles.robMat(:,(i-1)*12+1:i*12);
        plot3(tempRob(:,1),tempRob(:,2),tempRob(:,3),symbolRob{i},'MarkerSize',6)
    end
end


rotate3d on
hold off
axis([-12 12 -12 12 -12 12])
grid on
set(gca,'XDir','reverse');
set(gca,'ZDir','reverse');




%################# UPDATE BIG PLOT #######################################
function updatePlot(handles)
frame = floor(get(handles.slider,'value'));
fingerdistance(handles)

hold on
ind = 1;
set(handles.tableValues,'Data',rad2deg(handles.values(frame,:)'));
for f = 1:size(handles.robot.finger,2)
    plot(handles.robot.finger{f}, handles.values(frame,ind:ind+handles.robot.dof(f)-1),'noshadow','nobase','delay',0);
    ind = ind + handles.robot.dof(f);
end
hold off


%#################### CALCULATE FINGERTIP DISTANCES ######################
function fingerdistance(handles)
frame = floor(get(handles.slider,'value'));
ind = 1;
for f = 1:size(handles.robot.finger,2)
    fing{f} = fkine(handles.robot.finger{f},handles.values(frame,ind:ind+handles.robot.dof(f)-1));
    ind = ind + handles.robot.dof(f);
end


d = zeros(size(handles.robot.finger,2),size(handles.robot.finger,2));
for i = 1:size(handles.robot.finger,2)
    for j = 1:size(handles.robot.finger,2)
        tempmat = fing{j}-fing{i};
        d(i,j) = norm(tempmat(1:3,4));
    end 
end

set(handles.tableDistances,'Data',d)



% --- Executes on button press in radioFingertipHuman.
function radioFingertipHuman_Callback(hObject, eventdata, handles)
% hObject    handle to radioFingertipHuman (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioFingertipHuman

if get(hObject,'Value')
   handles.plotHumanFingertips = 1;
else
    handles.plotHumanFingertips = 0;
end

initializeBigPlot(handles)
guidata(hObject, handles);


% --- Executes on button press in radioFingertipRobot.
function radioFingertipRobot_Callback(hObject, eventdata, handles)
% hObject    handle to radioFingertipRobot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioFingertipRobot
if get(hObject,'Value')
   handles.plotRobotFingertips = 1;
else
    handles.plotRobotFingertips = 0;
end

initializeBigPlot(handles)
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function slider_graspType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_graspType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in screenshot.
function screenshot_Callback(hObject, eventdata, handles)
% hObject    handle to screenshot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  [f p] = uiputfile({'*.png', 'PNG File';}, 'Save Screenshot as');
feature('UseGenericOpengl', 1)
if isequal(f,0) || isequal(p,0)
    disp('User pressed cancel')
else
    set(gcf,'PaperPositionMode','auto')
    set(gcf,'InvertHardcopy','off')
    print('-dpng', '-r400', '-loose',fullfile(p,f),'-painters')
end
