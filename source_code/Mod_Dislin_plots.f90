!****************************************************************************************
!*   :: Purpose ::                                                                      *
!*   Module offering a simplified procedure for Dislin-based x--y scatter (curve) plots *
!*   using a few preset common plot settings. Several curves/data sets can be plotted   *
!*   on the same axis system with curve-specific properties provided.                   *
!*                                                                                      *
!*  This module requires an installed and linked DISLIN graphics library                *
!*  (https://www.dislin.de/index.html). See website for details about Dislin and        *
!*  installation instructions on different platforms.                                   *
!*                                                                                      *
!*   :: Authors ::                                                                      *
!*   Andi Zuend (andreas.zuend@mcgill.ca)                                               *
!*   Dept. Atmospheric and Oceanic Sciences, McGill University                          *
!*                                                                                      *
!*   :: License ::                                                                      *
!*   This program is free software: you can redistribute it and/or modify it under the  *
!*   terms of the GNU General Public License as published by the Free Software          *
!*   Foundation, either version 3 of the License, or (at your option) any later         *
!*   version.                                                                           *
!*   The module code is distributed in the hope that it will be useful, but             *
!*   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      *
!*   FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more      *
!*   details.                                                                           *
!*   You should have received a copy of the GNU General Public License along with this  *
!*   program. If not, see <http://www.gnu.org/licenses/>.                               *
!*                                                                                      *
!*   :: List of subroutines and functions contained in this module:                     *
!*   --------------------------------------------------------------                     *
!*   -  subroutine  add_plot_xydata                                                     *
!*   -  subroutine  dislin_plot                                                         *
!*                                                                                      *
!**************************************************************************************** 
module Mod_Dislin_plots

use Mod_NumPrec, only : wp

implicit none

!type declarations and shared module data:
type, private :: xydata_type                                   
    integer,allocatable :: npoints                  !stores number of data points of a data set to be plotted
    real(wp),dimension(:),allocatable :: xval       !x coordinates of x--y data
    real(wp),dimension(:),allocatable :: yval       !y coordinates of x--y data
    real(wp),dimension(:,:),allocatable :: xerr     !error bar lengths in x-axis direction, shape (1:2, 1:size(xval)), 
                                                    !first dimension elements list: x-value minus err val, x-value plus err val
    real(wp),dimension(:,:),allocatable :: yerr     !error bar lengths in y-axis direction, shape (1:2, 1:size(yval)), 
                                                    !first dimension elements list: y-value minus err val, y-value plus err val
    character(len=75)   :: legtext                  !legend entry text for a curve
    real(wp)            :: pen_width                !pen width; typical values are between 1.0 and 9.0
    integer,dimension(3):: rgb_color                !red, green, blue values (array of 3 values each in range [0, 255])
    character(len=13)   :: line_style               !options: 'solid', 'dotted', 'dashed', 'dashed_medium'
    character(len=7)    :: plot_symb                !plot curves and/or symbols; options: 'symbols', 'curve', 'both'
    integer             :: symbol_id                !ID (number) of symbol type to be plotted (see Dislin manual)
    integer             :: symbol_size              !size of the symbols in plot coordinates
end type xydata_type                                  

!
type(xydata_type),dimension(:),allocatable,private :: xy_data     !the array dimension denotes the data set (curve) no.

!public procedures:
public :: add_plot_xydata, dislin_plot

!-----------------------------------------------------------

contains
    
    
    !****************************************************************************************
    !*   :: Purpose ::                                                                      *
    !*   Public subroutine to define the x--y data arrays and a selection of curve/symbol   *
    !*   properties for a specific data set (curve) to be added to a Dislin plot page.      *
    !*   The data will be stored in xy_data and later used within 'dislin_plot' to generate *
    !*   the plot. xy_data will be increased in the number of curves dimension with each    *
    !*   call of this subroutine (until a reset at the end of the subroutine dislin_plot)   *
    !*                                                                                      *
    !*   Note: Dislin offers many additional plot types and controls of plot properties.    *
    !*         Here we use a typically useful set of options for x--y scatter/curve plots.  *
    !*                                                                                      *
    !*   :: Authors ::                                                                      *
    !*   Andi Zuend (andreas.zuend@mcgill.ca)                                               *
    !*   Dept. Atmospheric and Oceanic Sciences, McGill University                          *
    !*                                                                                      *
    !*   -> created:        2021-06-29                                                      *
    !*   -> latest changes: 2026-11-05                                                      *
    !*                                                                                      *
    !****************************************************************************************
    subroutine add_plot_xydata(xv, yv, xverr, yverr, ltext, pen_wid, rgb_col, lstyle, &
        & plot_symb, symb_id, symb_size)
    
    implicit none
    !interface arguments:
    real(wp),dimension(:),intent(in) :: xv, yv                  !arrays of x and y values of data set to be added
    real(wp),dimension(:,:),optional,intent(in) :: xverr        !x-value error bar length, first dimension elements list: 
                                                                !1: x-value minus err val, 2: x-value plus err val
    real(wp),dimension(:,:),optional,intent(in) :: yverr        !y-value error bar length, first dimension elements list: 
                                                                !1: y-value minus err val, 2: y-value plus err val
    character(len=*),optional,intent(in) :: ltext               !legend entry text for data set
    real(wp),optional,intent(in) :: pen_wid                     !pen width; typical values are between 1.0 and 9.0
    integer,dimension(3),optional,intent(in) :: rgb_col         !color array of the 3 r,g,b values, each in range [0, 255])
    character(len=*),optional,intent(in) :: lstyle              !line style; options: 'solid', 'dotted', 'dashed', 'dashed_medium'
    character(len=*),optional,intent(in) :: plot_symb           !plot curves w/ or w/o symbols or symbols only 
                                                                !(options: 'symbols', 'curve', 'both')
    integer,optional,intent(in) :: symb_id                      !the symbol ID for dislin (15 = open circle, 5 = open diamond, 
                                                                !3 = +, 4 = X, 16 = filled square, 21 = filled circle, etc.)
    integer,optional,intent(in) :: symb_size                    !the size (height) of a symbol in plot coordinates (default: 35)
    
    !local variables:
    integer :: i, istat, k, ndset, nl, np, np_old
    logical :: is_allocated
    type(xydata_type),dimension(:),allocatable :: temp_data
    !...................................
    
    k = size(xv)
    
    !check whether a xy_data variable has been allocated already: 
    if (allocated(xy_data)) then
        is_allocated = .true.
        ndset = size(xy_data, dim=1)
        np_old = size(xy_data(1)%xval, dim=1)
        !update ndset and np (with room for 
        !data set to be added to xy_data):
        ndset = ndset + 1
        if (k > np_old) then
            nl = 112
        endif
        np = max(k, np_old)
    else
        is_allocated = .false.
        ndset = 1
        np = k
    endif
    
    allocate(temp_data(ndset), stat=istat)
    do i = 1,ndset
        allocate(temp_data(i)%xval(np), temp_data(i)%yval(np), temp_data(i)%xerr(1:2,1:np), temp_data(i)%yerr(1:2,1:np), stat=istat)
    enddo
    
    if (is_allocated) then  
        !copy the data for the first ndset-1 entries 
        !to the temporary array
        temp_data(1:ndset-1) = xy_data(1:ndset-1)
    endif
    
    !move the data into an enlarged xy_data 
    !using memory-friendly move_alloc:
    call move_alloc(from = temp_data, to = xy_data)             !note: temp_data will be deallocated after this call
    
    !finally add the new data set to xy_data, including 
    !accounting for optional arguments:
    xy_data(ndset)%npoints = k
    
    xy_data(ndset)%xval(1:k) = xv(1:k)
    xy_data(ndset)%yval(1:k) = yv(1:k)
    
    if (present(xverr)) then
        xy_data(ndset)%xerr(1:2,1:k) = xverr(1:2,1:k)
    else
        xy_data(ndset)%xerr = 0.0_wp                            !default is error bar of zero length (then not shown)   
    endif
    
    if (present(yverr)) then
        xy_data(ndset)%yerr(1:2,1:k) = yverr(1:2,1:k)
    else
        xy_data(ndset)%yerr = 0.0_wp    
    endif
    
    xy_data(ndset)%legtext = ''                                 !initialize whole string
    if (present(ltext)) then
        nl = min(75, len_trim(ltext))                           !limit legend line entry to max. 75 characters
        xy_data(ndset)%legtext(1:nl) = ltext(1:nl)
    endif
    
    if (present(pen_wid)) then
        xy_data(ndset)%pen_width = pen_wid
    else    
        xy_data(ndset)%pen_width = 1.0_wp                       !set a default value
    endif
    
    if (present(rgb_col)) then
        xy_data(ndset)%rgb_color(1:3) = rgb_col(1:3)
    else
        xy_data(ndset)%rgb_color(1:3) = [0, 0, 0]               !default (black)
    endif
    
    if (present(lstyle)) then
        xy_data(ndset)%line_style = ''
        nl = min(75, len_trim(lstyle))
        xy_data(ndset)%line_style(1:nl) = lstyle(1:nl)
    else
        xy_data(ndset)%line_style = 'solid'
    endif
    
    if (present(plot_symb)) then
        xy_data(ndset)%plot_symb = ''
        nl = min(75, len_trim(plot_symb))
        xy_data(ndset)%plot_symb(1:nl) = plot_symb(1:nl)
    else
        xy_data(ndset)%plot_symb = 'curve'
    endif
    
    if (present(symb_id)) then
        xy_data(ndset)%symbol_id = symb_id
    else
        xy_data(ndset)%symbol_id = 15
    endif
    
    if (present(symb_size)) then
        xy_data(ndset)%symbol_size = symb_size
    else
        xy_data(ndset)%symbol_size = 35
    endif
    
    
    end subroutine add_plot_xydata
    !-----------------------------------------------------------
    
    
    
    !****************************************************************************************
    !*   :: Purpose ::                                                                      *
    !*   Public subroutine to generate a x--y scatter plot with the previously loaded data  *
    !*   (via calls to subroutine 'add_plot_xydata'                                         *
    !*                                                                                      *
    !*   Note: Dislin offers many additional plot types and controls of plot properties.    *
    !*         Here we use a typically useful set of options for x--y scatter plots.        *
    !*                                                                                      *
    !*   :: Authors ::                                                                      *
    !*   Andi Zuend (andreas.zuend@mcgill.ca)                                               *
    !*   Dept. Atmospheric and Oceanic Sciences, McGill University                          *
    !*                                                                                      *
    !*   -> created:        2021-06-29                                                      *
    !*   -> latest changes: 2026-11-05                                                      *
    !*                                                                                      *
    !****************************************************************************************
    subroutine dislin_plot(xlabel, ylabel, yaxis_mod, xaxis_limits, yaxis_limits, &
        & legend_position, metafile, out_file_name)

    implicit none
    !interface arguments:
    character(len=*),intent(in) :: xlabel, ylabel       !text for axis labels;
    real(wp),intent(in) :: yaxis_mod                    !set scaling of default length of y-axis on graph 
                                                        !(e.g. 0.5 indicates a plot height of half the x-axis length);
    real(wp),dimension(2),optional,intent(in) :: &
        & xaxis_limits, yaxis_limits                    !(optional) targeted x-axis and y-axis limits for plot;
    integer,intent(in) :: legend_position               !legend position value options:
                                                        != 0 for no legend
                                                        != 1 is the lower left corner of the page.
                                                        != 2 is the lower right corner of the page.
                                                        != 3 is the upper right corner of the page.
                                                        != 4 is the upper left corner of the page.
                                                        != 5 is the lower left corner of the axis system.
                                                        != 6 is the lower right corner of the axis system.
                                                        != 7 is the upper right corner of the axis system.
                                                        != 8 is the upper left corner of the axis system.
    character(len=*),intent(in) :: metafile             !typically set as 'xwin', 'cons', 'pdf' or two plots via 
                                                        !'cons, pdf', 'xwin, pdf' (one to screen, one to file)
    character(len=*),intent(in) :: out_file_name        !relative path/file name of output file (e.g. for a .pdf file, 
                                                        !without stating file extension);
    
    !local variables:
    character(len=:),allocatable :: cbuff
    character(len=:),allocatable :: meta_file_kind
    integer,parameter :: dp = kind(1.0D0)               !use this real kind with the double precision version of Dislin.
    integer :: i, istat, iplot, ndig, ndsets, npts, nxl, nyl, nzl, nplots
    real(dp) :: xaxis_min, xaxis_max, yaxis_min, yaxis_max, axis_range, temp, &
        & xa, xe, xor, xstep, ya, ye, yor, ystep
    real(dp),dimension(:),allocatable :: e1ray, e2ray
    logical :: invert_xaxis, invert_yaxis
    !the external Dislin procedures (available via linked static library):
    external :: metafl, scrmod, disini, pagfll, setclr, psfont, chaspc, height, hwfont, &
        & texmod, name, setscl, graf, incmrk, labdig, legini, leglin, legend, lncap, dot, &
        & dash, dashm, solid, penwid, color, curve, setrgb, endgrf, disfin, setfil, filmod, &
        & legtit, frame, linesp, getlen, axslen, psmode, marker, nochek, gaxpar, errbar, &
        & bartyp, errmod, hsymbl   
    !...............................................
    
    !The object xy_data contains stored data for a curve or for several curves, 
    !including curve color, thickness, legend text entry, etc.
    
    ndsets = size(xy_data)                                 !number of data sets
    allocate(character(len=75*min(ndsets, 30)) :: cbuff)
    
    select case(metafile)
    case('cons, pdf', 'xwin, pdf')
        nplots = 2
    case default
        nplots = 1
    end select

    do iplot = 1, nplots
        select case(iplot)
        case(1)
            meta_file_kind = metafile( 1:min(4, len_trim(metafile)) )
        case(2)
            meta_file_kind = 'pdf'
        end select
        call metafl(meta_file_kind)       
        call setfil(trim(out_file_name)//'.'//trim(meta_file_kind))
        call filmod('delete')                               !overwrite if file already exists                
        call scrmod('norev')
        call disini
        call pagfll(255)                                    !set page background color to white
        if (trim(meta_file_kind) == 'pdf') then
            call psfont('Helvetica')                        !for 'pdf' use a postscript font; e.g. 'Times-Roman' or 'Helvetica'
            call psmode('both')                             !allow both Greek and italic modes
        else
            call hwfont()                                   !use a hardware font; choice depends on operating system
        endif
        call chaspc(-0.06_dp)                               !slightly adjust character spacing
        call texmod('on')                                   !allow for TeX-style statments in figure text 
        call color('black')                                 !set text/axis/curve color by name

        !potentially modify axis system properties
        call getlen(nxl, nyl, nzl)
        nxl = ceiling(0.8_dp*nxl)
        call axslen(nxl, ceiling(nxl*yaxis_mod))            !modify the aspect ratio of the axis system via y-axis scaling

        !set axis system properties
        call name(trim(xlabel), 'X')                        !set x-axis label text
        call name(trim(ylabel), 'Y')
    
        invert_xaxis = .false.
        if (present(xaxis_limits)) then
            xaxis_min = xaxis_limits(1)  
            xaxis_max = xaxis_limits(2) 
            if (xaxis_min > xaxis_max) then
                invert_xaxis = .true.
            endif
        else
            !set automatic scaling for x-axis and y-axis based on slightly scaled input ranges:
            xaxis_min = minval( [( minval(xy_data(i)%xval(1:xy_data(i)%npoints)), i=1,ndsets )] )
            xaxis_max = maxval( [( maxval(xy_data(i)%xval(1:xy_data(i)%npoints)), i=1,ndsets )] )
        endif
        
        axis_range = abs(xaxis_max - xaxis_min)
        if (invert_xaxis) then
            temp = xaxis_min
            xaxis_min = xaxis_max
            xaxis_max = temp
        endif
        xaxis_min = xaxis_min -0.008_dp*axis_range
        xaxis_max = xaxis_max +0.008_dp*axis_range
    
        invert_yaxis = .false.    
        if (present(yaxis_limits)) then
            yaxis_min = yaxis_limits(1)  
            yaxis_max = yaxis_limits(2) 
            if (yaxis_min > yaxis_max) then
                invert_yaxis = .true.
            endif  
        else
            yaxis_min = minval( [( minval( xy_data(i)%yval(1:xy_data(i)%npoints)), i=1,ndsets )] ) 
            yaxis_max = maxval( [( maxval( xy_data(i)%yval(1:xy_data(i)%npoints)), i=1,ndsets )] ) 
        endif
        
        axis_range = abs(yaxis_max - yaxis_min)
        if (invert_yaxis) then
            temp = yaxis_min
            yaxis_min = yaxis_max   
            yaxis_max = temp
        endif
        yaxis_min = yaxis_min -(0.015_dp/yaxis_mod)*axis_range
        yaxis_max = yaxis_max +(0.015_dp/yaxis_mod)*axis_range
    
        !initialize graph axis system 
        !(using automatic scaling):
        ndig = -2                                               !set as -2 so dislin determines displayed digits automatically
        call nochek()                                           !suppress warning about points outside of the plotting area
        if (invert_xaxis) then
            call gaxpar(xaxis_max, xaxis_min, 'noextend', 'x', xa, xe, xor, xstep, ndig)
        else
            call gaxpar(xaxis_min, xaxis_max, 'noextend', 'x', xa, xe, xor, xstep, ndig)
        endif
        call labdig(ndig, 'x')
        
        ndig = -2
        if (invert_yaxis) then
            call gaxpar(yaxis_max, yaxis_min, 'noextend', 'y', ya, ye, yor, ystep, ndig)
        else
            call gaxpar(yaxis_min, yaxis_max, 'noextend', 'y', ya, ye, yor, ystep, ndig)
        endif
        call labdig(ndig, 'y')
        
        call graf(xa, xe, xor, xstep, ya, ye, yor, ystep)
        
        call legini(cbuff, min(ndsets, 30), 75)                 !initialize legend
    
        !plot x--y data for all curves/symbols 
        !with the curve-specific properties:
        do i = 1,ndsets
            npts = xy_data(i)%npoints
            
            !select plotting of only symbols, only curves, or both:
            select case( trim(xy_data(i)%plot_symb) )
            case('curve')
                call incmrk(0)
            case('symbols')
                call incmrk(-1)    
                call marker(xy_data(i)%symbol_id)
                call hsymbl(xy_data(i)%symbol_size) 
            case('both')
                call incmrk(1)        
                call marker(xy_data(i)%symbol_id)
                call hsymbl(xy_data(i)%symbol_size)                       
            case default
                call incmrk(0)              
            end select
            
            !select line style:
            select case( trim(xy_data(i)%line_style) )
            case('solid')
                call lncap('long')
                call solid()
            case('dotted')
                call lncap('round')                             !rounded line caps
                call dot()                             
            case('dashed')  
                call lncap('round')
                call dash()                          
            case('dashed_medium')
                call lncap('cut')
                call dashm()                              
            case default                                        !solid line style
                call lncap('long')
                call solid()            
            end select
            
            call penwid(real(xy_data(i)%pen_width, kind=dp))    !set pen / curve width (especially for pdf output) 
            
            call setrgb(xy_data(i)%rgb_color(1)/255.0_dp, &
                      & xy_data(i)%rgb_color(2)/255.0_dp, &
                      & xy_data(i)%rgb_color(3)/255.0_dp)       !set color by RGB value
            
            call leglin(cbuff, xy_data(i)%legtext, i)
            
            call curve(real(xy_data(i)%xval(1:npts), kind=dp), real(xy_data(i)%yval(1:npts), kind=dp), npts)
            
            !show x-value error bars if present as nonzero values:
            if (any(xy_data(i)%xerr > 0.0_wp)) then
                !set pen width for thickness of error bars: 
                call penwid(real(max(0.1_wp*xy_data(i)%pen_width, 0.2_wp), kind=dp)) 
                call solid()                                        !error bars as solid lines
                call errmod('check', 'off')
                call marker(-1)                                     !don't plot the symbol again (already done above)
                !draw horizontal (x-axis) error bars:
                e1ray = real(xy_data(i)%xerr(1,1:npts), kind=dp)    !error bar length for (x-value to x-value - e1ray) bars
                e2ray = real(xy_data(i)%xerr(2,1:npts), kind=dp)    !error bar length for (x-value to x-value + e2ray) bars
                if (any(e1ray(1:npts) > 0.0_dp) .or. any(e2ray(1:npts) > 0.0_dp)) then
                    call bartyp('hori')
                    call errbar(real(xy_data(i)%xval(1:npts), kind=dp), &
                        & real(xy_data(i)%yval(1:npts), kind=dp), &
                        & e1ray(1:npts), e2ray(1:npts), npts)
                endif
            endif
            
            !analogous for y-value error bars:
            if (any(xy_data(i)%yerr > 0.0_wp)) then
                !set pen width for thickness of error bars: 
                call penwid(real(max(0.1_wp*xy_data(i)%pen_width, 0.2_wp), kind=dp)) 
                call solid()
                call errmod('check', 'off')
                call marker(-1)
                !draw vertical (y-axis) error bars:
                e1ray = real(xy_data(i)%yerr(1,1:npts), kind=dp)    !error bar length for (y-value to y-value - e1ray) bars
                e2ray = real(xy_data(i)%yerr(2,1:npts), kind=dp)    !error bar length for (y-value to y-value + e2ray) bars
                if (any(e1ray(1:npts) > 0.0_dp) .or. any(e2ray(1:npts) > 0.0_dp)) then
                    call bartyp('vert')
                    call errbar(real(xy_data(i)%xval(1:npts), kind=dp), &
                        & real(xy_data(i)%yval(1:npts), kind=dp), &
                        & e1ray(1:npts), e2ray(1:npts), npts)
                endif
            endif
            
        enddo
    
        !plot legend and finalize plot:
        if (legend_position /= 0) then
            call height(26)                                 !set font size (height) for legend
            call color('black')
            call penwid(1.0_dp)  
            call legtit('')                             
            call frame(1)                                   !set legend frame thickness
            call linesp(2.0_dp)                             !modify line spacing of legend entries
            call legend(cbuff, legend_position)             !plot legend; e.g. 3 = position at upper right corner of page; 
                                                            !4 = upper left of page; 8 = upper left of axis system        
        endif
        call endgrf
        call disfin
    enddo !iplot
    
    deallocate(cbuff)
    !deallocate xy_data content so the next plot is not including current data:
    deallocate(xy_data, stat=istat)    

    end subroutine dislin_plot
    !------------------------------------------------------------ 
    
end module Mod_Dislin_plots