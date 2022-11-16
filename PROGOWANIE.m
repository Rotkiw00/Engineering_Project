function [I_wyj] = PROGOWANIE(I_wej, t)
% Funkcja 'PROGOWANIE' jako parametry wejściowe przyjmuje obraz oraz
% wartość progową t. Argumentem zwracanym jest obraz poddany progowaniu
% Obraz wejściowy konwertowany jest do skali szarości.
    I_wej = rgb2gray(I_wej);
    [x, y] = size(I_wej);
    I_wyj = zeros(x, y);
    for i = 1:x
        for j = 1:y
            if I_wej(i, j) > t
                I_wyj(i, j) = I_wej(i, j);
            else
                I_wyj(i, j) = 0;
            end
        end
    end
end