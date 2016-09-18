DELIMITER $$
DROP PROCEDURE IF EXISTS `statistics_ps_data` $$
CREATE PROCEDURE statistics_ps_data()
BEGIN
-- ------------�������� start--------------------------------------------------------------------------------------------------------------
	-- ������������ս�����еļ�¼
	DECLARE var_crid VARCHAR(36);
	DECLARE var_collect_node_id VARCHAR(36);
	DECLARE var_collect_time DATETIME;
	DECLARE var_today DECIMAL(25,5);
	DECLARE var_total DECIMAL(25,5);
	DECLARE var_psid VARCHAR(36);
	-- �����������¼��,��,��
	DECLARE var_year VARCHAR(4);
	DECLARE var_month VARCHAR(2);
	DECLARE var_day VARCHAR(2);
	-- ����һ�������洢������
	DECLARE var_energy DECIMAL(25,5);
	-- ����һ���������洢һ�����֣������ж��Ƿ����
	DECLARE var_exist INTEGER DEFAULT 0;
	-- ����һ���������洢��һ�εķ�����
	DECLARE var_last DECIMAL(25,5);
	-- �����α����ʱ����Ϊ�ж��Ƿ������ȫ����¼�ı��
  DECLARE cur_flag INTEGER DEFAULT 0;
	-- ����һ����������Ϊ�Ƿ����ı��
	DECLARE t_error INTEGER DEFAULT 0;
	-- �����α꣬��ѯ��cj_inverter_data�е�100����¼�����ɼ�ʱ�䣬��վ ��������
	DECLARE cur CURSOR FOR SELECT d.CRID, d.COLLECT_NODE_ID, d.COLLECT_TIME, d.TODAY_CAPACITY, d.TOTAL_CAPACITY FROM cj_inverter_data d WHERE d.AGGREGATED = 0 ORDER BY d.COLLECT_NODE_ID, d.COLLECT_TIME ASC LIMIT 100;
	-- �������α������ȫ����¼�󽫱�־�����ó�ĳ��ֵ
	DECLARE CONTINUE HANDLER FOR NOT FOUND 
		SET cur_flag=1;
	-- ����ʱ �� t_error ���Ϊ1
  	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
-- ------------�������� end--------------------------------------------------------------------------------------------------------------

	-- ���α�
	OPEN cur;
	-- ѭ��
	REPEAT
		FETCH cur INTO var_crid, var_collect_node_id, var_collect_time, var_today, var_total; -- ȡ��һ����¼
		IF cur_flag = 0 THEN
			-- SELECT var_crid, var_collect_node_id, var_collect_time, var_today, var_total;
			SET var_year = DATE_FORMAT(var_collect_time,'%Y');
			SET var_month = DATE_FORMAT(var_collect_time,'%m');
			SET var_day = DATE_FORMAT(var_collect_time,'%d');
			-- SELECT var_year, var_month, var_day;
			-- ����collect_node_id��ѯ��վid
			SET var_psid = null;
			SELECT station_id INTO var_psid FROM collect_node WHERE collect_node_id = var_collect_node_id;
			-- SELECT var_psid;
			SET t_error = 0; -- ������������Ϊ0
			START TRANSACTION; -- ��ʼ����
	-- ------------�����ܷ����� start---------------------------------------------------------------------------------------------------------
			/*
			�Ȳ�ѯcj_powerstation_energy��һ���ɼ���ֻ��һ����¼�����У��治���ڸòɼ���ļ�¼��������ڣ�����£�
			��������ڣ�����롣���Ҽ������һ�������������һ�ε��������������Ϊ��һ�����ݵķ������������������
			����ͳ���գ��£���ʱ���մ��ڸ��²����ڲ���ķ�ʽͳ�������ա�
			*/
			-- ��ʼ������
			SET var_exist = 0;
			SET var_last = 0;
			SELECT count(*) INTO var_exist FROM cj_powerstation_energy e WHERE e.collect_node_id = var_collect_node_id;
			IF var_exist = 0 THEN -- �ж��ܼ�¼�����ڣ�����
				SET var_energy = var_total;
				INSERT INTO cj_powerstation_energy(collect_node_id, total_energy, create_time, last_modify_time) VALUES (var_collect_node_id, var_total, NOW(), NOW());
			ELSE-- ����
				SELECT e.total_energy INTO var_last FROM cj_powerstation_energy e WHERE e.collect_node_id = var_collect_node_id;
				SET var_energy = var_total - var_last; -- �����ܷ���������һ�μ�¼���ܷ�������ֵ, Ҳ�����������һ�ε�����
				IF var_energy > 0 THEN
					-- SELECT var_total;
					update cj_powerstation_energy e SET e.total_energy = var_total, e.last_modify_time = NOW() WHERE e.collect_node_id = var_collect_node_id;
				ELSE -- ������С��0 ����������Ϊ1
					SET t_error = 1;
				END IF;
			END IF;
