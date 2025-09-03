function CreateSaveDir(cell_path, cell_type, cell_number)

    if ~exist("saved data", 'dir')
        mkdir("saved data")
    end
    cd 'saved data'
    if ~exist(cell_type, 'dir')
        mkdir(cell_type);
    end
    cd (cell_type);
    if ~exist(cell_number, 'dir')
        mkdir(cell_number);
    end
    cd (cell_number);

end