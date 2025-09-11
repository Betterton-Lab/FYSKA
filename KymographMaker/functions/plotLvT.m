% Plot the LvT curve with a given lvt matrix: 

function plotLvT(lvt, lvt_name, x_range, y_range, line_cl)
    figure;
    plot(lvt(:,1), lvt(:,2), '.-' ,color = line_cl);
    xlabel('Time (minutes)');
	ylabel('Spindle length (\mum)');
    xlim(x_range);
    ylim(y_range);
    exportgraphics(gcf, lvt_name);
    pause(0.5);
    close all;
end

