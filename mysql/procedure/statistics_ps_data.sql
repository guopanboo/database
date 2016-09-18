DELIMITER $$
DROP PROCEDURE IF EXISTS `statistics_ps_data` $$
CREATE PROCEDURE statistics_ps_data()
BEGIN
-- ------------变量声明 start--------------------------------------------------------------------------------------------------------------
	-- 定义变量来接收结果集中的记录
	DECLARE var_crid VARCHAR(36);
	DECLARE var_collect_node_id VARCHAR(36);
	DECLARE var_collect_time DATETIME;
	DECLARE var_today DECIMAL(25,5);
	DECLARE var_total DECIMAL(25,5);
	DECLARE var_psid VARCHAR(36);
	-- 定义变量来记录年,月,日
	DECLARE var_year VARCHAR(4);
	DECLARE var_month VARCHAR(2);
	DECLARE var_day VARCHAR(2);
	-- 定义一个变量存储发电量
	DECLARE var_energy DECIMAL(25,5);
	-- 定义一个变量来存储一个数字，用来判断是否存在
	DECLARE var_exist INTEGER DEFAULT 0;
	-- 定义一个变量来存储上一次的发电量
	DECLARE var_last DECIMAL(25,5);
	-- 定义游标遍历时，作为判断是否遍历完全部记录的标记
  DECLARE cur_flag INTEGER DEFAULT 0;
	-- 定义一个变量，作为是否出错的标记
	DECLARE t_error INTEGER DEFAULT 0;
	-- 定义游标，查询出cj_inverter_data中的100条记录，按采集时间，电站 升序排序
	DECLARE cur CURSOR FOR SELECT d.CRID, d.COLLECT_NODE_ID, d.COLLECT_TIME, d.TODAY_CAPACITY, d.TOTAL_CAPACITY FROM cj_inverter_data d WHERE d.AGGREGATED = 0 ORDER BY d.COLLECT_NODE_ID, d.COLLECT_TIME ASC LIMIT 100;
	-- 声明当游标遍历完全部记录后将标志变量置成某个值
	DECLARE CONTINUE HANDLER FOR NOT FOUND 
		SET cur_flag=1;
	-- 出错时 将 t_error 标记为1
  	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
-- ------------变量声明 end--------------------------------------------------------------------------------------------------------------

	-- 打开游标
	OPEN cur;
	-- 循环
	REPEAT
		FETCH cur INTO var_crid, var_collect_node_id, var_collect_time, var_today, var_total; -- 取出一条记录
		IF cur_flag = 0 THEN
			-- SELECT var_crid, var_collect_node_id, var_collect_time, var_today, var_total;
			SET var_year = DATE_FORMAT(var_collect_time,'%Y');
			SET var_month = DATE_FORMAT(var_collect_time,'%m');
			SET var_day = DATE_FORMAT(var_collect_time,'%d');
			-- SELECT var_year, var_month, var_day;
			-- 根据collect_node_id查询电站id
			SET var_psid = null;
			SELECT station_id INTO var_psid FROM collect_node WHERE collect_node_id = var_collect_node_id;
			-- SELECT var_psid;
			SET t_error = 0; -- 将错误标记设置为0
			START TRANSACTION; -- 开始事物
	-- ------------处理总发电量 start---------------------------------------------------------------------------------------------------------
			/*
			先查询cj_powerstation_energy（一个采集点只有一条记录）表中，存不存在该采集点的记录，如果存在，则更新，
			如果不存在，则插入。并且计算出这一条数据相对于上一次的增量（可以理解为这一条数据的发电量），这个增量在
			后续统计日，月，年时按照存在更新不存在插入的方式统计年月日。
			*/
			-- 初始化变量
			SET var_exist = 0;
			SET var_last = 0;
			SELECT count(*) INTO var_exist FROM cj_powerstation_energy e WHERE e.collect_node_id = var_collect_node_id;
			IF var_exist = 0 THEN -- 判断总记录不存在，插入
				SET var_energy = var_total;
				INSERT INTO cj_powerstation_energy(collect_node_id, total_energy, create_time, last_modify_time) VALUES (var_collect_node_id, var_total, NOW(), NOW());
			ELSE-- 更新
				SELECT e.total_energy INTO var_last FROM cj_powerstation_energy e WHERE e.collect_node_id = var_collect_node_id;
				SET var_energy = var_total - var_last; -- 本次总发电量与上一次记录的总发电量差值, 也就是相对于上一次的增量
				IF var_energy > 0 THEN
					-- SELECT var_total;
					update cj_powerstation_energy e SET e.total_energy = var_total, e.last_modify_time = NOW() WHERE e.collect_node_id = var_collect_node_id;
				ELSE -- 发电量小于0 将错误标记置为1
					SET t_error = 1;
				END IF;
			END IF;
