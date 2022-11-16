function [I_wyj] = WYPELNIENIE(I_wej, holes)
    opened = bwareaopen(I_wej, 500);
    closed = imclose(opened, ones(10));
    I_wyj = imfill(closed, holes);
end

