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

% Last Modified by GUIDE v2.5 06-Feb-2016 15:35:15

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
digits(3);
handles.output = self;
handles.variables = 3*eye(1, 7);
handles.popDown.Value = 3;
handles.zoom = [10, 20];
handles.last_click = zeros(1, 3);
handles.axes_shift = zeros(1, 2);
set(handles.displayGraph, {'XMinorGrid', 'YMinorGrid', 'XGrid', 'YGrid',...
                           'XMinorTick', 'YMinorTick', 'XLimMode', 'YLimMode'},...
                          {'on','on','on','on','on','on','manual','manual'});
guidata(self, handles);
addlistener([handles.sldA, handles.sldB, handles.sldC,...
             handles.sldD, handles.sldE, handles.sldF],...
             'Value', 'PostSet', @(s, e) sld_Callback(e.AffectedObject));
addlistener(handles.sldZ, 'Value', 'PostSet', @(s, e) zoom_Callback(e.AffectedObject));

% --- Outputs from this function are returned to the command line.
function varargout = PolyFunctions_OutputFcn(self, ~, handles)
varargout{1} = handles.output;
refreshGUI(self, handles);
set(gcf, 'WindowButtonUpFcn', @mouse_Callback)
set(gcf, 'WindowButtonDownFcn', @mouse_Callback)
set(gcf, 'WindowButtonMotionFcn', @mouse_Callback)




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
v = str2double(self.String);
if isfloat(v) && isfinite(v)
    value = min(abs(v), 10)*sign(v);
    self.String = value;
    parent_sld.Value = value;
    handles.variables(end, uint8(family)-63) = round(value, 2);
else
    self.String = round(parent_sld.Value, 2);
end
refreshGraph(self, handles)

% --- Executes on button press in btnAddLine
function btnAddLine_Callback(self, ~, handles)
handles.variables(end+1, :) = handles.variables(end, :);
refreshGraph(self, handles);

% --- Executes on button press in btnUndo
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
refreshGUI(self, handles)

% --- Executes on mouse functions
function mouse_Callback(self, eventData)
handles = guidata(self);
ca = handles.displayGraph;
p = get(ca, 'CurrentPoint');
valid = inpolygon(p(1,1), p(2,2), ca.XLim, ca.YLim);
switch eventData.EventName
    case 'WindowMousePress'
        if valid
            handles.last_click = [p(1, 1:2), 1];
        end
    case 'WindowMouseRelease'
        handles.last_click(3) = 0;
    case 'WindowMouseMotion'
        if valid && handles.last_click(3)
            diff = handles.last_click(1:2) - p(1, 1:2);
            handles.axes_shift = handles.axes_shift + diff;
            handles.txtZ.Style = 'pushButton';
            handles.txtZ.String = 'Home';
            refreshGraph(self, handles);
        end
end
guidata(self, handles);

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




function coords = POI(coeff)
% Maintain original parameters
org_coeff = coeff;
coeff = polyder(coeff);
coords = zeros(2,0);
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


% --- REFRESH SLIDERS

function refreshGUI(self, handles)
types = {'txt', 'sld', 'lbl'};
bool = {'on', 'off'};
reset = 1;
switch self.Tag
    case 'btnClear'
        handles.variables = 3*eye(1,7);
    case 'btnReset'
        handles.variables(end, :) = 3*eye(1,7);
    otherwise
        reset = 0;
end
switch self.Tag
    case {'btnClear', 'btnReset'}
        degree = 3;
        handles.popDown.Value = 3;
        zoom_Home(self, handles);
        handles = guidata(self);
    otherwise
        degree = handles.popDown.Value;
        handles.variables(end, 1) = degree;
        handles.variables(end, degree+2:end) = 0;
end
for ii = 1:6
    if ii > degree || reset
        handles.(['txt', char(64+ii)]).String = '0';
        handles.(['sld', char(64+ii)]).Value = 0;
    end
    flag = char(bool((ii > degree) + 1));
    for jj = 1:length(types)
        set(handles.([types{jj}, char(64+ii)]), {'Enable', 'Visible'},...
                                                { flag,     flag});
    end
end
refreshGraph(handles.popDown, handles)


% --- REFRESH GRAPH ---

function refreshGraph(self, handles)
guidata(self, handles);
ca = handles.displayGraph;
cla(ca)
% Resize and move the focus of the graph according to handles.zoom(1) and
% handles.axes_shift respectively
axis(ca, reshape([1 1]'*handles.axes_shift,1,4)+[-1 1 -1 1]*handles.zoom(1))
% Draw the function along the limits of the x-axis to reduce computational
% strain yet allow for full visual of function
x = linspace(ca.XLim(1),ca.XLim(2),1000);
hold on;
plot(ca.XLim, [0 0], 'k--', [0 0], ca.YLim, 'k--')
coeff = handles.variables;
for ii = 1:size(handles.variables, 1)
    degree = coeff(ii, 1);
    y = polyval(coeff(ii, 2:degree+1), x);
    ca.ColorOrderIndex = mod(ii-1, 7)+1;
    plot(x, y);
    if handles.chkPOI.Value
        pois = POI(coeff(ii, 2:degree+1));
        ca.ColorOrderIndex = mod(ii-1, 7)+1;
        plot(pois(1,:), pois(2,:), 'o');
    end
    sol = poly2sym(coeff(ii, 2:degree+1));
    if handles.chkInt.Value
        ints = zeros(2,1);
        ints(2,1) = polyval(coeff(ii, 2:degree+1), 0);
        if degree > 1 && any(coeff(ii, 2:degree) ~= 0)
            x_int = double(vpasolve(sol == 0, ca.XLim));
            ints = horzcat(ints, [x_int'; zeros(1, length(x_int))]);
        end
        for jj = 1:ii-1
            if ii ~= jj
                degree_jj = coeff(jj, 1);
                x_int = double(vpasolve(sol == poly2sym(coeff(jj, 2:degree_jj+1)), ca.XLim));
                ints = horzcat(ints, [x_int, polyval(coeff(jj, 2:degree_jj+1), x_int)]');
            end
        end
        plot(ints(1,:), ints(2,:), 'ks')
    end
end
equation = char(vpa(sol, 3));
if ~strcmp(equation, '0.0')
    equation = [sprintf('f(x)_%d = ', size(coeff, 1)), equation];
else
    equation = '';
end
xlabel(ca, texlabel(equation));
Z = handles.zoom(2);
% Shift the axes labels in correspondance to the axes_shift
ticks_x = [-Z:Z/4:Z] + round(handles.axes_shift(1)/Z*4)*Z/4;
ticks_y = [-Z:Z/4:Z] + round(handles.axes_shift(2)/Z*4)*Z/4;
set(ca, {'XTick', 'XTickLabel', 'YTick', 'YTickLabel'},...
        { ticks_x, ticks_x,      ticks_y, ticks_y});
hold off;
