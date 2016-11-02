select pd.device_id, pd.TYPE_CODE, 
	CASE 
		WHEN pd.TYPE_CODE = 3 THEN 
				(select cds.TOTAL_ENERGY from cj_device_status cds where cds.INVERTER_ID = pd.device_id)
		ELSE '134'
	end as total
from ps_devices pd 
where pd.DEL_FLAG = 0