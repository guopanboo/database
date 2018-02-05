CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `admin`@`%` 
    SQL SECURITY DEFINER
VIEW `view_ma_range` AS
    SELECT 
        `ma`.`ID` AS `id`,
        (SELECT 
                CAST(MIN(`ps1`.`LATITUDE`) AS DECIMAL (25 , 5 ))
            FROM
                (`ps_powerstations` `ps1`
                LEFT JOIN `ps_master_areas` `ma1` ON ((`ma1`.`ID` = `ps1`.`MASTER_AREA_ID`)))
            WHERE
                ((`ma1`.`PCODE` LIKE CONCAT(`ma`.`PCODE`, '%'))
                    AND (`ma1`.`TENANT_ID` = `ma`.`TENANT_ID`)
                    AND (`ps1`.`LATITUDE` IS NOT NULL)
                    AND (`ps1`.`LATITUDE` <> ''))) AS `min_lat`,
        (SELECT 
                CAST(MAX(`ps1`.`LATITUDE`) AS DECIMAL (25 , 5 ))
            FROM
                (`ps_powerstations` `ps1`
                LEFT JOIN `ps_master_areas` `ma1` ON ((`ma1`.`ID` = `ps1`.`MASTER_AREA_ID`)))
            WHERE
                ((`ma1`.`PCODE` LIKE CONCAT(`ma`.`PCODE`, '%'))
                    AND (`ma1`.`TENANT_ID` = `ma`.`TENANT_ID`)
                    AND (`ps1`.`LATITUDE` IS NOT NULL)
                    AND (`ps1`.`LATITUDE` <> ''))) AS `max_lat`,
        (SELECT 
                CAST(MIN(`ps1`.`LONGITUDE`) AS DECIMAL (25 , 5 ))
            FROM
                (`ps_powerstations` `ps1`
                LEFT JOIN `ps_master_areas` `ma1` ON ((`ma1`.`ID` = `ps1`.`MASTER_AREA_ID`)))
            WHERE
                ((`ma1`.`PCODE` LIKE CONCAT(`ma`.`PCODE`, '%'))
                    AND (`ma1`.`TENANT_ID` = `ma`.`TENANT_ID`)
                    AND (`ps1`.`LONGITUDE` IS NOT NULL)
                    AND (`ps1`.`LONGITUDE` <> ''))) AS `min_lng`,
        (SELECT 
                CAST(MAX(`ps1`.`LONGITUDE`) AS DECIMAL (25 , 5 ))
            FROM
                (`ps_powerstations` `ps1`
                LEFT JOIN `ps_master_areas` `ma1` ON ((`ma1`.`ID` = `ps1`.`MASTER_AREA_ID`)))
            WHERE
                ((`ma1`.`PCODE` LIKE CONCAT(`ma`.`PCODE`, '%'))
                    AND (`ma1`.`TENANT_ID` = `ma`.`TENANT_ID`)
                    AND (`ps1`.`LONGITUDE` IS NOT NULL)
                    AND (`ps1`.`LONGITUDE` <> ''))) AS `max_lng`
    FROM
        (`ps_master_areas` `ma`
        LEFT JOIN `ps_powerstations` `ps` ON ((`ps`.`MASTER_AREA_ID` = `ma`.`ID`)))
    WHERE
        (`ma`.`TYPE` < 7)
    ORDER BY `ma`.`TYPE` , `ma`.`NAME`
