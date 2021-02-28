if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[WOSite]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[WOSite]
GO

CREATE TABLE [dbo].[WOSite] (
	[SiteID] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SiteAcct] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SiteName] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
)
GO

alter table dbo.WOSite
	add constraint WOSite_SiteID_PK primary key clustered (SiteID)


insert into HEAT5.dbo.WOSite
values ('CIN', '822943944', 'AT&T MOBILITY')
insert into HEAT5.dbo.WOSite
values ('DVZ', '7826117-00001', 'Verizon Wireless')
insert into HEAT5.dbo.WOSite
values ('SCN', '822943944', 'AT&T Mobility')
insert into HEAT5.dbo.WOSite
values ('SVZ', '570533369-0001', 'Verizon Wireless')
insert into HEAT5.dbo.WOSite
values ('VZW', '000267478-00001', 'Verizon Wireless')

