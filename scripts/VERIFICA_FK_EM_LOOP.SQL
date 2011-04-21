rem =========================================================================
rem 
rem                     circ_fk.sql
rem 
rem     Copyright (C) Oriole Software, 1999
rem 
rem     Downloaded from http://www.oriolecorp.com
rem 
rem     This script for Oracle database administration is free software; you
rem     can redistribute it and/or modify it under the terms of the GNU General
rem     Public License as published by the Free Software Foundation; either
rem     version 2 of the License, or any later version.
rem 
rem     This script is distributed in the hope that it will be useful,
rem     but WITHOUT ANY WARRANTY; without even the implied warranty of
rem     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem     GNU General Public License for more details.
rem 
rem     You should have received a copy of the GNU General Public License
rem     along with this program; if not, write to the Free Software
rem     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
rem 
rem =========================================================================
--    List foreign keys which loop 

--    Indicates which are tables referencing directly or indirectly
--    themselves - never had problems with foreign keys during purges ?
--
set serveroutput on
declare
  type t_tabnum is
                 table of number
                 index by binary_integer;
  v_tab_looping  t_tabnum;
  v_tab_constr   t_tabnum;
  v_tab_fk       t_tabnum;
  v_tab_pk       t_tabnum;
  v_cnt          binary_integer := 1;
  i              binary_integer;
  j              binary_integer;
  v_level        number;
  cursor c_selfref is
                 select obj#, con#
                 from sys.cdef$
                 where robj#=obj#;
  cursor c_pk is select distinct rcon#, robj#
                 from sys.cdef$
                 where robj# != obj#
                   and rcon# is not null; -- can also test the type,
                                          -- but called type in V7
                                          -- and type# in V8 ...
  cursor c_ref(p_obj# in number) is
                 select level lvl, obj#, con#, robj#
                 from sys.cdef$
                 connect by obj# = prior robj#
                 start with robj# = p_obj#;
  cursor c_disp(p_con# in number) is
                 select ufk.name || '.' || ofk.name || ' -[' ||
                        co.name || ']-> ' || upk.name || '.' || opk.name ref
                 from sys.obj$ opk,
                      sys.user$ upk,
                      sys.obj$ ofk,
                      sys.user$ ufk,
                      sys.con$ co,
                      sys.cdef$ cd
                 where upk.user# = opk.owner#
                   and ufk.user# = ofk.owner#
                   and co.con# = cd.con#
                   and opk.obj# = cd.robj#
                   and ofk.obj# = cd.obj#
                   and cd.con# = p_con#; 
  v_line         varchar2(150);
  v_target_obj   number;
  e_loop         exception;
  PRAGMA EXCEPTION_INIT(e_loop, -1436);
begin
  dbms_output.enable;
  --
  --  First self references
  --
  for rec_selfref in c_selfref
  loop
    open c_disp(rec_selfref.con#);
    fetch c_disp into v_line; 
    dbms_output.put_v_line(v_line);
    close c_disp;
    v_tab_looping(v_cnt) :=  rec_selfref.obj#;
    v_cnt := v_cnt + 1;
  end loop;
  --
  --  Now indirect references - trickier
  --
  for rec_pk in c_pk
  loop
    --
    --  Check. Let CONNECT BY do the job for us and find
    --  all the tables which reference the current one.
    --
    begin
      for rec_ref in c_ref(rec_pk.robj#)
      loop
        v_tab_fk(rec_ref.lvl) := rec_ref.obj#;
        v_tab_pk(rec_ref.lvl) := rec_ref.robj#;
        v_tab_constr(rec_ref.lvl) := rec_ref.con#;
        v_level := rec_ref.lvl;
      end loop;
      v_level := 1;
    exception
      when e_loop then
         v_target_obj := v_tab_pk(v_level);
         --
         --  Already known ?
         --
         v_tab_looping(v_cnt) := v_target_obj;
         i := 1;
         while (v_tab_looping(i) <> v_target_obj)
         loop
           i := i + 1;
         end loop;
         if (i = v_cnt) -- New one
         then
           v_cnt := v_cnt + 1;
           i := 1;
           while (v_tab_fk(i) <> v_target_obj)
           loop
             i := i + 1;
           end loop;
           select u.name || '.' || o.name
           into v_line
           from sys.user$ u,
                sys.obj$ o
           where u.user# = o.owner#
             and o.obj# = v_target_obj;
           dbms_output.put_v_line(chr(10) || 'loop  for ' || v_line);
           for j in i .. v_level
           loop
             open c_disp(v_tab_constr(j));
             fetch c_disp into v_line; 
             dbms_output.put_v_line(v_line);
             close c_disp;
           end loop;
         end if;
    end;
  end loop;
end;
/


