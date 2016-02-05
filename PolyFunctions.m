function varargout = PolyFunctions(varargin)
% POLYFUNCTIONS MATLAB code for PolyFunctions.fig
%      POLYFUNCTIONS, by itself, creates a new POLYFUNCTIONS or raises the existing
%      singleton*.
%
%      H = POLYFUNCTIONS returns the handle to a new POLYFUNCTIONS or the handle to
%      the existing singleton*.
%
%      POLYFUNCTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POLYFUNCTIONS.M with the given input arguments.
%
%      POLYFUNCTIONS('Property','Value',...) creates a new POLYFUNCTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PolyFunctions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PolyFunctions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PolyFunctions

% Last Modified by GUIDE v2.5 05-Feb-2016 17:17:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PolyFunctions_OpeningFcn, ...
    'gui_OutputFcn',  @PolyFunctions_OutputFcn, ...
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


% --- Executes just before PolyFunctions is made visible.
function PolyFunctions_OpeningFcn(self, ~, handles, varargin)

handles.output = self;
handles.variables = 3*eye(1, 7);
handles.popDown.Value = 3;
handles.zoom = [10, 20];
handles.last_click = zeros(1, 3);
handles.axes_shift = zeros(1, 2);
set(handles.displayGraph, {'XLimMode', 'YLimMode'}, {'manual','manual'});
guidata(self, handles);
addlistener([handles.sldA, handles.sldB, handles.sldC,...
             handles.sldD, handles.sldE, handles.sldF],...
             'Value', 'PostSet', @(s, e) sld_Callback(e.AffectedObject));
addlistener(handles.sldZ, 'Value', 'PostSet', @(s, e) zoom_Callback(e.AffectedObject));
warning('off', 'MATLAB:deblank:NonStringInput');

% --- Outputs from this function are returned to the command line.
function varargout = PolyFunctions_OutputFcn(self, ~, handles)
varargout{1} = handles.output;
hideAndShowFeatures(self, handles);
set(gcf, 'WindowButtonUpFcn', @axs_btnUp)
set(gcf, 'WindowButtonDownFcn', @axs_btnDown)
set(gcf, 'WindowButtonMotionFcn', @axs_btnMove)




