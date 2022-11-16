function [I_wyj] = SEGMENTACJA_OD(I_wej, elem_str)
    I_fill = WYPELNIENIE(I_wej, 'holes');
    I_nobord = imclearborder(I_fill, 8);
    seD = strel(elem_str, 1);
    I_wyj = EROZJA(I_nobord,seD);
    I_wyj = EROZJA(I_wyj,seD);
end

