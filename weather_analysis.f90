program weather_analysis
    ! implicit none is used to enforce explicit declaration of all variables in the program.
    ! This helps prevent errors due to typos or undeclared variables.
    implicit none
    character(len=256) :: line
    character(len=32) :: name
    integer :: station_id, year, month, day, hour, u, ios
    real :: temp_c, rel_humidity_pct, pressure_hpa, dewpoint_c

    ! Open the input file for reading
    open(unit=10, file='weather_dummy_data.csv', status='old', action='read', iostat=ios)

    ! Check if the file was opened successfully
    if (ios /= 0) then
        print *, 'Error opening file'
        stop
    end if

    ! Skip the header line
    read(10, '(A)', iostat=ios) line

     ! Loop through the remaining rows until end-of-file (ios /= 0)
    do
        ! Read each line of the file and extract the relevant data
        read(10, '(I4, A32, I4, I2, I2, I2, F6.1, F5.1, F6.1, F5.1)', iostat=ios) &
            station_id, name, year, month, day, hour, temp_c, rel_humidity_pct, pressure_hpa, dewpoint_c

        ! Exit the loop if end-of-file is reached
        if (ios /= 0) exit

        ! Print the extracted data for verification
        print *, 'Station ID:', station_id
        print *, 'Name:', trim(name)
        print *, 'Date:', year, '-', month, '-', day
        print *, 'Hour:', hour
        print *, 'Temperature (C):', temp_c
        print *, 'Relative Humidity (%):', rel_humidity_pct
        print *, 'Pressure (hPa):', pressure_hpa
        print *, 'Dewpoint (C):', dewpoint_c
    end do

end program weather_analysis
