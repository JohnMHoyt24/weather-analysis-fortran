program weather_analysis
    ! implicit none is used to enforce explicit declaration of all variables in the program.
    ! This helps prevent errors due to typos or undeclared variables.
    implicit none
    character(len=256) :: line
    integer :: station_id, year, month, day, hour, ios, n
    real :: temp_c, rel_humidity_pct, pressure_hpa, dewpoint_c, avg_dewpoint_c

    n = 0
    avg_dewpoint_c = 0.0

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
        ! Read each line using list-directed input (*), which splits on commas,
        ! so values of any width are handled correctly.
        read(10, *, iostat=ios) &
            station_id, year, month, day, hour, temp_c, rel_humidity_pct, pressure_hpa, dewpoint_c

        ! Exit the loop if end-of-file is reached; report any other read error
        if (is_iostat_end(ios)) exit
        if (ios /= 0) then
            print *, 'Error reading data row', n + 1, ' iostat =', ios
            exit
        end if

        ! Update the running average dewpoint in degrees celsius.
        n = n + 1
        avg_dewpoint_c = ((avg_dewpoint_c * (n - 1) + dewpoint_c) / n)

        ! Print the extracted data for verification
        print *, 'Station ID:', station_id
        print '(A,I4,A,I2.2,A,I2.2)', ' Date: ', year, '-', month, '-', day
        print *, 'Hour:', hour
        print *, 'Temperature (C):', temp_c
        print *, 'Relative Humidity (%):', rel_humidity_pct
        print *, 'Pressure (hPa):', pressure_hpa
        print *, 'Dewpoint (C):', dewpoint_c
        print '(A,F7.2)', ' Running Average Dewpoint (C):', avg_dewpoint_c
    end do

    close(10)

    print *
    print '(A,I0)', ' Rows read: ', n
    print '(A,F7.2)', ' Overall Average Dewpoint (C):', avg_dewpoint_c
end program weather_analysis
