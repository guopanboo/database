DELIMITER $$

DROP PROCEDURE IF EXISTS `queryMasterById` $$
CREATE PROCEDURE queryMasterById(IN masterId char(36))
BEGIN
	-- 定义一个变量来标识是否是电站（1是电站， 0 是区域）
	DECLARE var_is_ps INTEGER DEFAULT NULL; 
	-- 定义一个变量存储区域电站id
	DECLARE var_master_id VARCHAR(36);
	-- 定义变量存储区域名称
	DECLARE var_master_name varchar(200);
	-- 定义一个变量存储天气code
	DECLARE var_city_code VARCHAR(36);
	-- 定义游标遍历时，作为判断是否遍历完全部记录的标记
  DECLARE cur_flag INTEGER DEFAULT 0;
	-- 定义游标，根据masterId查询出下一级的区域电站里诶报
	DECLARE cur CURSOR FOR select ma.id, ma.name, ma.WEATHER_CITY_CODE, case type when 7 then 1 else 0 end as a from ps_master_areas ma where ma.ID in (select id from ps_master_areas where DEL_FLAG =0 AND PARENT_ID = masterId);
	-- 声明当游标遍历完全部记录后将标志变量置成某个值
	DECLARE CONTINUE HANDLER FOR NOT FOUND 
		SET cur_flag = 1;
	

	-- 打开游标
	OPEN cur;
	-- 循环
	REPEAT
		FETCH cur INTO var_master_id, var_master_name, var_city_code, var_is_ps; -- 取出一条记录
		IF cur_flag = 0 THEN
			-- select var_master_id, var_city_code, var_is_ps;
			IF var_is_ps = 1 THEN -- 是电站
				select 1 as is_ps, vm.ID, vm.name, vm.CAPACITY, vm.TODAY_ENERGY, vm.TOTAL_ENERGY, vm.LAST_COLLECTION_TIME, vm.PIC_PATH from view_mprw vm where vm.ID = var_master_id;
			ELSE -- 是区域
				select 0 as is_ps, var_master_id as id, var_master_name as name, count(*) as num, sum(if(LAST_COLLECTION_TIME > DATE_SUB(SYSDATE(),INTERVAL 30 MINUTE), 1, 0)) as online_num, sum(CAPACITY) as CAPACITY, sum(TODAY_ENERGY) as TODAY_ENERGY, sum(TOTAL_ENERGY) as TOTAL_ENERGY from view_mprw where ID in (select ID from ps_master_areas where pcode like CONCAT((select pcode from ps_master_areas where id = var_master_id),'%'));
			END IF;
		END IF;
	UNTIL cur_flag  END REPEAT;-- 循环结束
	CLOSE cur;
END $$
DELIMITER ;