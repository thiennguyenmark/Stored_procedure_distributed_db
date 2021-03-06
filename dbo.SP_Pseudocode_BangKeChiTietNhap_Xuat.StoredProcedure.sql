USE [QLVT]
GO
/****** Object:  StoredProcedure [dbo].[SP_Pseudocode_BangKeChiTietNhap_Xuat]    Script Date: 12/23/2019 5:05:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_Pseudocode_BangKeChiTietNhap_Xuat]
@NGAYBD DATE,	--Lọc Chi tiết từ ngày
@NGAYKT DATE,	--Lọc Chi tiết đến ngày
@Permissions NVARCHAR(10),  --Quyền (CONGTY: lọc của cả 2 chi nhánh.  CHINHANH,USER: Lọc trên phân mảnh hiện hành)
@State NCHAR(4)				--Lọc chi tiết theo Phiếu Nhập or Phiếu Xuất (NHAP-XUAT)
AS
BEGIN
	SELECT
	NGAYTHANG = '',
	TENVT = '',
	TONGSOLUONG = '',
	TONGDONGIA = ''
END
GO
