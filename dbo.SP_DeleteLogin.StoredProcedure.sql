USE [QLVT]
GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteLogin]    Script Date: 12/23/2018 5:05:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DeleteLogin]
@MANV INT
AS
BEGIN 
	DECLARE @USERNAME VARCHAR(10)
	DECLARE @LOGINNAME VARCHAR(30)
	DECLARE @RET INT

	SELECT @USERNAME = users.name, @LOGINNAME = logins.name 
	FROM sys.database_principals AS users
	INNER JOIN sys.server_principals AS logins
	ON logins.sid = users.sid
	WHERE users.name = CONVERT(NVARCHAR(10), @MANV)

	IF(@@ROWCOUNT <> 0)
	BEGIN
		EXEC @RET = SP_DROPLOGIN @LOGINNAME	
		IF(@RET = 1) RETURN 1

		EXEC @RET = SP_DROPUSER  @USERNAME
		IF(@RET = 1) RETURN 2
	END
	RETURN 0 --Thành công
END

GO
