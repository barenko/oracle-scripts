/*******************************************************************
    EXCLUI JOBS AGENDADOS
*******************************************************************/
Begin
    For c_jobs in (SELECT * FROM user_jobs) Loop
        dbms_job.remove(c_jobs.job);
    End Loop;
    commit;
End;
/
