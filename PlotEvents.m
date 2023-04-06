function PlotEvents(Data)
    for i=1:length(Data)
        subplot(1,length(Data),i);
        scatter(Data(i).EventScatter(:,1),Data(i).EventScatter(:,2),3,'k','filled')
        
        xlabel('Time (samples)')
        xlim([0,Data(i).T])

        ylabel('Neuron #')
        ylim([0,Data(i).N])

    end
end
