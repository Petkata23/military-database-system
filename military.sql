CREATE DATABASE military;

USE military;

CREATE TABLE military_units (
  unit_id INT PRIMARY KEY AUTO_INCREMENT,
  unit_name VARCHAR(20) NOT NULL,
  CONSTRAINT unit_name_unique UNIQUE (unit_name)
);

CREATE TABLE facilities (
  facility_id INT PRIMARY KEY AUTO_INCREMENT,
  facility_name VARCHAR(20) NOT NULL,
  location VARCHAR(20) NOT NULL,
  facility_type VARCHAR(20) NOT NULL,
  capacity INT NOT NULL,
  unit_id INT NOT NULL,
  CONSTRAINT capacity_positive CHECK (capacity > 0),
  FOREIGN KEY (unit_id) REFERENCES military_units(unit_id)
);

CREATE TABLE military_events (
  event_id INT PRIMARY KEY AUTO_INCREMENT,
  event_name VARCHAR(30) NOT NULL,
  event_date DATE NOT NULL,
  event_location VARCHAR(20) NOT NULL, 
  event_description TEXT  
);

CREATE TABLE military_equipment (
  equipment_id INT PRIMARY KEY AUTO_INCREMENT,
  equipment_name VARCHAR(30) NOT NULL,
  unit_id INT NOT NULL,
  equipment_type VARCHAR(20) NOT NULL,  
  equipment_description TEXT,
  INDEX equipment_name_index (equipment_name),
  FOREIGN KEY (unit_id) REFERENCES military_units(unit_id)
);

CREATE TABLE equipment_events (
  equipment_event_id INT PRIMARY KEY AUTO_INCREMENT,
  equipment_id INT NOT NULL,
  event_id INT NOT NULL,
  FOREIGN KEY (equipment_id) REFERENCES military_equipment(equipment_id),
  FOREIGN KEY (event_id) REFERENCES military_events(event_id)
);

INSERT INTO military_units (unit_name)
VALUES
  ('Infantry'),
  ('Armored Division'),
  ('Special Forces');

INSERT INTO facilities (facility_name, location, facility_type, capacity, unit_id)
VALUES
  ('Base Camp 1', 'Camp Location 1', 'Camp', 500, 1),
  ('Training Center 1', 'Training Location 1', 'Training', 1000, 2),
  ('Storage Facility 1', 'Storage Location 1', 'Storage', 200, 3);

INSERT INTO military_events (event_name, event_date, event_location, event_description)
VALUES
  ('Training Exercise 1', '2023-11-10', 'Training Location 1', 'Basic infantry training'),
  ('Armored Division Parade', '2023-12-15', 'Parade Ground 1', 'Display of armored vehicles'),
  ('Mission Briefing', '2023-11-20', 'Special Ops Center 1', 'Top-secret mission planning');

INSERT INTO military_equipment (equipment_name, unit_id, equipment_type, equipment_description)
VALUES
  ('M16 Rifle', 1, 'Firearm', 'Standard issue rifle for infantry'),
  ('Abrams Tank', 2, 'Tank', 'Main battle tank with heavy armor'),
  ('M4 Carbine', 1, 'Firearm', 'Standard issue carbine for infantry'),
  ('Night Vision Goggles', 3, 'Optical Gear', 'Special forces night vision equipment');

INSERT INTO equipment_events (equipment_id, event_id)
VALUES
  (1, 1),
  (2, 2),
  (3, 3);

SELECT * FROM military_units;
SELECT * FROM facilities;
SELECT * FROM military_events;
SELECT * FROM military_equipment;
SELECT * FROM equipment_events;



-- Актуализиране на местоположението на фасилитито с id 1
UPDATE facilities
SET location = 'Bulgaria'
WHERE facility_id = 1;

-- Увеличаване на капацитета на фасилити с id 3
UPDATE facilities
SET capacity = capacity + 100
WHERE facility_id = 3;

-- Изтриване на събитие за екипиране с id 2 от equipment_events
DELETE FROM equipment_events
WHERE event_id = 2;

-- Списък от оборудвания и събития
SELECT 
  equipment_name AS item_name,
  equipment_description AS item_description,
  'Equipment' AS item_type
