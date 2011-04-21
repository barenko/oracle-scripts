rem =========================================================================
rem 
rem                     bufgets.sql
rem 
rem     Copyright (C) 1998  Oriole Software
rem 
rem     This program is free software; you can redistribute it and/or modify
rem     it under the terms of the GNU General Public License as published by
rem     the Free Software Foundation; either version 2 of the License, or
rem     any later version.
rem 
rem     This program is distributed in the hope that it will be useful,
rem     but WITHOUT ANY WARRANTY; without even the implied warranty of
rem     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem     GNU General Public License for more details.
rem 
rem     You should have received a copy of the GNU General Public License
rem     along with this program; if not, write to the Free Software
rem     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
rem 
rem =========================================================================
rem
rem    This script displays the number of (oracle) buffers accessed since
rem  the beginning of the session. By running bufgets before and immediately
rem  after a statement, you can have a fairly good idea of its cost.
rem
select sum(s.value) buffers_accessed
from v$mystat s,
     v$statname n
where n.name in ('db block gets', 'consistent gets')
  and n.statistic# = s.statistic#
/

