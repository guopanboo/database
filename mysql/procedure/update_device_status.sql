create PROCEDURE update_device_status()
BEGIN 
	-- 设备id
	declare var_device_id VARCHAR(36);
	-- 设备类型
	declare var_type_code INT;
	-- 设备序列号
	DECLARE var_sn VARCHAR(36);
	-- 定义游标遍历时，作为判断是否遍历完全部记录的标记
  declare cur_flag integer DEFAULT 0;
	-- 定义游标，查询出逆变器的所有id, sn, type_code
	DECLARE cur CURSOR FOR select id, sn, type_code from ps_devices where del_flag = 0 and sn is not null and sn != '无';
	-- 定义游标，查询出所有洛阳愿景的采集器
	DECLARE cur_lyyj CURSOR FOR select id from ps_devices where del_flag = 0 and type_code = 6 and (vendor_id = '516aaf86-780c-4bf6-863d-bb6f437f255d' or vendor_id = '042eca7f-9dd5-41c9-8d3f-845cedb94ff1');
	-- 定义游标，查询出所有集中器
	DECLARE cur_jzq CURSOR FOR select id from ps_devices where del_flag = 0 and type_code = 8;
	-- 声明当游标遍历完全部记录后将标志变量置成某个值
	DECLARE CONTINUE HANDLER FOR NOT FOUND 
		SET cur_flag=1;
	OPEN cur;
	-- 循环
	REPEAT
		FETCH cur INTO var_device_id, var_sn, var_type_code; -- 取出一条记录
		CASE var_type_code 
			WHEN 3 THEN-- 如果type=3 是逆变器
				update collect_node n set n.online = 
					(select count(r.flag) as online from (select 1 as flag from cj_realdatas where inverterid = var_sn and creat_time > DATE_SUB(SYSDATE(),INTERVAL 30 MINUTE) limit 1) r)
				where n.DEVICE_ID = var_device_id;
			WHEN 6 THEN -- 如果type=6为采集器
				update collect_node n set n.online = 
					(select count(r.flag) as online from (select 1 as flag from collector_online_log where device_id = var_device_id and ONLINE != 0 and ctime > DATE_SUB(SYSDATE(),INTERVAL 30 MINUTE) limit 1) r)
				where n.DEVICE_ID = var_device_id;
			ELSE BEGIN END;
		END CASE;
	UNTIL cur_flag  END REPEAT;-- 循环结束
	CLOSE cur;
	-- 创建临时表
	CREATE TABLE IF NOT EXISTS temp_collect_node_online (
		id VARCHAR(36),
		online INT
	);
	SET cur_flag = 0;
	open cur_lyyj;
	REPEAT
		FETCH cur_lyyj INTO var_device_id;
		-- 更新采集器状态，判断采集器下面的所有逆变器的状态来判断采集器的状态
		INSERT into temp_collect_node_online(id, online) values(var_device_id, (select case sum(s.online) WHEN 0 then 0 ELSE 1 END  as online from collect_node s where s.device_id in (select device_partner_id from ps_device_monitors where device_child_id  = var_device_id)));
		update collect_node n set n.`ONLINE` = 
			(select online from temp_collect_node_online where id = var_device_id limit 1)
		where n.DEVICE_ID = var_device_id;
	UNTIL cur_flag END REPEAT;
	CLOSE cur_lyyj;
	SET cur_flag = 0;
	open cur_jzq;
	REPEAT
		FETCH cur_jzq INTO var_device_id;
		-- 更新集中器状态，判断集中器下面的所有采集器的状态来判断集中器的状态
		INSERT into temp_collect_node_online(id, online) values(var_device_id, (select case sum(s.online) WHEN 0 then 0 ELSE 1 END  as online from collect_node s where s.device_id in (select device_partner_id from ps_device_monitors where device_child_id  = var_device_id)));
		update collect_node n set n.`ONLINE` = 
			(select online from temp_collect_node_online where id = var_device_id limit 1)
		where n.DEVICE_ID = var_device_id;
	UNTIL cur_flag END REPEAT;
	CLOSE cur_jzq;
	-- 删除临时表
	DROP TABLE temp_collect_node_online;
END