FROM military_equipment

UNION

SELECT 
  event_name AS item_name,
  event_description AS item_description,
  'Event' AS item_type
FROM military_events
ORDER BY item_type, item_name;


-- Информация за военните единици и техните оборудвания
SELECT 
  unit_name,
  (SELECT group_concat(CONCAT(equipment_name, ' - ', equipment_description))
   FROM military_equipment me
   WHERE mu.unit_id = me.unit_id) AS equipment_list
FROM military_units mu
ORDER BY unit_name;

-- Военни единици и техните оборудвания, където капацитетът на фасилитaта е по-голям от средния капацитет на всички фасилита
SELECT 
  mu.unit_name,
  mu.unit_id,
  (SELECT (me.equipment_name)
   FROM military_equipment me
   WHERE mu.unit_id = me.unit_id) AS equipment_list
FROM military_units mu
WHERE mu.unit_id IN (
    SELECT f.unit_id
    FROM facilities f
    WHERE f.capacity > (SELECT AVG(capacity) FROM facilities)
)
ORDER BY mu.unit_name;

-- ---------------------------------------------------------------------------------

-- Общ брой екипировки по видове военни единици
CREATE VIEW unit_equipment_count as
SELECT mu.unit_id, mu.unit_name, COUNT(me.equipment_id) as equipment_count
FROM military_units mu
LEFT JOIN military_equipment me on mu.unit_id = me.unit_id
GROUP BY mu.unit_id, mu.unit_name;

-- Среден капацитет на фасилититата
CREATE VIEW avg_facility_capacity as
SELECT facility_type, AVG(capacity) as average_capacity
FROM facilities
GROUP BY facility_type;

-- Брой събития по тип оборудване
CREATE VIEW event_equipment_count as
SELECT me.equipment_type, COUNT(DISTINCT ee.event_id) as event_count
FROM military_equipment me
LEFT JOIN equipment_events ee on me.equipment_id = ee.equipment_id
GROUP BY me.equipment_type;

-- Списък на екипировката, която се използва в eventite
CREATE VIEW event_equipment_list as
SELECT e.event_id, e.event_name, me.equipment_name
FROM military_events e
JOIN equipment_events ee on e.event_id = ee.event_id
JOIN military_equipment me on ee.equipment_id = me.equipment_id;


SELECT * FROM unit_equipment_count;
SELECT * FROM avg_facility_capacity;
SELECT * FROM event_equipment_count;
SELECT * FROM event_equipment_list;

- --------------------------------------------------------------------------

-- Показва броя на събитията за определен тип оборудване
DELIMITER $$
CREATE FUNCTION count_events_by_equipment_type(equipmentType VARCHAR(20))
returns int
DETERMINISTIC
BEGIN
  DECLARE eventCount INT;
  SELECT COUNT(*) INTO eventCount
  FROM equipment_events ee
  JOIN military_equipment me on ee.equipment_id = me.equipment_id
  WHERE me.equipment_type = equipmentType;
  RETURN eventCount;
END $$
delimiter ;

SELECT count_events_by_equipment_type('Firearm') as event_count;


-- Вмъква ново оборудване и го премества в друг unit
START TRANSACTION;
INSERT INTO military_equipment (equipment_name, unit_id, equipment_type, equipment_description)
VALUES ('AK-47', 1, 'Firearm', 'Brand new AK-47 for better equipment');
UPDATE military_equipment
SET unit_id = 2
WHERE equipment_name = 'AK-47';
COMMIT;

SELECT * FROM military_equipment;



CREATE TABLE logs (
  log_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(30) NOT NULL,
  log_message TEXT NOT NULL,
  log_timestamp TIMESTAMP default current_timestamp
);

-- Инсъртва нов unit и записва действието в logs 
DELIMITER $$
CREATE TRIGGER after_insert_unit
AFTER INSERT ON military_units
FOR EACH ROW
BEGIN
  INSERT INTO logs (name, log_message)
  VALUES ('unit insert', CONCAT('New unit created: ', new.unit_name));
END $$
DELIMITER ;

INSERT INTO military_units (unit_name) VALUES ('Air Forces');
SELECT * FROM logs;


