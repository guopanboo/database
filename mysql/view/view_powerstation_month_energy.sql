CREATE or replace VIEW view_powerstation_month_energy(pid, year, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, total) AS
select 
	POWERSTATION_ID as pid, 
	FLG_YEAR as year, 
	sum(if(FLG_MONTH='1', MONTH_ENERGY, 0)) as M1, 
	sum(if(FLG_MONTH='2', MONTH_ENERGY, 0)) as M2,
	sum(if(FLG_MONTH='3', MONTH_ENERGY, 0)) as M3,
	sum(if(FLG_MONTH='4', MONTH_ENERGY, 0)) as M4,
	sum(if(FLG_MONTH='5', MONTH_ENERGY, 0)) as M5,
	sum(if(FLG_MONTH='6', MONTH_ENERGY, 0)) as M6,
	sum(if(FLG_MONTH='7', MONTH_ENERGY, 0)) as M7,
	sum(if(FLG_MONTH='8', MONTH_ENERGY, 0)) as M8,
	sum(if(FLG_MONTH='9', MONTH_ENERGY, 0)) as M9,
	sum(if(FLG_MONTH='10', MONTH_ENERGY, 0)) as M10,
	sum(if(FLG_MONTH='11', MONTH_ENERGY, 0)) as M11,
	sum(if(FLG_MONTH='12', MONTH_ENERGY, 0)) as M12,
	sum(MONTH_ENERGY) as TOTAL_ENERGY
from cj_powerstation_month
group by POWERSTATION_ID, FLG_YEAR
;

select * from cj_powerstation_month 
where POWERSTATION_ID = 'f5041cd4-94db-44ea-94e8-e12a8f00ebd9' and FLG_YEAR = 2016 order by FLG_MONTH asc;


select * from view_powerstation_month_energy;