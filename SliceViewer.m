function SliceViewer()

global DICOMVolume axes_img_2 M

figure_1=figure('MenuBar','none','Units','centimeters','Name','SliceViewer','NumberTitle','off','Position',[5,3,25,15],'windowstyle', 'normal', 'resize', 'off');
view_panel = uipanel('parent',figure_1,'BorderType','etchedin','Title','Controls','Units','centimeters','Position',[0.5 0.5 24 3]);

axes_img_1 = axes('parent',figure_1,'units','centimeters','position',[1 5 9 9]);
axes_img_2 = axes('parent',figure_1,'units','centimeters','position',[13 5 9 9]);


load_button =uicontrol('parent',view_panel,'Style','Pushbutton','Units','centimeters','String','LOAD DICOM','Position',[0.5,0.4,4,2],...
 'FontSize',13,'HorizontalAlignment','Center','CallBack',@load_rot);

plane_text = uicontrol('parent',view_panel,'Style','Text','String','View Plane','Units','centimeters','Position',[6,1.8,3.3,0.5],'HorizontalAlignment','Left','FontSize',10);
plane_sort = uicontrol('parent',view_panel,'Units','centimeters','Enable','on','Style', 'popup',...
           'String', {'X-Y','Y-Z','X-Z'},'Value',1,'Position', [10 1.9 2 0.5],'Callback', @plane_rot); 
       
resolution_x_text = uicontrol('parent',view_panel,'Style','Text','String','Resolution (X/mm)','Units','centimeters','Position',[6,1.2,3.3,0.5],'HorizontalAlignment','Left','FontSize',10);
resolution_x_edit = uicontrol('parent',view_panel,'Style','Edit','String','8.0','Units','centimeters','Position',[10,1.2,2,0.5],'HorizontalAlignment','Left','FontSize',10);

resolution_y_text = uicontrol('parent',view_panel,'Style','Text','String','Resolution (Y/mm)','Units','centimeters','Position',[6,0.6,3.3,0.5],'HorizontalAlignment','Left','FontSize',10);
resolution_y_edit = uicontrol('parent',view_panel,'Style','Edit','String','1.0','Units','centimeters','Position',[10,0.6,2,0.5],'HorizontalAlignment','Left','FontSize',10);

resolution_z_text = uicontrol('parent',view_panel,'Style','Text','String','Slice Position (Z/mm)','Units','centimeters','Position',[13,1.6,3.3,0.5],'HorizontalAlignment','Left','FontSize',10);
resolution_z_edit = uicontrol('parent',view_panel,'Style','Edit','String','1','Units','centimeters','Position',[15.5,1.6,1.5,0.5],'HorizontalAlignment','Left','FontSize',10);
sld_bar = uicontrol('parent',view_panel,'Style', 'slider','Min',1,'Max',200,'Value',1,'SliderStep',[0.001 1],'Units','centimeters','Position', [13,1,10,0.5],'Callback', @sld_fun); 

reset_button =uicontrol('parent',view_panel,'Style','Pushbutton','Units','centimeters','String','RESET','Position',[15,0.2,3,0.5],...
 'FontSize',11,'HorizontalAlignment','Center','CallBack',@reset_rot);
drawnow

%/////////// callback functions ////////////////////////////////////

function load_rot(varargin)
    DICOMFolder=uigetdir('select directory contains DICOM files');      % asking uder to select the director for DICOM files
    DICOMVolume = LoadDICOMVolume([1 200], DICOMFolder);                % calling function to load volume of dicom files in the folder
    M=DICOMVolume.ImageData;
    disp(' ')
    
    S=str2num(get(resolution_z_edit,'String'));
    if(S>0 && S<=200)
        update_dis(S)
    else
        msgbox('Please select valid slice number', 'Error', 'Error')
    end
end

function sld_fun(varargin)
    curr_val=ceil(get(sld_bar,'Value'));
    set(resolution_z_edit,'String',num2str(curr_val));
    drawnow
    
    S=str2num(get(resolution_z_edit,'String'));
    update_dis(S)
end

function plane_rot(varargin)
    val=get(plane_sort,'Value');
    if(val==1)
        set(sld_bar,'Max',size(M,3),'Value',1);
    end
    if(val==2)
        set(sld_bar,'Max',size(M,1),'Value',1);
    end
    if(val==3)
        set(sld_bar,'Max',size(M,2),'Value',1);
    end
    set(resolution_z_edit,'String','1');
    sld_fun();
end

function update_dis(S)
    voxel_dimentions=DICOMVolume.VoxelDimensions;                               % extracting voxel dimensions
    algo='linear';                                                              % defining interpolation methods to run using loop
    plane=get(plane_sort,'Value');
    I=ComputeOrthogonalSlice_updated(algo,1,DICOMVolume,S,plane,1);
    
    
    imshow(I,'parent',axes_img_1);
    axis(axes_img_1,'off');
    drawnow
end

function reset_rot(varargin)

end

end


