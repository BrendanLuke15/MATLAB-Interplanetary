function [h] = PorkchopPlot(Planets,Vinf,Parameter,Leg,other,n,ae_flag)
% Function to make porkchop plot:
% Inputs:
%   - Planets: Planets struct
%   - Vinf: Vinf struct
%   - Parameter: metrics to plot
%       - C3 (km^2/s^2 -> [none])
%       - V_Entry (inertial, km/s -> [mu1, R_Planet1, h_interface1, mu2, R_Planet2, h_interface2])
%       - dV (km/s -> [mu1, R_Planet1, h_orb1, mu2, R_Planet2, h_orb2])
%       - Vinf (km/s -> [none])
%   - Leg: leg of trajectory to plot
%   - other: vector of ancilliary information needed for some parameters
%       - see items insude square brackets [] in Parameter input above for what to include
%   - n: tick spacing (days), applies to both x & y axes
%   - ae_flag: axis equal flag
% Outputs:
%   - Figure

% axis equal input logic
if ~isa(ae_flag,'logical')
    txt = sprintf("Error: ae_flag is not a 'logical' type");
    error(txt);
end

h = figure('name','Porkchop Plot');
set(gcf,'WindowState','Maximized');

Date1 = Planets.Dates{Leg};
Date2 = Planets.Dates{Leg+1};

% Departure
ax1 = subplot(1,2,1);
if strcmp(Parameter(1),'C3')
    [One,c1] = contourf(datenum(Date1),datenum(Date2),(Vinf.Magnitude{2*Leg-1}.^2)','ShowText','on');
    kLabelString = sprintf('C3 (km^2/s^2)');
elseif strcmp(Parameter(1),'V_Entry')
    [One,c1] = contourf(datenum(Date1),datenum(Date2),(sqrt(2*other(1)/(other(2)+other(3))+Vinf.Magnitude{2*Leg-1}.^2))','ShowText','on');
    kLabelString = 'V_{Entry} (km/s)';
elseif strcmp(Parameter(1),'dV')
    [One,c1] = contourf(datenum(Date1),datenum(Date2),(sqrt(2*other(1)/(other(2)+other(3))+Vinf.Magnitude{2*Leg-1}.^2)-sqrt(other(1)/(other(2)+other(3))))','ShowText','on');
    kLabelString = '\Delta V (km/s)';
elseif strcmp(Parameter(1),'Vinf')
    [One,c1] = contourf(datenum(Date1),datenum(Date2),Vinf.Magnitude{2*Leg-1}','ShowText','on');
    kLabelString = 'V_{\infty} (km/s)';
end

colormap(myColorMap(15));
k = colorbar;
k.Label.String = kLabelString;
C=caxis;
caxis([C(1),C(2)]);
xlabel([Planets.Name{Leg},' Departure Date']);
ylabel([Planets.Name{Leg+1},' Arrival Date']);
title('Departure:');
grid on
if ae_flag
    axis equal
end
hold on
plot(datenum(Date1),datenum(Date1),'k-','LineWidth',1.5);

xlim([datenum(Date1(1)) datenum(Date1(end))]);
ylim([datenum(Date2(1)) datenum(Date2(end))]);
dateFormat = 'yyyy-mmm-dd';

L = get(gca,'XLim');
set(gca,'XTick',[L(1):n:L(2)])
L = get(gca,'YLim');
set(gca,'YTick',[L(1):n:L(2)])
xtickangle(60)

datetick('x',dateFormat,'keeplimits', 'keepticks')
datetick('y',dateFormat,'keeplimits', 'keepticks')

% Arrival
ax2 = subplot(1,2,2);
if strcmp(Parameter(2),'C3')
    [Two,c2] = contourf(datenum(Date1),datenum(Date2),(Vinf.Magnitude{2*Leg}.^2)','ShowText','on');
    kLabelString = 'C3 (km^2/s^2)';
elseif strcmp(Parameter(2),'V_Entry')
    [Two,c2] = contourf(datenum(Date1),datenum(Date2),(sqrt(2*other(4)/(other(5)+other(6))+Vinf.Magnitude{2*Leg}.^2))','ShowText','on');
    kLabelString = 'V_{Entry} (km/s)';
elseif strcmp(Parameter(2),'dV')
    [Two,c2] = contourf(datenum(Date1),datenum(Date2),(sqrt(2*other(4)/(other(5)+other(6))+Vinf.Magnitude{2*Leg}.^2)-sqrt(2*other(4)/(other(5)+other(6))))','ShowText','on');
    kLabelString = '\Delta V (km/s)';
elseif strcmp(Parameter(2),'Vinf')
    [Two,c2] = contourf(datenum(Date1),datenum(Date2),Vinf.Magnitude{2*Leg}','ShowText','on');
    kLabelString = 'V_{\infty} (km/s)';
end

colormap(myColorMap(15));
k = colorbar;
k.Label.String = kLabelString;
C2=caxis;
caxis([C2(1),C2(2)]);
xlabel([Planets.Name{Leg},' Departure Date']);
ylabel([Planets.Name{Leg+1},' Arrival Date']);
title('Arrival:');
grid on
if ae_flag
    axis equal
end
hold on
plot(datenum(Date1),datenum(Date1),'k-','LineWidth',1.5);

xlim([datenum(Date1(1)) datenum(Date1(end))]);
ylim([datenum(Date2(1)) datenum(Date2(end))]);
dateFormat = 'yyyy-mmm-dd';

L = get(gca,'XLim');
set(gca,'XTick',[L(1):n:L(2)])
L = get(gca,'YLim');
set(gca,'YTick',[L(1):n:L(2)])
xtickangle(60)

datetick('x',dateFormat,'keeplimits', 'keepticks')
datetick('y',dateFormat,'keeplimits', 'keepticks')

% Common: custom data cursor and linked zoom and pan of subplots
dcm_obj = datacursormode(h);
set(dcm_obj,'UpdateFcn',@perso_datacursor)
linkaxes([ax1 ax2],'xy');

end