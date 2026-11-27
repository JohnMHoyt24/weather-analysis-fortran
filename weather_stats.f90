module weather_stats
    use weather_data, only: weather_record
    ! This module contains functions to compute statistical measures for weather data.
    implicit none

    contains
    ! Compute the average temperature from an array of weather records.
    function compute_average_temperature(records) result(avg_temp)
        type(weather_record), intent(in) :: records(:)
        real :: avg_temp
        integer :: i, n

        n = size(records)
        if (n == 0) then
            avg_temp = 0.0
            return
        end if

        avg_temp = 0.0
        do i = 1, n
            avg_temp = avg_temp + records(i)%temp_c
        end do
        avg_temp = avg_temp / n
    end function compute_average_temperature

    ! Compute the average pressure from an array of weather records.
    function compute_average_pressure(records) result(avg_pressure)
        type(weather_record), intent(in) :: records(:)
        real :: avg_pressure
        integer :: i, n

        n = size(records)
        if (n == 0) then
            avg_pressure = 0.0
            return
        end if

        avg_pressure = 0.0
        do i = 1, n
            avg_pressure = avg_pressure + records(i)%pressure_hpa
        end do
        avg_pressure = avg_pressure / n
    end function compute_average_pressure

    ! Compute the average dewpoint from an array of weather records.
    function compute_average_dewpoint(records) result(avg_dewpoint)
        type(weather_record), intent(in) :: records(:)
        real :: avg_dewpoint
        integer :: i, n

        n = size(records)
        if (n == 0) then
            avg_dewpoint = 0.0
            return
        end if

        avg_dewpoint = 0.0
        do i = 1, n
            avg_dewpoint = avg_dewpoint + records(i)%dewpoint_c
        end do
        avg_dewpoint = avg_dewpoint / n
    end function compute_average_dewpoint

    ! Compute the variance of temperature from an array of weather records.
    function compute_variance_temperature(records) result(var_temp)
        type(weather_record), intent(in) :: records(:)
        real :: var_temp
        integer :: i, n
        real :: mean_temp, sum_sq_diff

        n = size(records)
        if (n == 0) then
            var_temp = 0.0
            return
        end if

        mean_temp = compute_average_temperature(records)
        sum_sq_diff = 0.0
        do i = 1, n
            sum_sq_diff = sum_sq_diff + (records(i)%temp_c - mean_temp)**2
        end do
        var_temp = sum_sq_diff / n
    end function compute_variance_temperature

    ! Compute the standard deviation of temperature from an array of weather records.
    function compute_std_dev_temperature(records) result(std_dev_temp)
        type(weather_record), intent(in) :: records(:)
        real :: std_dev_temp
        real :: var_temp

        var_temp = compute_variance_temperature(records)
        std_dev_temp = sqrt(var_temp)
    end function compute_std_dev_temperature