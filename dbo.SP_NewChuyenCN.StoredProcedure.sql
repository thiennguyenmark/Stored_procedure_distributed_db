USE [QLVT]
GO
/****** Object:  StoredProcedure [dbo].[SP_NewChuyenCN]    Script Date: 12/23/2019 5:05:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- -1: Thất Bại
--	0: Thành công khi tạo Mã NV mới
CREATE PROCEDURE [dbo].[SP_NewChuyenCN]
@MANV INT, @NEWID INT
AS
BEGIN
	SET XACT_ABORT ON
	BEGIN TRY
		BEGIN DISTRIBUTED TRANSACTION
		DECLARE @MACN NCHAR(10)				--Tìm MACN ở bên Server mới để chuẩn bị thêm dữ liệu vào
		SELECT TOP 1 @MACN = MACN FROM LINK.QLVT.dbo.ChiNhanh

		INSERT INTO LINK.QLVT.dbo.NhanVien(MANV,HO,TEN,DIACHI,NGAYSINH,LUONG,MACN,TrangThaiXoa)
		SELECT @NEWID AS MANV, HO, TEN, DIACHI, NGAYSINH, LUONG, @MACN AS MACN, 0
		FROM dbo.NhanVien
		WHERE MANV = @MANV

		UPDATE dbo.NhanVien					--Cập nhật lại Trạng thái xóa tại chi nhánh cũ
		SET TrangThaiXoa = 1
		WHERE MANV = @MANV
		IF(@@TRANCOUNT > 0)
		BEGIN
			PRINT 'Commit Success'
			COMMIT TRANSACTION
			RETURN 0	--Thành công
		END
	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT > 0)
		BEGIN
			ROLLBACK TRANSACTION
			PRINT 'Commit Failure'
			RETURN -1	--Thất bại
		END
	END CATCH
END
GO
