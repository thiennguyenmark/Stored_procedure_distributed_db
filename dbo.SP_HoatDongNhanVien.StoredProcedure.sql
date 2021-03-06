USE [QLVT]
GO
/****** Object:  StoredProcedure [dbo].[SP_HoatDongNhanVien]    Script Date: 12/23/2018 5:05:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_HoatDongNhanVien]
@MANV INT,			--Hoạt động của nhân viên
@NGAYBD DATE,		--Lọc chi tiết hoạt động từ ngày
@NGAYKT DATE,		--Lọc chi tiết hoạt động đến ngày
@State NVARCHAR(4)	--Lọc chi tiết theo Phiếu Nhập or Phiếu Xuất (NHAP-XUAT)
AS
BEGIN
	IF(@State = 'NHAP')
	BEGIN
		SELECT
		FORMAT(PN.NGAY,'MMMM yyyy') AS THANGNAM, --Để vào C# Group theo tháng/n
		PN.NGAY,
		CTPN.MAPN AS MAPHIEU,  --Đồng bộ cột khi SP chứa 2 câu query 2 cột MAPN,PAPX khác nhau
		N'Không có thông tin' AS HOTENKH,	   --Vì ở Phiếu Nhập ko có KH nên thêm cột giả như ở PX
		TENVT = (SELECT VT.TENVT FROM dbo.Vattu AS VT		 --Từ MAVT lọc ra được tên TENVT
				WHERE VT.MAVT = CTPN.MAVT),
		TENKHO = (SELECT 
					  (SELECT KHO.TENKHO FROM dbo.Kho AS KHO --Từ MAKHO lọc ra được TENKHO
					   WHERE KHO.MAKHO = DDH.MAKHO) 
				  FROM dbo.DatHang AS DDH					 --Từ MasoDDH lọc ra được MAKHO
				  WHERE DDH.MasoDDH = PN.MasoDDH),
		CTPN.SOLUONG,
		CTPN.DONGIA
		FROM dbo.CTPN AS CTPN
		INNER JOIN 
			(SELECT *		--Lọc các PN thỏa MANV và thời gian trước
			 FROM dbo.PhieuNhap
			 WHERE MANV = @MANV 
			 AND (NGAY BETWEEN @NGAYBD AND @NGAYKT)) AS PN
		ON PN.MAPN = CTPN.MAPN
	END
	ELSE IF(@State = 'XUAT')
	BEGIN
		SELECT
		FORMAT(PX.NGAY,'MMMM yyyy') AS THANGNAM, 
		PX.NGAY,
		CTPX.MAPX AS MAPHIEU,
		PX.HOTENKH,
		TENVT  = (SELECT VT.TENVT FROM dbo.Vattu AS VT
				  WHERE VT.MAVT = CTPX.MAVT),
		TENKHO = (SELECT  KHO.TENKHO FROM dbo.Kho AS KHO
					WHERE KHO.MAKHO = PX.MAKHO),
		CTPX.SOLUONG,
		CTPX.DONGIA
		FROM dbo.CTPX AS CTPX
		INNER JOIN
			(SELECT *		--Lọc các PN thỏa MANV và thời gian trước
			FROM dbo.PhieuXuat
			WHERE MANV = @MANV 
			AND (NGAY BETWEEN @NGAYBD AND @NGAYKT)) AS PX
		ON PX.MAPX = CTPX.MAPX
	END
END
GO
