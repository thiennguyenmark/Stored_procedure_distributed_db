USE [QLVT]
GO
/****** Object:  StoredProcedure [dbo].[SP_CheckID]    Script Date: 12/23/2018 5:05:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CheckID]
@Code NVARCHAR(10),
@Type NVARCHAR(15)
AS
BEGIN
	--Kiểm tra Table NhanVien của server hiện tại
	IF(@Type = 'MANV')
	BEGIN
		IF EXISTS(SELECT *FROM dbo.NhanVien WHERE dbo.NhanVien.MANV = CONVERT(INT, @Code))
			RETURN 1;	--Mã NV tồn tại ở chi nhánh hiện tại
		ELSE IF EXISTS(SELECT * FROM LINK.QLVT.dbo.NhanVien AS NV WHERE NV.MANV = CONVERT(INT, @Code))
			RETURN 2;	--Mã NV tồn tại ở chi nhánh khác
	END
	ELSE IF(@Type = 'MAVT')
	BEGIN
		IF EXISTS(SELECT *FROM dbo.Vattu WHERE dbo.Vattu.MAVT = @Code)
			RETURN 1;    --Mã VT tồn tại ở chi nhánh hiện tại
	END
	ELSE IF(@Type = 'MAKHO')
	BEGIN
		IF EXISTS(SELECT *FROM dbo.Kho WHERE dbo.Kho.MAKHO = @Code)
			RETURN 1	--Mã KHO tồn tại ở chi nhánh hiện tại
		ELSE IF EXISTS(SELECT * FROM LINK.QLVT.dbo.Kho AS KHO WHERE KHO.MAKHO = @Code)
			RETURN 2	--Mã KHO tồn tại ở chi nhánh khác
	END
	ELSE IF(@Type = 'TENKHO')
	BEGIN
		IF EXISTS(SELECT *FROM dbo.Kho WHERE dbo.Kho.TENKHO = @Code)
			RETURN 1	--Tên KHO tồn tại ở chi nhánh hiện tại
		ELSE IF EXISTS(SELECT * FROM LINK.QLVT.dbo.Kho AS KHO WHERE KHO.TENKHO = @Code)
			RETURN 2	--Tên KHO tồn tại ở chi nhánh khác
	END
	ELSE IF(@Type = 'MADDH')
	BEGIN
		IF EXISTS(SELECT *FROM dbo.DatHang WHERE dbo.DatHang.MasoDDH = @Code)
			RETURN 1	--Tên Mã DDH đã tồn tại ở chi nhánh hiện tại
		ELSE IF EXISTS(SELECT * FROM LINK.QLVT.dbo.DatHang AS DDH WHERE DDH.MasoDDH = @Code)
			RETURN 2	--Tên Mã DDH tồn tại ở chi nhánh khác
	END
	ELSE IF(@Type = 'MAPN')
	BEGIN
		IF EXISTS(SELECT *FROM dbo.PhieuNhap WHERE dbo.PhieuNhap.MAPN = @Code)
			RETURN 1	--Tên Mã Phiếu Nhập đã tồn tại ở chi nhánh hiện tại
		ELSE IF EXISTS(SELECT * FROM LINK.QLVT.dbo.PhieuNhap AS PN WHERE PN.MAPN = @Code)
			RETURN 2	--Tên Mã Phiếu Nhập tồn tại ở chi nhánh khác
	END
	ELSE IF(@Type = 'MAPX')
	BEGIN
		IF EXISTS(SELECT *FROM dbo.PhieuXuat WHERE dbo.PhieuXuat.MAPX = @Code)
			RETURN 1	--Tên Mã Phiếu Xuất đã tồn tại ở chi nhánh hiện tại
		ELSE IF EXISTS(SELECT * FROM LINK.QLVT.dbo.PhieuXuat AS PX WHERE PX.MAPX = @Code)
			RETURN 2	--Tên Mã Phiếu Xuất tồn tại ở chi nhánh khác
	END
	ELSE IF(@Type = 'MANV_EXIST')
	BEGIN
		IF EXISTS(
			SELECT * FROM
			(	SELECT DH.MANV FROM dbo.DatHang AS DH
				UNION 
				SELECT PN.MANV FROM dbo.PhieuNhap AS PN
				UNION
				SELECT PX.MANV FROM dbo.PhieuXuat AS PX
			) AS NV WHERE NV.MANV = CONVERT(INT, @Code)
		)
		RETURN 1	--Tồn tại MANV ít nhất trong các bảng
	END
	ELSE IF(@Type = 'MAVT_EXIST')
	BEGIN
		IF EXISTS(
			SELECT * FROM
			(	SELECT MAVT FROM dbo.CTDDH
				UNION
				SELECT MAVT FROM LINK.QLVT.dbo.CTDDH
				UNION
				SELECT MAVT FROM dbo.CTPN
				UNION
				SELECT MAVT FROM LINK.QLVT.dbo.CTPN
				UNION
				SELECT MAVT FROM dbo.CTPX
				UNION
				SELECT MAVT FROM LINK.QLVT.dbo.CTPX
			) AS VT WHERE VT.MAVT = @Code
		)
		RETURN 1	--Tồn tại MAVT ít nhất trong các bảng
	END
	ELSE IF(@Type = 'MAKHO_EXIST')
	BEGIN
		IF EXISTS(
			SELECT * FROM
			(	SELECT MAKHO FROM dbo.DatHang
				UNION
				SELECT MAKHO FROM dbo.PhieuXuat
			) AS KHO WHERE KHO.MAKHO = @Code
		)
		RETURN 1	--Tồn tại MAKHO ít nhất trong các bảng
	END
	RETURN 0	--Không bị trùng được thêm
END
GO
