function I_blur=BlurSlices(I,gamma_x,gamma_y,gamma_z,plane)

if(plane==1)
    I_blur=imgaussfilt(I,gamma_x);
end
if(plane==2)
    I_blur=imgaussfilt(I,gamma_y);
end
if(plane==3)
    I_blur=imgaussfilt(I,gamma_z);
end

end