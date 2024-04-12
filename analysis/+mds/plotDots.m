function plotDots(coords_xy,categoryColumns,categoryColors,categoryLabels)

nCategories=size(categoryColumns,2);

if ~exist('categoryColors','var')
    categoryColors=randomColor(nCategories);
end

hold on;

for categoryI=1:nCategories
    %     coords_xy
    %     categoryColumns
    %     categoryI
    %     categoryColors
    %     coords_xy(categoryColumns(:,categoryI),1)
    %     coords_xy(categoryColumns(:,categoryI),2)
    %     categoryColors(categoryI,:)
    plot(coords_xy(logical(categoryColumns(:,categoryI)),1),coords_xy(logical(categoryColumns(:,categoryI)),2),...
         'o','MarkerFaceColor',categoryColors(categoryI,:),'MarkerEdgeColor',categoryColors(categoryI,:),'MarkerSize',7);
end

if exist('categoryLabels','var')
    xlim=get(gca,'XLim');
    ylim=get(gca,'YLim');
    yr=max(range(ylim),range(xlim)/4);
    for categoryI=1:nCategories
        % vertical
        % text(xlim(1)+0.05*range(xlim),ylim(1)+categoryI*range(ylim)/(nCategories+1),categoryLabels(categoryI),'FontWeight','bold','Color',categoryColors(categoryI,:));

        % horizontal
        text(xlim(1)+(categoryI-1+.5)*range(xlim)/nCategories,ylim(1)-0.1*yr,categoryLabels(categoryI),'FontWeight','bold','Color',categoryColors(categoryI,:),'HorizontalAlignment','Center');
    end
    % legend(categoryLabels,'Location','NorthWest');
end