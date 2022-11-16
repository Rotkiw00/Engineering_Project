function [bf_score, dice_coeff, jaccard_coef] = POROWNAJ_MASKI(segmented_mask, gt_mask, option)

    if option == "file"
        bf_score = round(bfscore(logical(segmented_mask), logical(gt_mask)), 4) * 100;
        dice_coeff = round(dice(logical(segmented_mask), logical(gt_mask)), 4) * 100;
        jaccard_coef = round(jaccard(logical(segmented_mask), logical(gt_mask)), 4) * 100;
    end
    
    if option == "folder"
        % TODO: Sprawdzić jak zapisywać do pliku .csv wartości dopasowania
        % trzeba użyć pętli, żeby przeiterować po folderze
%     info = dir(path);
%     elemslist = {info(:).name};
%     elemslist(ismember(elemslist,{'.','..','.DS_Store'}))=[];
    end
end