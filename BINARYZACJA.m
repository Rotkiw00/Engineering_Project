function [I_wyj] = BINARYZACJA(I_wej, t, redukcja_naczyn)
    if redukcja_naczyn
        I_wej = REDUKUKCJA_NACZYN(I_wej);
    else
        [R,~,~] = imsplit(I_wej);
        grayImage = .9*double(R);
        I_wej = uint8(grayImage);
    end    
    [x, y] = size(I_wej);
    I_wyj = zeros(x, y);
    for i = 1:x
        for j = 1:y
            if I_wej(i, j) > t
                I_wyj(i, j) = 255;
            else
                I_wyj(i, j) = 0;
            end
        end
    end
end