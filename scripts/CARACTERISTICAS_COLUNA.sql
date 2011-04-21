SELECT user_tab_columns.table_name,
    user_tab_columns.column_name,
    user_tab_columns.data_type,
    user_tab_columns.data_length,
    user_tab_columns.data_precision,
    user_tab_columns.data_scale,
    user_tab_columns.nullable,
    user_tab_columns.data_default,
    
    (SELECT comments 
    FROM user_col_comments 
    WHERE user_col_comments.table_name = user_tab_columns.table_name 
    AND user_col_comments.column_name = user_tab_columns.column_name) 
FROM user_tab_columns WHERE table_name = UPPER('&tbl') ORDER BY 1,2