% --- Executes during slider creation
function sld_CreateFcn(self, ~, ~)
if isequal(get(self,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(self,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during drop down creation
function popDown_CreateFcn(self, ~, ~)
if ispc && isequal(get(self,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(self,'BackgroundColor','white');
end

% --- Executes during text label creation
function txt_CreateFcn(self, ~, ~)
if ispc && isequal(get(self,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(self,'BackgroundColor','white');
end





% --- Executes on slider movement.
function sld_Callback(varargin)
self = varargin{1};
if nargin == 1
    handles = guidata(self);
else
    handles = varargin{end};
end
value = round(self.Value, 2);
family = self.Tag(end);
handles.(['txt', family]).String = value;
handles.variables(end, uint8(family)-63) = value;
refreshGraph(self, handles)

% --- Executes on textbox entry. 
function txt_Callback(self, ~, handles)
family = self.Tag(end);
parent_sld = handles.(['sld', family]);
value = str2double(get(self, 'String'));
if value > 10
    set(parent_sld, 'Value', 10.0)
    set(self, 'String', 10.0)
elseif value < -10
    set(parent_sld, 'Value', -10.0)
    set(self, 'String', -10.0)
else
    set(parent_sld, 'Value', value)
end
handles.variables(end, uint8(family)-63) = round(value, 2);
refreshGraph(self, handles)

% --- Executes on zoom slider movement
function zoom_Callback(varargin)
if nargin ~= 1
    handles = varargin{end};
    self = handles.sldZ;
    self.Value = 0;
    handles.txtZ.Style = 'text';
    handles.txtZ.String = 'Zoom';
else
    self = varargin{1};
    handles = guidata(self);
    handles.txtZ.Style = 'pushButton';
    handles.txtZ.String = 'Home';
end
ac = 5*2^(-self.Value+1);
handles.zoom = [ac, 5*2^(floor(-self.Value)+2)];
axis(handles.displayGraph, [-ac ac -ac ac])
refreshGraph(self, handles);

function zoom_Home(self, handles)
handles.axes_shift = zeros(1,2);
guidata(self, handles);
zoom_Callback(self, handles)



% --- Executes on button press in btnAddLine.
function btnAddLine_Callback(self, ~, handles)
handles.variables(end+1, :) = handles.variables(end, :);
refreshGraph(self, handles);

% --- Executes on selection change in popDown.
function popDown_Callback(self, ~, handles)
hideAndShowFeatures(self, handles)

% --- Executes on button press in btnReset.
function btnReset_Callback(self, ~, handles)
reset(self, handles)

% --- Executes on button press in btnClear.
function btnClear_Callback(self, ~, handles)
handles.variables = 3*eye(1,7);
reset(self, handles)

% --- Executes on button press in btnUndo.
function btnUndo_Callback(self, ~, handles)
handles.variables(end, :) = [];
if size(handles.variables, 1) < 1
    handles.variables(end+1, :) = 3*eye(1,7);
end
for ii=2:7
    handles.(['sld', char(ii+63)]).Value = handles.variables(end, ii);
    handles.(['txt', char(ii+63)]).String = handles.variables(end, ii);
end
handles.popDown.Value = handles.variables(end, 1);
hideAndShowFeatures(self, handles)

function axs_btnUp(~, ~)
ax = gca;
handles = guidata(ax);
handles.last_click(3) = 0;
guidata(ax, handles)

function axs_btnDown(~, ~)
ax = gca;
handles = guidata(ax);
p = get(ax, 'CurrentPoint');
Lim = [handles.displayGraph.XLim; handles.displayGraph.YLim];
if inpolygon(p(1,1),p(1,2),Lim(1,:),Lim(2,:))
    handles.last_click = [p(1, 1:2), 1];
    guidata(ax, handles);
end

function axs_btnMove(~, ~)
ax = gca;
handles = guidata(ax);
p = get(ax, 'CurrentPoint');
Lim = [handles.displayGraph.XLim; handles.displayGraph.YLim];
if inpolygon(p(1,1),p(1,2),Lim(1,:),Lim(2,:)) && handles.last_click(3)
    diff = handles.last_click(1:2) - p(1, 1:2);
    handles.axes_shift = handles.axes_shift + diff;
    handles.txtZ.Style = 'pushButton';
    handles.txtZ.String = 'Home';
    refreshGraph(ax, handles);
end




function coords = POI(coeff)
% Maintain original parameters
org_coeff = coeff;
coords = [0; polyval(org_coeff,0)];
% Initialize loop through derivatives and consequential roots
while ~all(coeff == 0)
    x = roots(coeff)';
    % Only plot real roots
    if all(isreal(x))
        points = [x; polyval(org_coeff, x)];
        coords = [coords, points];
    end
    % Derive polynomial coefficients for next iteration
    coeff = polyder(coeff);
end

function hideAndShowFeatures(~, handles)
types = {'txt', 'sld', 'lbl'};
bool = 'on';
degree = handles.popDown.Value;
handles.variables(end, 1) = degree;
handles.variables(end, degree+2:end) = 0;
for ii = 1:6
    if ii > handles.popDown.Value
        bool = 'off';
        handles.(['txt', char(64+ii)]).String = '0';
        handles.(['sld', char(64+ii)]).Value = 0;
    end
    for jj = 1:length(types)
        handles.([types{jj}, char(64+ii)]).Enable = bool;
    end
end
refreshGraph(handles.popDown, handles)

function reset(self, handles)
for ii = 1:6
    handles.(['txt', char(64+ii)]).String = 0;
    handles.(['sld', char(64+ii)]).Value  = 0;
end
handles.variables(end, :) = 3*eye(1,7);
handles.popDown.Value = 3;
hideAndShowFeatures(self, handles)

function refreshGraph(self, handles)
guidata(self, handles);
cla(handles.displayGraph)
% Resize and move the focus of the graph according to handles.zoom(1) and
% handles.axes_shift respectively
axis(handles.displayGraph, reshape([handles.axes_shift;handles.axes_shift],1,4)+[-1 1 -1 1]*handles.zoom(1))
% Draw the function along the limits of the x-axis to reduce computational
% strain yet allow for full visual of function
x = linspace(handles.displayGraph.XLim(1),handles.displayGraph.XLim(2),1000);
hold on;
for n = 1:size(handles.variables, 1)
    degree = handles.variables(n, 1);
    y = polyval(handles.variables(n, 2:degree+1), x);
    handles.displayGraph.ColorOrderIndex = mod(n-1, 7)+1;
    plot(x, y);
    pois = POI(handles.variables(n, 2:degree+1));
    handles.displayGraph.ColorOrderIndex = mod(n-1, 7)+1;
    plot(pois(1,:), pois(2,:), 'o');
end
equation = 'f(x) =';
for ii = 1:degree
    dd = degree-ii;
    coeff = handles.variables(end, ii+1);
    preamble = ' %.3g';
    if size(equation, 2) > 7
        % If this is not the first coefficient to be drawn, add sign
        % symbols and spaces as a prelude
        preamble = [' ', char(44-sign(coeff)), preamble];
        coeff = abs(coeff);
    end
    if coeff ~= 0
        % Do not draw coefficients of zero (0)
        equation = [equation, sprintf(strcat(preamble, 'x'*(dd > 0), ['^', num2str(dd)]*(dd > 1)), coeff)];
    end
end
xlabel(handles.displayGraph, texlabel(equation));
Z = handles.zoom(2);
% Shift the axes labels in correspondance to the axes_shift
ticks_x = [-Z:Z/4:Z] + round(handles.axes_shift(1)/Z*4)*Z/4;
ticks_y = [-Z:Z/4:Z] + round(handles.axes_shift(2)/Z*4)*Z/4;
set(handles.displayGraph, 'XMinorGrid', 'on', ...
                          'YMinorGrid', 'on', ...
                          'YGrid', 'on', ...
                          'XGrid', 'on', ...
                          'XMinorTick','on',...
                          'YMinorTick','on',...
                          'XTick', ticks_x, ...
                          'XTickLabel', ticks_x,...
                          'YTick', ticks_y,...
                          'YTickLabel', ticks_y)
hold off;
