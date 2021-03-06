USE [QLVT]
GO
/****** Object:  StoredProcedure [dbo].[SP_BangKeChiTietNhap_Xuat]    Script Date: 12/23/2018 5:05:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_BangKeChiTietNhap_Xuat]
@NGAYBD DATE,	--Lọc Chi tiết từ ngày
@NGAYKT DATE,	--Lọc Chi tiết đến ngày
@Permissions NVARCHAR(10),  --Quyền (CONGTY: lọc của cả 2 chi nhánh.  CHINHANH,USER: Lọc trên phân mảnh hiện hành)
@State NCHAR(4)				--Lọc chi tiết theo Phiếu Nhập or Phiếu Xuất (NHAP-XUAT)
AS 
BEGIN
	IF(@Permissions = 'CONGTY')
	BEGIN
		IF(@State = 'NHAP')
		BEGIN
			--Vì name của bảng tạm SQL sẽ định danh lại tên bảng tạm(tên user đặt + physical address)
			--nên nếu dùng OBJECT_ID sẽ không tìm được nên ở đây ta dùng LIKE và %(bỏ qua hậu tố physical address)
			IF EXISTS(SELECT *FROM tempdb.sys.tables		
						WHERE name LIKE '#PhieuNhapTemp1%') DROP TABLE #PhieuNhapTemp1

			SELECT PN.MAPN, PN.NGAY INTO #PhieuNhapTemp1
			FROM (
				SELECT PN_Current.MAPN, PN_Current.NGAY FROM dbo.PhieuNhap AS PN_Current
				UNION 
				SELECT PN_Other.MAPN, PN_Other.NGAY FROM LINK.QLVT.dbo.PhieuNhap AS PN_Other
			) AS PN
			WHERE PN.NGAY BETWEEN @NGAYBD AND @NGAYKT

			SELECT 
			NGAYTHANG = FORMAT(PN.NGAY, 'MM/yyyy'), --Dùng Format vì MONTH,YEAR không có prefix 0 nên khi ORDER BY phát sinh sort sai tháng 10 11 12
			TENVT = (SELECT VT.TENVT FROM dbo.Vattu AS VT WHERE VT.MAVT = CTPN.MAVT),
			TONGSOLUONG = SUM(CTPN.SOLUONG),
			TONGDONGIA = SUM(CTPN.DONGIA * CTPN.SOLUONG)-- Bẳng tổng của SLuong*DGia trên mỗi record
			FROM #PhieuNhapTemp1 AS PN
			INNER JOIN (
						SELECT * FROM dbo.CTPN
						UNION
						SELECT * FROM LINK.QLVT.dbo.CTPN
						) AS CTPN
			ON CTPN.MAPN = PN.MAPN
			GROUP BY FORMAT(PN.NGAY, 'MM/yyyy'), CTPN.MAVT
			ORDER BY 1  --Sau khi dùng hàm FORMAT bây giờ chỉ có thể Sort theo cột và type là String
		END
		ELSE IF(@State = 'XUAT')
		BEGIN
			IF EXISTS(SELECT *FROM tempdb.sys.tables		
						WHERE name LIKE '#PhieuXuatTemp1%') DROP TABLE #PhieuXuatTemp1

			SELECT PX.MAPX, PX.NGAY INTO #PhieuXuatTemp1
			FROM (
				SELECT PX_Current.MAPX, PX_Current.NGAY FROM dbo.PhieuXuat AS PX_Current
				UNION 
				SELECT PX_Other.MAPX, PX_Other.NGAY FROM LINK.QLVT.dbo.PhieuXuat AS PX_Other
			) AS PX
			WHERE PX.NGAY BETWEEN @NGAYBD AND @NGAYKT
		
			SELECT 
			NGAYTHANG = FORMAT(PX.NGAY, 'MM/yyyy'), --Dùng Format vì MONTH,YEAR không có prefix 0 nên khi ORDER BY phát sinh sort sai tháng 10 11 12
			TENVT = (SELECT VT.TENVT FROM dbo.Vattu AS VT WHERE VT.MAVT = CTPX.MAVT),
			TONGSOLUONG = SUM(CTPX.SOLUONG),
			TONGDONGIA = SUM(CTPX.DONGIA * CTPX.SOLUONG) -- The Sum of SOLUONG*DONGIA on each record
			FROM #PhieuXuatTemp1 AS PX
			INNER JOIN (
						SELECT * FROM dbo.CTPX
						UNION
						SELECT * FROM LINK.QLVT.dbo.CTPX
						) AS CTPX
			ON CTPX.MAPX = PX.MAPX
			GROUP BY FORMAT(PX.NGAY, 'MM/yyyy'), CTPX.MAVT
			ORDER BY 1  --Sau khi dùng hàm FORMAT bây giờ chỉ có thể Sort theo cột và type là String
		END
	END
	ELSE --In case: permissions is CHINHANH or USER
	BEGIN
		IF(@State = 'NHAP')
		BEGIN
			--Vì name của bảng tạm SQL sẽ định danh lại tên bảng tạm(tên user đặt + physical address)
			--nên nếu dùng OBJECT_ID sẽ không tìm được nên ở đây ta dùng LIKE và %(bỏ qua hậu tố physical address)
			IF EXISTS(SELECT *FROM tempdb.sys.tables		
						WHERE name LIKE '#PhieuNhapTemp2%') DROP TABLE #PhieuNhapTemp2
			SELECT MAPN, NGAY INTO #PhieuNhapTemp2 FROM dbo.PhieuNhap	
			WHERE NGAY BETWEEN @NGAYBD AND @NGAYKT

			SELECT 
			NGAYTHANG = FORMAT(PN.NGAY, 'MM/yyyy'), --Dùng Format vì MONTH,YEAR không có prefix 0 nên khi ORDER BY phát sinh sort sai tháng 10 11 12
			TENVT = (SELECT VT.TENVT FROM dbo.Vattu AS VT WHERE VT.MAVT = CTPN.MAVT),
			TONGSOLUONG = SUM(CTPN.SOLUONG),
			TONGDONGIA = SUM(CTPN.DONGIA * CTPN.SOLUONG) -- Bẳng tổng của SLuong*DGia trên mỗi record
			FROM #PhieuNhapTemp2 AS PN
			INNER JOIN dbo.CTPN AS CTPN
			ON CTPN.MAPN = PN.MAPN
			GROUP BY FORMAT(PN.NGAY, 'MM/yyyy'), CTPN.MAVT	
			ORDER BY 1  --Sau khi dùng hàm FORMAT bây giờ chỉ có thể Sort theo cột và type là String
		END
		ELSE IF(@State = 'XUAT')
		BEGIN
			IF EXISTS(SELECT *FROM tempdb.sys.tables		
						WHERE name LIKE '#PhieuXuatTemp2%') DROP TABLE #PhieuXuatTemp2
			SELECT MAPX, NGAY INTO #PhieuXuatTemp2 FROM dbo.PhieuXuat
			WHERE NGAY BETWEEN @NGAYBD AND @NGAYKT

			SELECT 
			NGAYTHANG = FORMAT(PX.NGAY, 'MM/yyyy'), --Dùng Format vì MONTH,YEAR không có prefix 0 nên khi ORDER BY phát sinh sort sai tháng 10 11 12
			TENVT = (SELECT VT.TENVT FROM dbo.Vattu AS VT WHERE VT.MAVT = CTPX.MAVT),
			TONGSOLUONG = SUM(CTPX.SOLUONG),
			TONGDONGIA = SUM(CTPX.DONGIA * CTPX.SOLUONG) -- Bẳng tổng của SLuong*DGia trên mỗi record
			FROM #PhieuXuatTemp2 AS PX
			INNER JOIN dbo.CTPX AS CTPX
			ON CTPX.MAPX = PX.MAPX
			GROUP BY FORMAT(PX.NGAY, 'MM/yyyy'), CTPX.MAVT	
			ORDER BY 1  --Sau khi dùng hàm FORMAT bây giờ chỉ có thể Sort theo cột và type là String
		END
	END
END

GO
