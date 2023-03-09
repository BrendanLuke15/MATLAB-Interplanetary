% Interplanetary Trajectories w/ SPICE
% available on GitHub: https://github.com/BrendanLuke15/MATLAB-Interplanetary
format compact
clear, clc, close all
tic
%% Load SPICE Kernels
% if error re-write to PATH:
addpath('Path\to\..\mice\lib');
addpath('Path\to\..\mice\src\mice');

cspice_furnsh('kernels\de440.bsp'); % DE440 ephemeris
cspice_furnsh('kernels\naif0012.tls'); % leap seconds kernel
cspice_furnsh('kernels\gm_de431.tpc'); % solar system GM values
cspice_furnsh('kernels\pck00011.tpc'); % solar system sizes and orientation

%% Inputs
% Planets
Planets = struct('Name',[],'Mu',[],'R',[],'State',[],'Dates',[],'TOF',[],'Step',[]);
Planets.Name = {'Earth','Pluto'}; % planets of trajectory
for i = 1:length(Planets.Name)
    Planets.Mu(i) = cspice_bodvrd(char(Planets.Name(i)),'GM',1);
    R = cspice_bodvrd(char(Planets.Name(i)),'RADII',3);
    Planets.R(i) = R(1);
end
clearvars R

% Period of Interest & Time of Flights
StartDate = datetime(2023,05,01,0,0,0);
Planets.Step = 2; % time step of TOF vectors (days)
Planets.TOF = {86400*(0:Planets.Step:450)',...
    86400*(1500:Planets.Step:3500)'}; % time of flight vector (s), first item is Launch period

% convert to Ephemeris Time (et)
et0 = cspice_str2et(datestr(StartDate));

% Constants
mu_Sun = cspice_bodvrd('sun','GM',1);
au = 149597870.693; % from DE403

%% Get State Vectors & Dates
Planets.Dates{1} = StartDate+seconds(Planets.TOF{1}); % write "launch" dates
try
    [state,~] = cspice_spkezr(char(Planets.Name(1)),cspice_str2et(datestr(StartDate+seconds(Planets.TOF{1}))),'eclipj2000','none','ssb'); % write "launch" states
catch
    [state,~] = cspice_spkezr(strcat(char(Planets.Name(1)),' Barycenter'),cspice_str2et(datestr(StartDate+seconds(Planets.TOF{1}))),'eclipj2000','none','ssb'); % case for barycenter systems
end
Planets.State{1} = state'; % write state
for i = 2:length(Planets.Name)
    temp_Dates = Planets.Dates{i-1};
    temp_TOF = Planets.TOF{i};
    Planets.Dates{i} = (temp_Dates(1)+seconds(temp_TOF(1)):days(Planets.Step):temp_Dates(end)+seconds(temp_TOF(end)))'; % write dates
    try
        [state,~] = cspice_spkezr(char(Planets.Name(i)),cspice_str2et(datestr(Planets.Dates{i})),'eclipj2000','none','ssb');
    catch
        [state,~] = cspice_spkezr(strcat(char(Planets.Name(i)),' Barycenter'),cspice_str2et(datestr(Planets.Dates{i})),'eclipj2000','none','ssb'); % case for barycenter systems
    end
    Planets.State{i} = state'; % write state
end
clearvars state temp_TOF temp_Dates

%% Populate V_inf Matrices
Vinf = struct('Vector',[],'Magnitude',[]);
for i = 2:length(Planets.Name)
    [VinfA,VinfB] = VinfVectorFunc(Planets.State{i-1},Planets.State{i},Planets.Dates{i-1},Planets.Dates{i},Planets.TOF{i});
    Vinf.Vector{2*(i-1)-1} = VinfA(:,:,1:3);
    Vinf.Vector{2*(i-1)} = VinfB(:,:,1:3);
    Vinf.Magnitude{2*(i-1)-1} = VinfA(:,:,4);
    Vinf.Magnitude{2*(i-1)} = VinfB(:,:,4);
end
clearvars VinfA VinfB

%% Groom Data
Vinf = GroomData(Vinf,'Reset',0,false,0,[]); % reset raw data
Vinf = GroomData(Vinf,'C3',50,true,1,[]); % groom C3
% Vinf = GroomData(Vinf,'V_Entry',7.5,true,1,[Planets.Mu(2), Planets.R(2), 125]); % groom based on inertial entry velocity

% [Vinf,trajKPIs] = FlybyGroom(Planets,Vinf,[0.2 4*Planets.R(2)]); % for multi planet flyby trajectories

%% Porkchop Plot
PorkchopPlot(Planets,Vinf,{'C3','Vinf'},1,[],14,false);
% PorkchopPlot(Planets,Vinf,{'dV','dV'},1,[Planets.Mu(1), Planets.R(1), 250, Planets.Mu(2), Planets.R(2), 0],70,false);
% PorkchopPlot(Planets,Vinf,{'Vinf','Vinf'},2,[],70,true);
% FlybyVinfPlot(Planets,Vinf,1,28);

%% Stop Clock
toc
