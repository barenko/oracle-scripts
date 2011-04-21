/*
--
-- PROCEDURE PARA MANDAR E-MAIL
--
CREATE OR REPLACE PROCEDURE ENVIA_EMAIL(MESSAGEM VARCHAR2, -- mensagem
RECIPIENTE VARCHAR2, -- destinatario
ASSUNTO VARCHAR2 -- assunto
) is

--
-- VARIAVEIS
--
ENVIAR VARCHAR2(50) := 'teste@eu.com.br'; -- email de quem esta enviando a mensagem
HOSTEMAIL VARCHAR2(50) := 'mail.servidoremail.com.br'; -- caminho do servidor de email
DATA VARCHAR2(255) default to_char( SYSDATE, 'dd Mon yy hh24:mi:ss' );

CONEXAO UTL_SMTP.CONNECTION; -- Abre conexao SMTP

PROCEDURE send_header(name IN VARCHAR2, header IN VARCHAR2) AS BEGIN utl_smtp.write_data(CONEXAO, name || ': ' || header || utl_tcp.CRLF);
END;

BEGIN CONEXAO := utl_smtp.open_connection (HOSTEMAIL,25); -- abrindo conexao

UTL_SMTP.HELO (CONEXAO,HOSTEMAIL); -- identificando o dominio do servidor smtp
UTL_SMTP.MAIL (CONEXAO,ENVIAR); -- quem esta mandando mensagem
UTL_SMTP.RCPT (CONEXAO,RECIPIENTE); -- quem vai receber mensagem
UTL_SMTP.OPEN_DATA (CONEXAO); -- inicia o corpo da mensagem

send_header('From', ENVIAR); -- quem esta mandando mensagem
send_header('To', RECIPIENTE); -- quem vai receber mensagem
send_header('Subject', ASSUNTO); -- assunto

UTL_SMTP.WRITE_DATA (CONEXAO,MESSAGEM); -- escreve o corpo da mensagem a ser mandada
UTL_SMTP.CLOSE_DATA (CONEXAO); -- fecha o corpo da mensagem e envia email
UTL_SMTP.QUIT (CONEXAO); -- fechando a conexao

Exception
WHEN OTHERS THEN
utl_smtp.quit (conexao);
raise_application_error(-20011,'Não foi possível enviar o e-mail devido ao seguinte erro: ' || sqlerrm);
END;
/
*/
/*
Pra testar pode ser utilizado
EXEC ENVIA_EMAIL ('teste','email@gmail.com','teste');
*/
/






CREATE OR REPLACE 
PROCEDURE p_sendmail (
      from_name     varchar2                     --'seu e-mail'
      ,to_name       varchar2                    --'e-mail'
      ,subject       varchar2                    --'Mensagem Oracle'
      ,message       varchar2                    --'Mensagem do Servidor Oracle'
      ,smtp_server   VARCHAR2   :='smtp.xpto.com.br'
      ,smtp_server_port NUMBER  :=25
)is

    v_smtp_server           varchar2(30)        :='smtp.xpto.com.br';
    v_smtp_server_port      number              := 25;
    mesg                    varchar2(32767);
    crlf                    CHAR(2)             := CHR( 13 ) || CHR( 10 );

    conn                    UTL_SMTP.CONNECTION;

begin

   -- Abrindo Conexão SMTP e HTTP
   -- ----------------------------
   conn  := utl_smtp.open_connection( v_smtp_server, v_smtp_server_port );

    -- Construindo a mensagem
    -- -----------------------
    
    mesg:=  'Date: ' || TO_CHAR( SYSDATE, 'dd Mon yy hh24:mi:ss' ) || crlf ||
            'From: <'||from_name||'>' || crlf ||
            'Subject: '||subject || crlf ||
            'To: '||to_name || crlf || crlf ||
            message;

   -- Comunicando SMTP
   -- ------------------
   utl_smtp.helo( conn, v_smtp_server );
   utl_smtp.mail( conn, from_name );
   utl_smtp.rcpt( conn, to_name );
   UTL_SMTP.data( conn, mesg );

   -- Fechando conexão SMTP
   -- -----------------------
   utl_smtp.quit( conn );

end;
