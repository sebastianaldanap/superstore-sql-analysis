-- =============================================
-- 01_create_staging_table.sql
-- Objetivo: Documentar el schema de la tabla Superstore
-- Nota: La carga inicial se realizó con el asistente "Import Flat File" 
-- de SSMS (no con este script). Este archivo documenta el schema final 
-- resultante, con los tipos de datos ajustados manualmente durante la 
-- importación (Postal_Code como nvarchar para preservar ceros iniciales, 
-- Sales/Discount/Profit como decimal para precisión financiera).
-- =============================================

USE [Superstore]
GO
/****** Object:  Table [dbo].[Superstore]    Script Date: 3/09/2026 17:01:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Superstore](
	[Row_ID] [smallint] NULL,
	[Order_ID] [nvarchar](50) NULL,
	[Order_Date] [date] NULL,
	[Ship_Date] [date] NULL,
	[Ship_Mode] [nvarchar](50) NULL,
	[Customer_ID] [nvarchar](50) NULL,
	[Customer_Name] [nvarchar](50) NULL,
	[Segment] [nvarchar](50) NULL,
	[Country] [nvarchar](50) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[Postal_Code] [nvarchar](10) NULL,
	[Region] [nvarchar](50) NULL,
	[Product_ID] [nvarchar](50) NULL,
	[Category] [nvarchar](50) NULL,
	[Sub_Category] [nvarchar](50) NULL,
	[Product_Name] [nvarchar](150) NULL,
	[Sales] [decimal](10, 2) NULL,
	[Quantity] [tinyint] NULL,
	[Discount] [decimal](4, 2) NULL,
	[Profit] [decimal](10, 2) NULL
) ON [PRIMARY]
GO

