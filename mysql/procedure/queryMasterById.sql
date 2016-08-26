DELIMITER $$

DROP PROCEDURE IF EXISTS `queryMasterById` $$
CREATE PROCEDURE queryMasterById(IN masterId char(36))
BEGIN
	-- ����һ����������ʶ�Ƿ��ǵ�վ��1�ǵ�վ�� 0 ������
	DECLARE var_is_ps INTEGER DEFAULT NULL; 
	-- ����һ�������洢�����վid
	DECLARE var_master_id VARCHAR(36);
	-- ��������洢��������
	DECLARE var_master_name varchar(200);
	-- ����һ�������洢����code
	DECLARE var_city_code VARCHAR(36);
	-- �����α����ʱ����Ϊ�ж��Ƿ������ȫ����¼�ı��
  DECLARE cur_flag INTEGER DEFAULT 0;
	-- �����α꣬����masterId��ѯ����һ���������վ������
	DECLARE cur CURSOR FOR select ma.id, ma.name, ma.WEATHER_CITY_CODE, case type when 7 then 1 else 0 end as a from ps_master_areas ma where ma.ID in (select id from ps_master_areas where DEL_FLAG =0 AND PARENT_ID = masterId);
	-- �������α������ȫ����¼�󽫱�־�����ó�ĳ��ֵ
	DECLARE CONTINUE HANDLER FOR NOT FOUND 
		SET cur_flag = 1;
	

	-- ���α�
	OPEN cur;
	-- ѭ��
	REPEAT
		FETCH cur INTO var_master_id, var_master_name, var_city_code, var_is_ps; -- ȡ��һ����¼
		IF cur_flag = 0 THEN
			-- select var_master_id, var_city_code, var_is_ps;
			IF var_is_ps = 1 THEN -- �ǵ�վ
				select 1 as is_ps, vm.ID, vm.name, vm.CAPACITY, vm.TODAY_ENERGY, vm.TOTAL_ENERGY, vm.LAST_COLLECTION_TIME, vm.PIC_PATH from view_mprw vm where vm.ID = var_master_id;
			ELSE -- ������
				select 0 as is_ps, var_master_id as id, var_master_name as name, count(*) as num, sum(if(LAST_COLLECTION_TIME > DATE_SUB(SYSDATE(),INTERVAL 30 MINUTE), 1, 0)) as online_num, sum(CAPACITY) as CAPACITY, sum(TODAY_ENERGY) as TODAY_ENERGY, sum(TOTAL_ENERGY) as TOTAL_ENERGY from view_mprw where ID in (select ID from ps_master_areas where pcode like CONCAT((select pcode from ps_master_areas where id = var_master_id),'%'));
			END IF;
		END IF;
	UNTIL cur_flag  END REPEAT;-- ѭ������
	CLOSE cur;
END $$
DELIMITER ;