-- ------------处理总发电量 end-----------------------------------------------------------------------------------------------------------

			-- SELECT var_energy;-- 得到的发电量的增量
			-- SELECT t_error;
			-- 如果错误标记为0则执行后续操作
			IF t_error = 0 THEN
	-- ------------处理日发电量 start---------------------------------------------------------------------------------------------------------
				-- 初始化变量
				SET var_exist = 0;
				SET var_last = 0;
				SELECT count(*) INTO var_exist FROM cj_powerstation_day e WHERE e.collect_node_id = var_collect_node_id AND flg_date = CONCAT(var_year,'-',var_month,'-',var_day);
				IF var_exist = 0 THEN -- 判断日记录不存在，插入
					SET var_last = var_energy;
					INSERT INTO cj_powerstation_day(id, powerstation_id, collect_node_id, flg_date, today_energy, total_energy, today_togrid_energy, total_togrid_energy, change_record_id, creat_time)
						VALUES (UUID(), var_psid, var_collect_node_id, CONCAT(var_year,'-',var_month,'-',var_day), var_last, var_total, var_last, var_total, var_crid, NOW());
				ELSE-- 更新
					SELECT e.today_energy INTO var_last FROM cj_powerstation_day e WHERE e.collect_node_id = var_collect_node_id AND flg_date = CONCAT(var_year,'-',var_month,'-',var_day) LIMIT 1;
					SET var_last = var_last + var_energy;
					UPDATE cj_powerstation_day d SET d.TODAY_ENERGY = var_last, d.TOTAL_ENERGY = var_total, d.TODAY_TOGRID_ENERGY = var_last, d.TOTAL_TOGRID_ENERGY = var_total WHERE d.COLLECT_NODE_ID = var_collect_node_id AND flg_date = CONCAT(var_year,'-',var_month,'-',var_day);
				END IF;
	-- ------------处理日发电量 end---------------------------------------------------------------------------------------------------------

	-- ------------电站实时数据start--------------------------------------------------------------------------------------------------------
				-- 初始化变量
				SET var_exist = 0;
				-- 注意，这里没有初始化最后发电量，使用的是处理日发电量时的数据
				SELECT count(*) INTO var_exist FROM cj_powerstation_realdata where POWERSTATION_ID = var_psid;
				IF var_exist = 0 THEN -- 判断实时记录不存在
					INSERT INTO cj_powerstation_realdata(POWERSTATION_ID, IS_ONLINE, TODAY_ENERGY, TODAY_TOGRID, TOTAL_ENERGY, TOTAL_TOGRID, LAST_COLLECTION_TIME, CREAT_TIME)
						VALUES (var_psid, 1, var_last, var_last, var_total, var_total, var_collect_time, now());
				ELSE -- 存在，更新
					UPDATE cj_powerstation_realdata pr set pr.TODAY_ENERGY = var_last, pr.TODAY_TOGRID = var_last, pr.TOTAL_ENERGY = var_total, pr.TOTAL_TOGRID = var_total, pr.LAST_COLLECTION_TIME = var_collect_time WHERE pr.POWERSTATION_ID = var_psid;
				END IF;
	-- ------------电站实时数据end----------------------------------------------------------------------------------------------------------


	-- ------------处理月发电量 start-------------------------------------------------------------------------------------------------------
				-- 初始化变量
				SET var_exist = 0;
				SET var_last = 0;
				SELECT count(*) INTO var_exist FROM cj_powerstation_month e WHERE e.collect_node_id = var_collect_node_id AND e.FLG_YEAR = var_year AND e.FLG_MONTH = var_month;
				IF var_exist = 0 THEN -- 当月数据为空，插入
					INSERT INTO cj_powerstation_month(id, powerstation_id, collect_node_id, flg_year, flg_month, month_energy, total_energy, month_togid_energy, total_togrid_energy, change_record_id, creat_time) 
						VALUES (UUID(), var_psid, var_collect_node_id, var_year, var_month, var_energy, var_total, var_energy, var_total, var_crid, NOW());
				ELSE -- 更新
					SELECT e.month_energy INTO var_last FROM cj_powerstation_month e WHERE e.collect_node_id = var_collect_node_id AND e.FLG_YEAR = var_year AND e.FLG_MONTH = var_month LIMIT 1;
					SET var_last = var_last + var_energy;
					UPDATE cj_powerstation_month d SET d.MONTH_ENERGY = var_last, d.TOTAL_ENERGY = var_total, d.MONTH_TOGID_ENERGY = var_last, d.TOTAL_TOGRID_ENERGY = var_total WHERE d.collect_node_id = var_collect_node_id AND d.FLG_YEAR = var_year AND d.FLG_MONTH = var_month;
				END IF;
	-- ------------处理月发电量 end---------------------------------------------------------------------------------------------------------

	-- ------------处理年发电量 start-------------------------------------------------------------------------------------------------------
				-- 初始化变量
				SET var_exist = 0;
				SET var_last = 0;
				SELECT count(*) INTO var_exist FROM cj_powerstation_year e WHERE e.collect_node_id = var_collect_node_id AND e.FLG_YEAR = var_year;
				IF var_exist = 0 THEN -- 当年数据为空，插入
					INSERT INTO cj_powerstation_year(id, powerstation_id, collect_node_id, flg_year, year_energy, total_energy, year_togid_energy, total_togrid_energy, change_record_id, creat_time) 
						VALUES (UUID(), var_psid, var_collect_node_id, var_year, var_energy, var_total, var_energy, var_total, var_crid, NOW());
				ELSE -- 更新
					SELECT e.YEAR_ENERGY INTO var_last FROM cj_powerstation_year e WHERE e.collect_node_id = var_collect_node_id AND e.FLG_YEAR = var_year LIMIT 1;
					SET var_last = var_last + var_energy;
					UPDATE cj_powerstation_year d SET d.YEAR_ENERGY = var_last, d.TOTAL_ENERGY = var_total, d.YEAR_TOGID_ENERGY = var_last, d.TOTAL_TOGRID_ENERGY = var_total WHERE d.collect_node_id = var_collect_node_id AND d.FLG_YEAR = var_year;
				END IF;
	-- ------------处理年发电量 end---------------------------------------------------------------------------------------------------------

	-- ------------更新逆变器实时数据表的统计状态 start---------------------------------------------------------------------------------------
				UPDATE cj_inverter_data d SET d.AGGREGATED = 1 WHERE d.CRID = var_crid;
	-- ------------更新逆变器实时数据表的统计状态 end-----------------------------------------------------------------------------------------
			END IF;
	-- ------------异常处理 start-----------------------------------------------------------------------------------------------------------
			-- SELECT t_error;
			IF t_error = 1 THEN -- 如果出错
					ROLLBACK; -- 回滚
					-- 修改统计状态为出错，避免再次统计
					UPDATE cj_inverter_data d set d.AGGREGATED = -1 where d.CRID = var_crid;
					COMMIT;
			ELSE
					COMMIT; -- 提交
			END IF;
	-- ------------异常处理 end-------------------------------------------------------------------------------------------------------------
	END IF;
	UNTIL cur_flag  END REPEAT;-- 循环结束
	CLOSE cur;
END $$
DELIMITER ;