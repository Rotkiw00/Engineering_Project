function [t_lvl] = WYZNACZ_PROG(I_rgb)
    I_thr = rgb2gray(I_rgb);
    t_lvl = round(graythresh(I_thr)*1000);
    if t_lvl >= 220
        t_lvl = 215;
    elseif t_lvl <= 130
        t_lvl = t_lvl + 30;
    elseif t_lvl <= 100
        t_lvl = t_lvl + 20;
    end
end

