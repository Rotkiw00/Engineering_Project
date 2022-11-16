function [I_wyj] = KONTUR(I_wej, metoda_kr, wsp_wyg)
    [~, prog] = edge(I_wej, metoda_kr);
    I_kr = edge(I_wej, metoda_kr, prog * wsp_wyg);
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    I_wyj = DYLATACJA(I_kr,[se90 se0]);
end

