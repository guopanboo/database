CREATE or replace VIEW view_powerstation_day_energy as 
select 
	d.POWERSTATION_ID as pid, 
	d.time as time, 
	sum(if(d.FLG_DATE like '%01', d.TODAY_ENERGY, 0)) as D1, 
	sum(if(d.FLG_DATE like '%02', d.TODAY_ENERGY, 0)) as D2, 
	sum(if(d.FLG_DATE like '%03', d.TODAY_ENERGY, 0)) as D3, 
	sum(if(d.FLG_DATE like '%04', d.TODAY_ENERGY, 0)) as D4, 
	sum(if(d.FLG_DATE like '%05', d.TODAY_ENERGY, 0)) as D5, 
	sum(if(d.FLG_DATE like '%06', d.TODAY_ENERGY, 0)) as D6, 
	sum(if(d.FLG_DATE like '%07', d.TODAY_ENERGY, 0)) as D7, 
	sum(if(d.FLG_DATE like '%08', d.TODAY_ENERGY, 0)) as D8, 
	sum(if(d.FLG_DATE like '%09', d.TODAY_ENERGY, 0)) as D9, 
	sum(if(d.FLG_DATE like '%10', d.TODAY_ENERGY, 0)) as D10, 
	sum(if(d.FLG_DATE like '%11', d.TODAY_ENERGY, 0)) as D11, 
	sum(if(d.FLG_DATE like '%12', d.TODAY_ENERGY, 0)) as D12, 
	sum(if(d.FLG_DATE like '%13', d.TODAY_ENERGY, 0)) as D13, 
	sum(if(d.FLG_DATE like '%14', d.TODAY_ENERGY, 0)) as D14, 
	sum(if(d.FLG_DATE like '%15', d.TODAY_ENERGY, 0)) as D15, 
	sum(if(d.FLG_DATE like '%16', d.TODAY_ENERGY, 0)) as D16, 
	sum(if(d.FLG_DATE like '%17', d.TODAY_ENERGY, 0)) as D17, 
	sum(if(d.FLG_DATE like '%18', d.TODAY_ENERGY, 0)) as D18, 
	sum(if(d.FLG_DATE like '%19', d.TODAY_ENERGY, 0)) as D19, 
	sum(if(d.FLG_DATE like '%20', d.TODAY_ENERGY, 0)) as D20, 
	sum(if(d.FLG_DATE like '%21', d.TODAY_ENERGY, 0)) as D21, 
	sum(if(d.FLG_DATE like '%22', d.TODAY_ENERGY, 0)) as D22, 
	sum(if(d.FLG_DATE like '%23', d.TODAY_ENERGY, 0)) as D23, 
	sum(if(d.FLG_DATE like '%24', d.TODAY_ENERGY, 0)) as D24, 
	sum(if(d.FLG_DATE like '%25', d.TODAY_ENERGY, 0)) as D25, 
	sum(if(d.FLG_DATE like '%26', d.TODAY_ENERGY, 0)) as D26, 
	sum(if(d.FLG_DATE like '%27', d.TODAY_ENERGY, 0)) as D27, 
	sum(if(d.FLG_DATE like '%28', d.TODAY_ENERGY, 0)) as D28, 
	sum(if(d.FLG_DATE like '%29', d.TODAY_ENERGY, 0)) as D29, 
	sum(if(d.FLG_DATE like '%30', d.TODAY_ENERGY, 0)) as D30, 
	sum(if(d.FLG_DATE like '%31', d.TODAY_ENERGY, 0)) as D31,
	sum(d.TODAY_ENERGY) as TOTAL
from view_powerstation_daily_energy d
group by d.POWERSTATION_ID, d.time;

CREATE or replace VIEW view_powerstation_daily_energy as select POWERSTATION_ID, FLG_DATE, TODAY_ENERGY, SUBSTRING(FLG_DATE,1,7) as time from cj_powerstation_day;


select *, SUBSTRING(FLG_DATE,1,7) as time from cj_powerstation_day;



select * from cj_powerstation_day where POWERSTATION_ID = '61751186-7b6d-46e8-b032-ad7779b2fd4c' 
and FLG_DATE like '2016-02%'
order by FLG_DATE asc;

select * from view_powerstation_day_energy;