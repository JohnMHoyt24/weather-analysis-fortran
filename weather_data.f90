module weather_data
    implicit none
    private

    ! Public interface of this module: the record type and the reader routine
    public :: weather_record, read_weather_data

    ! One row of the CSV file
    type :: weather_record
        integer :: station_id = 0
        integer :: year = 0, month = 0, day = 0, hour = 0
        real    :: temp_c = 0.0
        real    :: rel_humidity_pct = 0.0
        real    :: pressure_hpa = 0.0
        real    :: dewpoint_c = 0.0
    end type weather_record

contains

    ! Read every data row of a weather CSV file into an allocatable array.
    ! On return, n holds the number of rows read and ierr is 0 on success.
    subroutine read_weather_data(filename, records, n, ierr)
        character(len=*), intent(in) :: filename
        type(weather_record), allocatable, intent(out) :: records(:)
        integer, intent(out) :: n, ierr

        character(len=256) :: line
        integer :: unit, ios, n_lines
        type(weather_record) :: rec

        n = 0
        ierr = 0

        ! newunit= picks a free unit number for us (no hard-coded unit 10)
        open(newunit=unit, file=filename, status='old', action='read', iostat=ios)
        if (ios /= 0) then
            print *, 'Error opening file: ', trim(filename)
            ierr = ios
            allocate(records(0))
            return
        end if

        ! First pass: count the data lines so we can size the array
        read(unit, '(A)', iostat=ios) line          ! skip header
        n_lines = 0
        do
            read(unit, '(A)', iostat=ios) line
            if (ios /= 0) exit
            if (len_trim(line) > 0) n_lines = n_lines + 1
        end do
        allocate(records(n_lines))

        ! Second pass: rewind and parse each row
        rewind(unit)
        read(unit, '(A)', iostat=ios) line          ! skip header again
        do while (n < n_lines)
            ! List-directed input (*) splits on commas, so any field width works
            read(unit, *, iostat=ios) rec%station_id, rec%year, rec%month, rec%day, &
                rec%hour, rec%temp_c, rec%rel_humidity_pct, rec%pressure_hpa, rec%dewpoint_c

            if (is_iostat_end(ios)) exit
            if (ios /= 0) then
                print *, 'Error reading data row', n + 1, ' iostat =', ios
                ierr = ios
                exit
            end if

            n = n + 1
            records(n) = rec
        end do

        close(unit)
    end subroutine read_weather_data

end module weather_data