-- ------------�����ܷ����� end-----------------------------------------------------------------------------------------------------------

			-- SELECT var_energy;-- �õ��ķ�����������
			-- SELECT t_error;
			-- ���������Ϊ0��ִ�к�������
			IF t_error = 0 THEN
	-- ------------�����շ����� start---------------------------------------------------------------------------------------------------------
				-- ��ʼ������
				SET var_exist = 0;
				SET var_last = 0;
				SELECT count(*) INTO var_exist FROM cj_powerstation_day e WHERE e.collect_node_id = var_collect_node_id AND flg_date = CONCAT(var_year,'-',var_month,'-',var_day);
				IF var_exist = 0 THEN -- �ж��ռ�¼�����ڣ�����
					SET var_last = var_energy;
					INSERT INTO cj_powerstation_day(id, powerstation_id, collect_node_id, flg_date, today_energy, total_energy, today_togrid_energy, total_togrid_energy, change_record_id, creat_time)
						VALUES (UUID(), var_psid, var_collect_node_id, CONCAT(var_year,'-',var_month,'-',var_day), var_last, var_total, var_last, var_total, var_crid, NOW());
				ELSE-- ����
					SELECT e.today_energy INTO var_last FROM cj_powerstation_day e WHERE e.collect_node_id = var_collect_node_id AND flg_date = CONCAT(var_year,'-',var_month,'-',var_day) LIMIT 1;
					SET var_last = var_last + var_energy;
					UPDATE cj_powerstation_day d SET d.TODAY_ENERGY = var_last, d.TOTAL_ENERGY = var_total, d.TODAY_TOGRID_ENERGY = var_last, d.TOTAL_TOGRID_ENERGY = var_total WHERE d.COLLECT_NODE_ID = var_collect_node_id AND flg_date = CONCAT(var_year,'-',var_month,'-',var_day);
				END IF;
	-- ------------�����շ����� end---------------------------------------------------------------------------------------------------------

	-- ------------��վʵʱ����start--------------------------------------------------------------------------------------------------------
				-- ��ʼ������
				SET var_exist = 0;
				-- ע�⣬����û�г�ʼ����󷢵�����ʹ�õ��Ǵ����շ�����ʱ������
				SELECT count(*) INTO var_exist FROM cj_powerstation_realdata where POWERSTATION_ID = var_psid;
				IF var_exist = 0 THEN -- �ж�ʵʱ��¼������
					INSERT INTO cj_powerstation_realdata(POWERSTATION_ID, IS_ONLINE, TODAY_ENERGY, TODAY_TOGRID, TOTAL_ENERGY, TOTAL_TOGRID, LAST_COLLECTION_TIME, CREAT_TIME)
						VALUES (var_psid, 1, var_last, var_last, var_total, var_total, var_collect_time, now());
				ELSE -- ���ڣ�����
					UPDATE cj_powerstation_realdata pr set pr.TODAY_ENERGY = var_last, pr.TODAY_TOGRID = var_last, pr.TOTAL_ENERGY = var_total, pr.TOTAL_TOGRID = var_total, pr.LAST_COLLECTION_TIME = var_collect_time WHERE pr.POWERSTATION_ID = var_psid;
				END IF;
	-- ------------��վʵʱ����end----------------------------------------------------------------------------------------------------------


	-- ------------�����·����� start-------------------------------------------------------------------------------------------------------
				-- ��ʼ������
				SET var_exist = 0;
				SET var_last = 0;
				SELECT count(*) INTO var_exist FROM cj_powerstation_month e WHERE e.collect_node_id = var_collect_node_id AND e.FLG_YEAR = var_year AND e.FLG_MONTH = var_month;
				IF var_exist = 0 THEN -- ��������Ϊ�գ�����
					INSERT INTO cj_powerstation_month(id, powerstation_id, collect_node_id, flg_year, flg_month, month_energy, total_energy, month_togid_energy, total_togrid_energy, change_record_id, creat_time) 
						VALUES (UUID(), var_psid, var_collect_node_id, var_year, var_month, var_energy, var_total, var_energy, var_total, var_crid, NOW());
				ELSE -- ����
					SELECT e.month_energy INTO var_last FROM cj_powerstation_month e WHERE e.collect_node_id = var_collect_node_id AND e.FLG_YEAR = var_year AND e.FLG_MONTH = var_month LIMIT 1;
					SET var_last = var_last + var_energy;
					UPDATE cj_powerstation_month d SET d.MONTH_ENERGY = var_last, d.TOTAL_ENERGY = var_total, d.MONTH_TOGID_ENERGY = var_last, d.TOTAL_TOGRID_ENERGY = var_total WHERE d.collect_node_id = var_collect_node_id AND d.FLG_YEAR = var_year AND d.FLG_MONTH = var_month;
				END IF;
	-- ------------�����·����� end---------------------------------------------------------------------------------------------------------

	-- ------------�����귢���� start-------------------------------------------------------------------------------------------------------
				-- ��ʼ������
				SET var_exist = 0;
				SET var_last = 0;
				SELECT count(*) INTO var_exist FROM cj_powerstation_year e WHERE e.collect_node_id = var_collect_node_id AND e.FLG_YEAR = var_year;
				IF var_exist = 0 THEN -- ��������Ϊ�գ�����
					INSERT INTO cj_powerstation_year(id, powerstation_id, collect_node_id, flg_year, year_energy, total_energy, year_togid_energy, total_togrid_energy, change_record_id, creat_time) 
						VALUES (UUID(), var_psid, var_collect_node_id, var_year, var_energy, var_total, var_energy, var_total, var_crid, NOW());
				ELSE -- ����
					SELECT e.YEAR_ENERGY INTO var_last FROM cj_powerstation_year e WHERE e.collect_node_id = var_collect_node_id AND e.FLG_YEAR = var_year LIMIT 1;
					SET var_last = var_last + var_energy;
					UPDATE cj_powerstation_year d SET d.YEAR_ENERGY = var_last, d.TOTAL_ENERGY = var_total, d.YEAR_TOGID_ENERGY = var_last, d.TOTAL_TOGRID_ENERGY = var_total WHERE d.collect_node_id = var_collect_node_id AND d.FLG_YEAR = var_year;
				END IF;
	-- ------------�����귢���� end---------------------------------------------------------------------------------------------------------

	-- ------------���������ʵʱ���ݱ��ͳ��״̬ start---------------------------------------------------------------------------------------
				UPDATE cj_inverter_data d SET d.AGGREGATED = 1 WHERE d.CRID = var_crid;
	-- ------------���������ʵʱ���ݱ��ͳ��״̬ end-----------------------------------------------------------------------------------------
			END IF;
	-- ------------�쳣���� start-----------------------------------------------------------------------------------------------------------
			-- SELECT t_error;
			IF t_error = 1 THEN -- �������
					ROLLBACK; -- �ع�
					-- �޸�ͳ��״̬Ϊ���������ٴ�ͳ��
					UPDATE cj_inverter_data d set d.AGGREGATED = -1 where d.CRID = var_crid;
					COMMIT;
			ELSE
					COMMIT; -- �ύ
			END IF;
	-- ------------�쳣���� end-------------------------------------------------------------------------------------------------------------
	END IF;
	UNTIL cur_flag  END REPEAT;-- ѭ������
	CLOSE cur;
END $$
DELIMITER ;