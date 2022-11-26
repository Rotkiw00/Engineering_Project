function [bf_score, dice_coeff, jaccard_coef] = POROWNAJ_MASKI(segmented_mask, gt_mask, option) 
    
    if option == "file"
        bf_score = round(bfscore(logical(segmented_mask), logical(gt_mask)), 4) * 100;
        dice_coeff = round(dice(logical(segmented_mask), logical(gt_mask)), 4) * 100;
        jaccard_coef = round(jaccard(logical(segmented_mask), logical(gt_mask)), 4) * 100;
    end
    
    if option == "folder"
        info_segm = dir(segmented_mask);
        segmentedList = {info_segm(:).name};

        info_gt = dir(gt_mask);    
        gtList = {info_gt(:).name};    

        segmentedList(ismember(segmentedList,{'.','..','.DS_Store'}))=[];
        sg = natsort(segmentedList);
        gtList(ismember(gtList,{'.','..','.DS_Store'}))=[];
        gt = natsort(gtList);
        
        headers_coeff = {'Image', 'Sørensen-Dice[%]', 'Jaccard[%]', 'BF-Score[%]'};
        coeffs = cell(900, 4);
        for i = 1:900
            segMaskImg = imread(cat(2, segmented_mask, '/', sg{i}));
            gtMaskImg = imread(cat(2, gt_mask, '/', gt{i}));
            bf_score = round(bfscore(logical(segMaskImg), logical(gtMaskImg)), 4) * 100;
            dice_coeff = round(dice(logical(segMaskImg), logical(gtMaskImg)), 4) * 100;
            jaccard_coef = round(jaccard(logical(segMaskImg), logical(gtMaskImg)), 4) * 100;
            
            coeffs{i,1} = cat(2,num2str(i),'_fundus');
            coeffs{i,2} = num2str(dice_coeff);
            coeffs{i,3} = num2str(jaccard_coef);
            coeffs{i,4} = num2str(bf_score);
        end
        comparison_report = [headers_coeff; coeffs];
        writecell(comparison_report, '/Users/wiktorkalaga/Desktop/report.csv');
    end
end