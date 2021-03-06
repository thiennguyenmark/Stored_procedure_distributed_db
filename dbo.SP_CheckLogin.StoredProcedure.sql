USE [QLVT]
GO
/****** Object:  StoredProcedure [dbo].[SP_CheckLogin]    Script Date: 12/23/2018 5:05:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_CheckLogin]
  @LOGIN VARCHAR(50),
  @USER VARCHAR(50)
AS
BEGIN
	IF EXISTS(SELECT name FROM sys.server_principals 
				WHERE TYPE IN ('U', 'S', 'G')	--U: Windows Login Accounts
				AND name NOT LIKE '%##%'		--S: SQL Login Accounts
				AND name = @LOGIN)				--G: Windows Group Login Accounts
		RETURN 1	--Trùng Login
	ELSE IF EXISTS(SELECT name FROM sys.database_principals
					WHERE type_desc = 'SQL_USER'
					AND name = @USER)
		RETURN 2	--Trùng User
	RETURN 0		--Không trùng
END
GO
