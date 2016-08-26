create PROCEDURE update_device_status()
BEGIN 
	-- �豸id
	declare var_device_id VARCHAR(36);
	-- �豸����
	declare var_type_code INT;
	-- �豸���к�
	DECLARE var_sn VARCHAR(36);
	-- �����α����ʱ����Ϊ�ж��Ƿ������ȫ����¼�ı��
  declare cur_flag integer DEFAULT 0;
	-- �����α꣬��ѯ�������������id, sn, type_code
	DECLARE cur CURSOR FOR select id, sn, type_code from ps_devices where del_flag = 0 and sn is not null and sn != '��';
	-- �����α꣬��ѯ����������Ը���Ĳɼ���
	DECLARE cur_lyyj CURSOR FOR select id from ps_devices where del_flag = 0 and type_code = 6 and (vendor_id = '516aaf86-780c-4bf6-863d-bb6f437f255d' or vendor_id = '042eca7f-9dd5-41c9-8d3f-845cedb94ff1');
	-- �����α꣬��ѯ�����м�����
	DECLARE cur_jzq CURSOR FOR select id from ps_devices where del_flag = 0 and type_code = 8;
	-- �������α������ȫ����¼�󽫱�־�����ó�ĳ��ֵ
	DECLARE CONTINUE HANDLER FOR NOT FOUND 
		SET cur_flag=1;
	OPEN cur;
	-- ѭ��
	REPEAT
		FETCH cur INTO var_device_id, var_sn, var_type_code; -- ȡ��һ����¼
		CASE var_type_code 
			WHEN 3 THEN-- ���type=3 �������
				update collect_node n set n.online = 
					(select count(r.flag) as online from (select 1 as flag from cj_realdatas where inverterid = var_sn and creat_time > DATE_SUB(SYSDATE(),INTERVAL 30 MINUTE) limit 1) r)
				where n.DEVICE_ID = var_device_id;
			WHEN 6 THEN -- ���type=6Ϊ�ɼ���
				update collect_node n set n.online = 
					(select count(r.flag) as online from (select 1 as flag from collector_online_log where device_id = var_device_id and ONLINE != 0 and ctime > DATE_SUB(SYSDATE(),INTERVAL 30 MINUTE) limit 1) r)
				where n.DEVICE_ID = var_device_id;
			ELSE BEGIN END;
		END CASE;
	UNTIL cur_flag  END REPEAT;-- ѭ������
	CLOSE cur;
	-- ������ʱ��
	CREATE TABLE IF NOT EXISTS temp_collect_node_online (
		id VARCHAR(36),
		online INT
	);
	SET cur_flag = 0;
	open cur_lyyj;
	REPEAT
		FETCH cur_lyyj INTO var_device_id;
		-- ���²ɼ���״̬���жϲɼ�������������������״̬���жϲɼ�����״̬
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
		-- ���¼�����״̬���жϼ�������������вɼ�����״̬���жϼ�������״̬
		INSERT into temp_collect_node_online(id, online) values(var_device_id, (select case sum(s.online) WHEN 0 then 0 ELSE 1 END  as online from collect_node s where s.device_id in (select device_partner_id from ps_device_monitors where device_child_id  = var_device_id)));
		update collect_node n set n.`ONLINE` = 
			(select online from temp_collect_node_online where id = var_device_id limit 1)
		where n.DEVICE_ID = var_device_id;
	UNTIL cur_flag END REPEAT;
	CLOSE cur_jzq;
	-- ɾ����ʱ��
	DROP TABLE temp_collect_node_online;
END