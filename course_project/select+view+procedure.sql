USE dtp;

SELECT r.region_name, 
	   COUNT(*) AS dtp_number,
	   SUM(c.deads_number) AS deads_number,
	   SUM(c.wounded_number) AS wounded_number
  FROM cards c
  JOIN regions r ON c.region_name = r.region_id 
 GROUP BY r.region_name; -- Основные показатели аварийности

SELECT (SELECT dtp_type_name 
	   	  FROM dtp_types dt 
	   	 WHERE dtp_type_id = dtp_type) AS dtp_type,
	   COUNT(*) AS dtp_number
  FROM cards
 GROUP BY dtp_type; 

CREATE OR REPLACE VIEW roads_stat
	AS
SELECT r.road_name,
	   COUNT(c.card_id) AS dtp_number,
	   SUM(c.deads_number) AS deads_number,
	   SUM(c.wounded_number) AS wounded_number
  FROM roads r
  JOIN dtp_info i ON r.road_id = i.road_id 
  JOIN cards c ON i.card_id = c.card_id 
 GROUP BY r.road_name
 ORDER BY dtp_number DESC, deads_number DESC, wounded_number DESC; -- Показатели аварийности по автомобильным дорогам
 
SELECT * FROM roads_stat;

CREATE OR REPLACE VIEW road_condition_stat
	AS
SELECT rc.road_condition_name,
	   COUNT(*) AS dtp_number,
	   SUM(c.deads_number) AS deads_number,
	   SUM(c.wounded_number) AS wounded_number 
  FROM roads_conditions rc 
  JOIN road_condition_connection rcc ON rc.road_condition_id = rcc.road_condition_id 
  JOIN cards c ON rcc.card_id = c.card_id
 WHERE rc.road_condition_id != 1
 GROUP BY rc.road_condition_name
 ORDER BY dtp_number DESC, deads_number DESC, wounded_number DESC; -- Показатели аварийности по НДУ
 
SELECT * FROM road_condition_stat;

   SELECT c.dtp_number,
	      CONCAT(c.dtp_date, '/', c.dtp_time) AS date_time,
	      COALESCE(r.road_name, s.street_name) AS road_street,
	      dt.dtp_type_name,
	      GROUP_CONCAT(tv.traffic_violation_name, '; ', IF(tv2.traffic_violation_name <> 'Нет нарушений', tv2.traffic_violation_name, '') SEPARATOR '; ') AS traffic_violation 
     FROM cards c  
     JOIN dtp_info di ON c.card_id = di.card_id  
LEFT JOIN roads r ON di.road_id = r.road_id
LEFT JOIN streets s ON di.street_id = s.street_id 
     JOIN dtp_types dt ON c.dtp_type = dt.dtp_type_id
     JOIN participant_info pi2 ON c.card_id = pi2.card_id
     JOIN traffic_violation tv ON pi2.direct_traffic_violation = tv.traffic_violation_id
     JOIN additional_traffic_violation_connection atvc ON pi2.participant_id = atvc.participant_id
     JOIN traffic_violation tv2 ON atvc.additional_traffic_violation = tv2.traffic_violation_id 
    WHERE pi2.direct_traffic_violation != 2
    GROUP BY c.dtp_number, date_time, road_street, dt.dtp_type_name; -- Отчет по нарушениям ПДД

DELIMITER //
DROP PROCEDURE IF EXISTS add_dtp_card //
CREATE PROCEDURE add_dtp_card(dtp_num INT, reg_name VARCHAR(255), dtp_t VARCHAR(255), 
	   dtp_d DATE, dtp_tm TIME, part_num SMALLINT, cars_num SMALLINT, deads_num SMALLINT, wounded_num SMALLINT)
	   BEGIN
		DECLARE rn, dt BIGINT;
	   	
		SELECT region_id 
	   	  INTO rn
	   	  FROM regions
	   	 WHERE region_name = reg_name
	   	 LIMIT 1;
	   	
	   	IF ISNULL(rn) 
	    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Указанный регион отсутствует в справочнике.';
	   	END IF;
	   	
	   	SELECT dtp_type_id 
	   	  INTO dt
	   	  FROM dtp_types
	   	 WHERE dtp_type_name = dtp_t
	   	 LIMIT 1;
	   	
	   	IF ISNULL(dt) 
	    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Указанный вид ДТП отсутствует в справочнике.';
	   	END IF;
	    
	    INSERT cards (dtp_number, region_name, dtp_type, dtp_date, dtp_time, 
  			   participants_number, cars_number, deads_number, wounded_number)
		VALUES (dtp_num, rn, dt, dtp_d, dtp_tm, part_num, cars_num, deads_num, wounded_num);
		
	   END// -- Процедура добавления записи в карточку ДТП
	   
CALL add_dtp_card(221787228, 'Московская область, Егорьевский район', 'Съезд с дороги', '14.10.2021', '18:44', 1, 1, 1, 0); 
	   
	   