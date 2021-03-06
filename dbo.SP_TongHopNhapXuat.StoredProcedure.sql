USE [QLVT]
GO
/****** Object:  StoredProcedure [dbo].[SP_TongHopNhapXuat]    Script Date: 12/23/2019 5:05:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_TongHopNhapXuat]
@NGAYBD DATE, @NGAYKT DATE
AS
BEGIN
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END
	--Nếu Bảng tạm đã tồn tại thì xóa bảng tạm đó đi
	IF EXISTS(SELECT *FROM tempdb.sys.tables
				WHERE name LIKE '#PNTemp%') DROP TABLE #PNTemp
	IF EXISTS(SELECT *FROM tempdb.sys.tables
				WHERE name LIKE '#PXTemp%') DROP TABLE #PXTemp

	--Lưu danh sách Phiếu Nhập, Phiếu Xuất trong khoảng thời gian vào Bảng tạm
	SELECT PN.MAPN, PN.NGAY INTO #PNTemp
	FROM dbo.PhieuNhap AS PN
	WHERE PN.NGAY BETWEEN @NGAYBD AND @NGAYKT

	SELECT PX.MAPX, PX.NGAY INTO #PXTemp
	FROM dbo.PhieuXuat AS PX
	WHERE PX.NGAY BETWEEN @NGAYBD AND @NGAYKT

	--Lấy ra được danh sách Ngày - Nhập - Xuất lưu vào Bảng tạm
	SELECT
	ISNULL(NHAP.NGAY, XUAT.NGAY) AS NGAY,
	ISNULL(NHAP.TONGTIEN, 0) AS NHAP ,
	ISNULL(XUAT.TONGTIEN, 0) AS XUAT
	FROM
	(
		SELECT PN.NGAY, SUM(SOLUONG*DONGIA) AS TONGTIEN FROM #PNTemp AS PN
		INNER JOIN dbo.CTPN
		ON CTPN.MAPN = PN.MAPN
		GROUP BY PN.NGAY
	) AS NHAP
	FULL JOIN
	(
		SELECT PX.NGAY, SUM(SOLUONG*DONGIA) AS TONGTIEN FROM #PXTemp AS PX
		INNER JOIN dbo.CTPX
		ON CTPX.MAPX = PX.MAPX
		GROUP BY PX.NGAY
	) AS XUAT
	ON XUAT.NGAY = NHAP.NGAY
END


GO
