function [I_wyj] = REDUKUKCJA_NACZYN(I_wej)
    [R,~,~] = imsplit(I_wej);
    grayImage = .9*double(R);
    I_wej = uint8(grayImage);
    SE = strel('disk',10);
    IM2 = imdilate(I_wej,SE);
    %SE2 = strel('disk',10);
    I_wyj = imerode(IM2,SE);
end

