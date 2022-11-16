function [granice_od] = WYZNACZ_GRANICE_OD(I_wej)
    granice_od = bwboundaries(I_wej);
end

