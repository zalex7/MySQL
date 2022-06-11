-- CREATE DATABASE dtp;

-- Справочники

CREATE TABLE dtp.regions (
	   region_id SERIAL PRIMARY KEY,
	   region_name VARCHAR(255)
	   ) COMMENT = 'Муниципальные образования';

CREATE TABLE dtp.dtp_types (
	   dtp_type_id SERIAL PRIMARY KEY,
	   dtp_type_name VARCHAR(255)
	   ) COMMENT = 'Вид ДТП';
	  
CREATE TABLE dtp.roads_streets_categories (
	   category_id SERIAL PRIMARY KEY,
	   category_name VARCHAR(100)
	   ) COMMENT = 'Категории дорог и улиц';

CREATE TABLE dtp.roads (
	   road_id SERIAL PRIMARY KEY,
	   road_category BIGINT UNSIGNED NOT NULL,
	   road_name VARCHAR(255),
	   road_length DECIMAL(5,2),
	   
	   FOREIGN KEY (road_category) REFERENCES roads_streets_categories (category_id)
	   ) COMMENT = 'Автомобильные дороги';
	  
CREATE TABLE dtp.streets (
	   street_id SERIAL PRIMARY KEY,
	   street_category BIGINT UNSIGNED NOT NULL,
	   street_name VARCHAR(100),
	   street_length DECIMAL(5,2),
	   population_center VARCHAR(50),
	   
	   FOREIGN KEY (street_category) REFERENCES dtp.roads_streets_categories (category_id)
	   ) COMMENT = 'Улицы';
	  
CREATE TABLE dtp.dtp_schemes (
	   scheme_id SERIAL PRIMARY KEY,
	   scheme_name VARCHAR(50),
	   scheme_file_name VARCHAR(255) 
	   ) COMMENT = 'Схемы ДТП со ссылками на файлы с изображениями';
	  
CREATE TABLE dtp.roads_conditions (
	   road_condition_id SERIAL PRIMARY KEY,
	   road_condition_name VARCHAR(100)
	   ) COMMENT = 'Неудовлетворительные дорожные условия';
	  
CREATE TABLE dtp.objects_nearby (
	   objects_nearby_id SERIAL PRIMARY KEY,
	   objects_nearby_name VARCHAR(100)
	   ) COMMENT = 'Объекты поблизости';

CREATE TABLE dtp.traffic_features (
	   traffic_features_id SERIAL PRIMARY KEY,
	   traffic_features_name VARCHAR(100)
	   ) COMMENT = 'Особенности ОДД';

CREATE TABLE dtp.weather_conditions (
	   weather_conditions_id SERIAL PRIMARY KEY,
	   weather_conditions_name VARCHAR(50)
	   ) COMMENT = 'Погодные условия';

CREATE TABLE dtp.traffic_violation (
	   traffic_violation_id SERIAL PRIMARY KEY,
	   traffic_violation_name VARCHAR(350)
	   ) COMMENT = 'Нарушения ПДД';
	  
-- Основные таблицы

CREATE TABLE dtp.cards (
	   card_id SERIAL PRIMARY KEY,
	   dtp_number INT UNSIGNED NOT NULL,
	   region_name BIGINT UNSIGNED NOT NULL,
	   dtp_type BIGINT UNSIGNED NOT NULL,
	   dtp_date DATE NOT NULL,
	   dtp_time TIME NOT NULL,
	   participants_number SMALLINT UNSIGNED NOT NULL,
	   cars_number SMALLINT UNSIGNED NOT NULL,
	   deads_number SMALLINT UNSIGNED NOT NULL,
	   wounded_number SMALLINT UNSIGNED NOT NULL,
	   
	   INDEX (dtp_number),
	   FOREIGN KEY (region_name) REFERENCES dtp.regions (region_id),
	   FOREIGN KEY (dtp_type) REFERENCES dtp.dtp_types (dtp_type_id)
	   ) COMMENT = 'Карточки ДТП';
	  
CREATE TABLE dtp.dtp_info (
	   info_id SERIAL PRIMARY KEY,
	   card_id BIGINT UNSIGNED NOT NULL, 
	   population_center VARCHAR(50),
	   road_id BIGINT UNSIGNED,
	   coordinate_km INT UNSIGNED,
	   coordinate_m INT UNSIGNED,
	   street_id BIGINT UNSIGNED,
	   house_number VARCHAR(50),
	   driving_mode ENUM('Режим движения не изменялся', 'Движение частично перекрыто') NOT NULL, 
	   special_conditions ENUM('Сведения отсутствуют', 'Участок, оборудованный искусственными неровностями', 'Участок, контролируемый стационарными камерами автоматической фотовидеофиксации нарушений ПДД, обозначенный соответствующим предупреждающим знаком') NOT NULL,
	   light_level ENUM('В темное время суток, освещение отсутствует', 'Светлое время суток', 'В темное время суток, освещение включено') NOT NULL,
	   road_surface_condition SET('Заснеженное', 'Сухое', 'Мокрое', 'Пыльное') NOT NULL,
	   longitude DECIMAL(10, 6) NOT NULL,
	   latitude DECIMAL(10, 6) NOT NULL,
	   dtp_scheme_id BIGINT UNSIGNED NOT NULL,
	   
	   FOREIGN KEY (card_id) REFERENCES dtp.cards (card_id),
	   FOREIGN KEY (road_id) REFERENCES dtp.roads (road_id),
	   FOREIGN KEY (street_id) REFERENCES dtp.streets (street_id),
	   FOREIGN KEY (dtp_scheme_id) REFERENCES dtp.dtp_schemes (scheme_id)
	   ) COMMENT = 'Информация о ДТП';
	  
