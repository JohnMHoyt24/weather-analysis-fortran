program weather_analysis
    ! Bring in the record type and file reader from the weather_data module
    use weather_data, only: weather_record, read_weather_data
    use weather_stats, only: compute_average_temperature, compute_average_pressure, compute_average_dewpoint
    ! implicit none is used to enforce explicit declaration of all variables in the program.
    ! This helps prevent errors due to typos or undeclared variables.
    implicit none

    type(weather_record), allocatable :: records(:)
    integer :: i, n, ierr
    real :: avg_temp_c, avg_pressure_hpa, avg_dewpoint_c
    real :: var_temp_c, std_dev_temp_c, m2_temp_c, delta

    ! All accumulators must start at zero, otherwise they hold garbage
    avg_temp_c = 0.0
    avg_pressure_hpa = 0.0
    avg_dewpoint_c = 0.0
    m2_temp_c = 0.0

    call read_weather_data('weather_dummy_data.csv', records, n, ierr)
    if (ierr /= 0 .and. n == 0) stop 'No data read.'

    do i = 1, n
        associate (r => records(i))
            ! Running averages
            avg_pressure_hpa = avg_pressure_hpa + (r%pressure_hpa - avg_pressure_hpa) / i
            avg_dewpoint_c   = avg_dewpoint_c   + (r%dewpoint_c   - avg_dewpoint_c)   / i

            ! Welford's method: running mean and variance for temperature
            delta = r%temp_c - avg_temp_c
            avg_temp_c = avg_temp_c + delta / i
            m2_temp_c = m2_temp_c + delta * (r%temp_c - avg_temp_c)

            ! Print the extracted data for verification
            print *, 'Station ID:', r%station_id
            print '(A,I4,A,I2.2,A,I2.2)', ' Date: ', r%year, '-', r%month, '-', r%day
            print *, 'Hour:', r%hour
            print *, 'Temperature (C):', r%temp_c
            print '(A,F7.2)', ' Running Average Temperature (C):', avg_temp_c
            print *, 'Relative Humidity (%):', r%rel_humidity_pct
            print *, 'Pressure (hPa):', r%pressure_hpa
            print '(A,F8.2)', ' Running Average Pressure (hPa):', avg_pressure_hpa
            print *, 'Dewpoint (C):', r%dewpoint_c
            print '(A,F7.2)', ' Running Average Dewpoint (C):', avg_dewpoint_c
        end associate
    end do

    ! Population variance / standard deviation
    var_temp_c = 0.0
    if (n > 0) var_temp_c = m2_temp_c / n
    std_dev_temp_c = sqrt(var_temp_c)

    print *
    print '(A,I0)', ' Rows read: ', n
    print '(A,F7.2)', ' Overall Average Temperature (C):', avg_temp_c
    print '(A,F8.2)', ' Overall Average Pressure (hPa):', avg_pressure_hpa
    print '(A,F7.2)', ' Overall Average Dewpoint (C):', avg_dewpoint_c
    print '(A,F7.2)', ' Standard Deviation Temperature (C):', std_dev_temp_c
    print '(A,F7.2)', ' Variance Temperature (C):', var_temp_c
end program weather_analysis
