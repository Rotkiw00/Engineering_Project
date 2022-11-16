function RYSUJ_GRANICE_OD(I_wej, I_segm, granice_od, axes)
    imshow(I_wej, 'Parent', axes);
    hold( axes , 'on' )
    
    c = regionprops(I_segm, 'centroid');
    centroids = cat(1, c.Centroid);
    
    for k = 1:length(granice_od)
        
       granica = granice_od{k};
       
       plot(granica(:,2), granica(:,1), 'g', ...
           'LineWidth', 1.5, 'Parent', axes)       
       plot(centroids(:,1), centroids(:,2), 'b*', ...
           'LineWidth', 0.5, 'Parent', axes)
    end
    hold( axes , 'off' )
end