CREATE TABLE dtp.cars_info (
	   car_id SERIAL PRIMARY KEY,
	   card_id BIGINT UNSIGNED NOT NULL, 
	   car_color VARCHAR(50),
	   ownership_form VARCHAR(100) NOT NULL,
	   release_year YEAR,
	   car_model VARCHAR(100),
	   car_brand VARCHAR(100),
	   participant_type ENUM('Физические лица', 'Юридические лица, являющиеся коммерческими организациями', 'Юридические лица, являющиеся некоммерческими организациями', 'Индивидуальные предприниматели без образования юридического лица') NOT NULL, 
	   transmission_type ENUM('С передним приводом', 'С задним приводом', 'Иное расположение рулевого управления', 'Полноприводные'),
	   technical_malfunctions ENUM('Технические неисправности отсутствуют', 'Ремни безопасности неработоспособны или имеют видимые надрывы') NOT NULL,
	   car_class VARCHAR(100),
	   participant_car_behavior ENUM('Осталось на месте ДТП', 'Скрылось с места ДТП') NOT NULL,
	   
	   FOREIGN KEY (card_id) REFERENCES dtp.cards (card_id)
	   ) COMMENT = 'Информация о транспортных средствах';
	  
CREATE TABLE dtp.participant_info (
	   participant_id SERIAL PRIMARY KEY,
	   card_id BIGINT UNSIGNED NOT NULL, 
	   car_id BIGINT UNSIGNED NOT NULL,
	   dtp_participant_category ENUM('Водитель', 'Пассажир', 'Велосипедист') NOT NULL, 
	   gender ENUM('Мужской', 'Женский') NOT NULL,
	   driving_experience SMALLINT UNSIGNED,
	   direct_traffic_violation BIGINT UNSIGNED,
	   alcohol_intoxication SMALLINT UNSIGNED,
	   is_safety_belt BIT,
	   dtp_scene_left ENUM('Остался на месте ДТП', 'Скрылся с места ДТП'),
	   consequences_severity VARCHAR(100),
	   
	   FOREIGN KEY (card_id) REFERENCES dtp.cards (card_id),
	   FOREIGN KEY (car_id) REFERENCES dtp.cars_info (car_id),
	   FOREIGN KEY (direct_traffic_violation) REFERENCES dtp.traffic_violation (traffic_violation_id)
	   ) COMMENT = 'Информация об участниках ДТП';
	   
-- Связывающие таблицы
	  
CREATE TABLE dtp.objects_nearby_connection (
	   card_id BIGINT UNSIGNED NOT NULL,
	   objects_nearby_id BIGINT UNSIGNED NOT NULL,

	   FOREIGN KEY (card_id) REFERENCES dtp.cards (card_id),
	   FOREIGN KEY (objects_nearby_id) REFERENCES dtp.objects_nearby (objects_nearby_id)
	   ) COMMENT = 'Связь объектов поблизости и карточки ДТП';
	  
CREATE TABLE dtp.road_condition_connection (
	   card_id BIGINT UNSIGNED NOT NULL,
	   road_condition_id BIGINT UNSIGNED NOT NULL,

	   FOREIGN KEY (card_id) REFERENCES dtp.cards (card_id),
	   FOREIGN KEY (road_condition_id) REFERENCES dtp.roads_conditions (road_condition_id)
	   ) COMMENT = 'Связь неудовлетворительных дорожных условий и карточки ДТП';
	  
CREATE TABLE dtp.traffic_features_connection (
	   card_id BIGINT UNSIGNED NOT NULL,
	   traffic_features_id BIGINT UNSIGNED NOT NULL,

	   FOREIGN KEY (card_id) REFERENCES dtp.cards (card_id),
	   FOREIGN KEY (traffic_features_id) REFERENCES dtp.traffic_features (traffic_features_id)
	   ) COMMENT = 'Связь особенностей ОДД и карточки ДТП';
	  
CREATE TABLE dtp.weather_conditions_connection (
	   card_id BIGINT UNSIGNED NOT NULL,
	   weather_conditions_id BIGINT UNSIGNED NOT NULL,

	   FOREIGN KEY (card_id) REFERENCES dtp.cards (card_id),
	   FOREIGN KEY (weather_conditions_id) REFERENCES dtp.weather_conditions (weather_conditions_id)
	   ) COMMENT = 'Связь погодных условий и карточки ДТП';
	  
CREATE TABLE dtp.additional_traffic_violation_connection (
	   participant_id BIGINT UNSIGNED NOT NULL,
	   card_id BIGINT UNSIGNED NOT NULL,
	   additional_traffic_violation BIGINT UNSIGNED NOT NULL,

	   FOREIGN KEY (participant_id) REFERENCES dtp.participant_info (participant_id),
	   FOREIGN KEY (card_id) REFERENCES dtp.cards (card_id),
	   FOREIGN KEY (additional_traffic_violation) REFERENCES dtp.traffic_violation (traffic_violation_id)
	   ) COMMENT = 'Связь сопутствующих нарушений ПДД, карточки ДТП и участника ДТП';	  
	  
	  
	  
	  