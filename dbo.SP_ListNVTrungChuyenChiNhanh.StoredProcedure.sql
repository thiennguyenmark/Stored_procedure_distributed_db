USE [QLVT]
GO
/****** Object:  StoredProcedure [dbo].[SP_ListNVTrungChuyenChiNhanh]    Script Date: 12/23/2018 5:05:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ListNVTrungChuyenChiNhanh]
@MANV INT
AS
BEGIN
	SELECT NV1.* FROM LINK.QLVT.dbo.NhanVien AS NV1
	INNER JOIN (SELECT *FROM dbo.NhanVien
				WHERE MANV = @MANV) AS NV2
	ON NV2.HO = NV1.HO 
	AND NV2.TEN = NV1.TEN 
	AND NV2.NGAYSINH = NV1.NGAYSINH
	WHERE NV1.TrangThaiXoa = 1
END
GO
