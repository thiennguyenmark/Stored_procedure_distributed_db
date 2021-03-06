USE [QLVT]
GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteNV]    Script Date: 12/23/2018 5:05:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DeleteNV]
@MANV INT
AS
BEGIN
	DECLARE @RET INT

	UPDATE dbo.NhanVien		
	SET TrangThaiXoa = 1
	WHERE MANV = @MANV

	EXEC @RET = SP_DeleteLogin @MANV
	IF(@RET = 1)
	BEGIN
		UPDATE dbo.NhanVien				--Rollback thủ công nếu như tài khoản đang được logged in
		SET TrangThaiXoa = 0
		WHERE MANV = @MANV
		RETURN 1	--Xóa Login không thành công
	END
	ELSE IF(@RET = 2)
	BEGIN
		UPDATE dbo.NhanVien			
		SET TrangThaiXoa = 0
		WHERE MANV = @MANV
		RETURN 2	--Xóa User không thành công
	END
	RETURN 0	--Thành công
END

GO
