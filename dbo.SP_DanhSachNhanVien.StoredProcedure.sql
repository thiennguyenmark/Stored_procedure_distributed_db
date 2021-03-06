USE [QLVT]
GO
/****** Object:  StoredProcedure [dbo].[SP_DanhSachNhanVien]    Script Date: 12/23/2018 5:05:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DanhSachNhanVien]
AS
BEGIN
SELECT MANV, CONCAT(HO,' ',TEN) AS HOTEN, DIACHI, NGAYSINH, LUONG, MACN FROM dbo.NhanVien 
WHERE TrangThaiXoa = 0
ORDER BY TEN, HO ASC
END
GO
