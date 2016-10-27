create PROCEDURE update_powerstation_daily() 
BEGIN 
	-- 电站id
	DECLARE var_powerstation_id VARCHAR(36);
	-- 要更新的列名
	DECLARE var_hour INT DEFAULT 0;
	-- 定义一个变量，作为遍历时是否遍历完成的标识
	DECLARE cur_flag INTEGER DEFAULT 0;
	-- 定义游标，查询所有电站的id
	DECLARE cur CURSOR FOR select ID from ps_powerstations where DEL_FLAG = 0;
	-- 声明当游标遍历完全部记录后将标志变量置成某个值
	DECLARE CONTINUE HANDLER FOR NOT FOUND 
		SET cur_flag=1;
	-- M 加上 过去一个小时的小时 组成要更新的列名
	select date_format(date_add(now(), INTERVAL - 1 hour), '%H') into var_hour;
	OPEN cur;
	-- 循环
	REPEAT 
		FETCH cur INTO var_powerstation_id; -- 取出一条电站的id\
			CASE var_hour 
				WHEN 1 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h1, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h1 = VALUES(h1), last_modify_time = values(create_time);
				WHEN 2 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h2, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h2 = VALUES(h2), last_modify_time = values(create_time);
				WHEN 3 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h3, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h3 = VALUES(h3), last_modify_time = values(create_time);
				WHEN 4 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h4, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h4 = VALUES(h4), last_modify_time = values(create_time);
				WHEN 5 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h5, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h5 = VALUES(h5), last_modify_time = values(create_time);
				WHEN 6 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h6, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h6 = VALUES(h6), last_modify_time = values(create_time);
				WHEN 7 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h7, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h7 = VALUES(h7), last_modify_time = values(create_time);
				WHEN 8 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h8, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h8 = VALUES(h8), last_modify_time = values(create_time);
				WHEN 9 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h9, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h9 = VALUES(h9), last_modify_time = values(create_time);
				WHEN 10 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h10, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h10 = VALUES(h10), last_modify_time = values(create_time);
				WHEN 11 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h11, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h11 = VALUES(h11), last_modify_time = values(create_time);
				WHEN 12 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h12, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h12 = VALUES(h12), last_modify_time = values(create_time);
				WHEN 13 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h13, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h13 = VALUES(h13), last_modify_time = values(create_time);
				WHEN 14 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h14, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h14 = VALUES(h14), last_modify_time = values(create_time);
				WHEN 15 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h15, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h15 = VALUES(h15), last_modify_time = values(create_time);
				WHEN 16 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h16, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h16 = VALUES(h16), last_modify_time = values(create_time);
				WHEN 17 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h17, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h17 = VALUES(h17), last_modify_time = values(create_time);
				WHEN 18 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h18, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h18 = VALUES(h18), last_modify_time = values(create_time);
				WHEN 19 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h19, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h19 = VALUES(h19), last_modify_time = values(create_time);
				WHEN 20 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h20, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h20 = VALUES(h20), last_modify_time = values(create_time);
				WHEN 21 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h21, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h21 = VALUES(h21), last_modify_time = values(create_time);
				WHEN 22 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h22, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h22 = VALUES(h22), last_modify_time = values(create_time);
				WHEN 23 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h23, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h23 = VALUES(h23), last_modify_time = values(create_time);
				WHEN 0 THEN 
					insert into cj_powerstation_daily(powerstation_id, date, h24, create_time) 
						select var_powerstation_id, CURDATE(), a.ETODAY - b.ETODAY as ehour, now() from (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(now(), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1) a, (
							select ETODAY from cj_realdatas_ps 
								where POWERSTATION_ID = var_powerstation_id 
									and CREAT_TIME < STR_TO_DATE(date_format(DATE_ADD(Now(),INTERVAL -1 hour), '%Y%m%d%H0000'), '%Y%m%d%H%i%s') 
								order by creat_time DESC limit 1
						) b
						ON DUPLICATE KEY 
									UPDATE h24 = VALUES(h24), last_modify_time = values(create_time);
			ELSE BEGIN END;
		END CASE;
	UNTIL cur_flag END REPEAT;-- 循环结束
	CLOSE cur;
END