/*Создание структуры БД*/

drop schema if exists pod;
create database pod;
use pod;

drop table if exists bild_obj_types;

create table bild_obj_types ( id int NOT NULL AUTO_INCREMENT UNIQUE primary key,
bild_obj_type varchar(255));


drop table if exists ADM_AREAS;
create table ADM_AREAS ( id int NOT NULL AUTO_INCREMENT UNIQUE primary key,
ADM_AREA varchar(255)
);

drop table if exists DISTRICTS;

create table DISTRICTS ( id int NOT NULL AUTO_INCREMENT UNIQUE primary key,
DISTRICT varchar(255));

drop table if exists normative;

create table normative ( id int NOT NULL AUTO_INCREMENT UNIQUE primary key,
cat_name text,
cat_normative DECIMAL(10,2)
);

drop table if exists Type_Objects;

create table Type_Objects ( id int NOT NULL AUTO_INCREMENT UNIQUE primary key,
Type_Object varchar(255),
cat_normative int (2),
constraint fk_cat_normative foreign key (cat_normative) references normative (id) ON DELETE RESTRICT
ON UPDATE CASCADE
);


drop table if exists address_register;
create table address_register (
address TEXT,
UNOM int NOT NULL AUTO_INCREMENT UNIQUE primary key,
bild_obj_type int,
ADM_AREA int,
DISTRICT int(2),
constraint fk_bild_obj_type foreign key (bild_obj_type) references bild_obj_types (id) ON DELETE SET NULL
ON UPDATE CASCADE,
constraint fk_ADM_AREA foreign key (ADM_AREA) references ADM_AREAS (id) ON DELETE restrict ON UPDATE CASCADE,
constraint fk_DISTRICT foreign key (DISTRICT) references DISTRICTS (id) ON DELETE restrict ON UPDATE CASCADE,
N_FIAS varchar(255),
KAD_N varchar(255),
KAD_ZU varchar(255),
geoData TEXT
);

drop table if exists catering_facilities_register;
create table catering_facilities_register ( 
Id int primary key auto_increment,
Build_unom int,
constraint fk_Build_unom_catering_facilities foreign key (Build_unom) references address_register(UNOM) ON DELETE SET NULL
ON UPDATE CASCADE,
Type_Object int(2),
constraint fk_Type_Object foreign key (Type_Object) references Type_Objects (id) ON DELETE restrict ON UPDATE CASCADE,
name varchar(255) not null,
PublicPhone varchar(255),
SeatsCount int(7),
IsNetObject varchar (20)
);

drop table if exists mno_types;
create table mno_types ( Id int primary key auto_increment,
mno_type varchar(255),
trash_type varchar(255)
);

drop table if exists MNO;
create table MNO ( 
Id int primary key auto_increment,
serv_bild_UNOM int,
constraint fk_serv_bild_UNOM foreign key (serv_bild_UNOM) references address_register(UNOM) ON DELETE SET NULL
ON UPDATE CASCADE,
mno_adress varchar(255),
separate_trash varchar(10),
cordinate varchar(255),
mno_type int(2),
constraint fk_mno_type foreign key (mno_type) references mno_types (id) ON DELETE restrict ON UPDATE CASCADE
);

drop table if exists trash_tanks_types;
create table trash_tanks_types ( Id int primary key,
capacity DECIMAL(2,1),
area DECIMAL(2,1)
);

drop table if exists trash_tanks;
create table trash_tanks ( 
tank_id int primary key,
MNO_id int,
constraint fk_MNO_id foreign key (MNO_id) references MNO(id) ON DELETE SET NULL
ON UPDATE CASCADE,
trash_tanks_type int,
constraint fk_trash_tanks_type foreign key (trash_tanks_type) references trash_tanks_types (id) ON DELETE restrict ON UPDATE CASCADE
);

drop table if exists STO_register;
create table STO_register ( 
Id int primary key auto_increment,
name varchar(255),
IsNetObject varchar(10),
TypeObject_id int,
constraint fk_TypeObject_id foreign key (TypeObject_id) references Type_Objects (id)  ON DELETE restrict ON UPDATE CASCADE,
PublicPhone varchar(255),
WorkingHours text,
area DECIMAL(10,2),
Build_unom int,
constraint fk_Build_unom_STO foreign key (Build_unom) references address_register (UNOM) ON DELETE SET NULL
ON UPDATE CASCADE
);

/*Загрузка данных*/

use pod;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ADM_AREAS.csv'
into
	table pod.ADM_AREAS FIELDS terminated by ';' ignore 1 lines;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Districts.csv'
into
	table pod.Districts FIELDS terminated by ';' ignore 1 lines ;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/normative.csv'
into
	table pod.normative FIELDS terminated by ';' ignore 1 lines ;
	
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Type_Objects.csv'
into
	table pod.Type_Objects FIELDS terminated by ';' ignore 1 lines  ;
	
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bild_obj_types.csv'
into
	table pod.bild_obj_types FIELDS terminated by ';' ignore 1 lines ;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/address_register.csv'
into
	table pod.address_register FIELDS terminated by ';' ignore 1 lines (address, UNOM, N_FIAS, KAD_N, KAD_ZU, geoData, bild_obj_type, ADM_AREA, DISTRICT);
	
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/mno_types.csv'
into
	table pod.mno_types FIELDS terminated by ';' ignore 1 lines ;
	
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/mno.csv'
into
	table pod.mno FIELDS terminated by ';' ignore 1 lines (id, serv_bild_UNOM, mno_adress, separate_trash, cordinate, mno_type);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/trash_tanks_types.csv'
into
	table pod.trash_tanks_types FIELDS terminated by ';' ignore 1 lines;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/trash_tanks.csv'
into
	table pod.trash_tanks FIELDS terminated by ';' ignore 1 lines ;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/catering_facilities_register.csv'
into
	table pod.catering_facilities_register FIELDS terminated by ';' ignore 1 lines (id, Build_unom, Type_Object, name, PublicPhone, SeatsCount, IsNetObject) ;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/STO_register.csv'
into
	table pod.STO_register FIELDS terminated by ';' ignore 1 lines ;

/*Создание представлений*/

/*Предствление №1 "Объем генерации отходов на объектах общественного питания"*/

drop view if exists pod.v1;
create or replace
algorithm = UNDEFINED view pod.v1 as
select
    t_cfr.name as `Название объекта`,
    t_cfr.SeatsCount as `Количество посадочный мест`,
    t_to.Type_Object as `Тип объекта`,
    t_norm.cat_normative as `Норматив`,
    ROUND((t_cfr.SeatsCount * t_norm.cat_normative / 1000),2) as `Объем образования отходов, тонн`
from
    (pod.catering_facilities_register as t_cfr
left join pod.type_objects as t_to on
    (t_cfr.Type_Object = t_to.id)
 left join pod.normative as t_norm on
    (t_to.cat_normative = t_norm.id))   
    ;

/*Предствление №2 "Объем генерации отходов на объектах стационарной торговли"*/

drop view if exists pod.v2;
create or replace
algorithm = UNDEFINED view pod.v2 as
select
    t_sto.name as `Название объекта`,
    t_sto.area as `Площадь`,
    t_to.Type_Object as `Тип объекта`,
    t_norm.cat_normative as `Норматив`,
    ROUND((t_sto.area * t_norm.cat_normative / 1000),2) as `Объем образования отходов, тонн`
from
    (pod.sto_register as t_sto
left join pod.type_objects as t_to on
    (t_sto.TypeObject_id = t_to.id)
 left join pod.normative as t_norm on
    (t_to.cat_normative = t_norm.id))   
    ;
    
/*Предствление №3 "Объем генерации отходов в разрезе зданий"*/

drop view if exists pod.v3;
create or replace
algorithm = UNDEFINED view pod.v3 as
select t1.UNOM, t1.`Адрес здания`, count(t1.`Объем образования отходов, тонн`) as 'Количество отходообразователей', sum(t1.`Объем образования отходов, тонн`) as 'Объем образования отходов, тонн' from
(select
t_ar.address as `Адрес здания`,
	t_ar.`UNOM` as `UNOM`,
    t_sto.name as `Наименование`,
    ROUND((t_sto.area * t_norm.cat_normative / 1000),2) as `Объем образования отходов, тонн`
from
    (pod.address_register as t_ar
left join pod.sto_register as t_sto on
	(t_ar.`UNOM` = t_sto.`Build_unom`)
left join pod.type_objects as t_to on
    (t_sto.`TypeObject_id` = t_to.id)
left join pod.normative as t_norm on
    (t_to.cat_normative = t_norm.id))   
union all
select
t_ar.address as `Адрес здания`,
	t_ar.`UNOM` as `UNOM`,
    t_cfr.name as `Наименование`,
    ROUND((t_cfr.SeatsCount * t_norm.cat_normative / 1000),2) as `Объем образования отходов, тонн`
from
    (pod.address_register as t_ar
left join pod.catering_facilities_register as t_cfr on
	(t_ar.`UNOM` = t_cfr.`Build_unom`)	
left join pod.type_objects as t_to on
    (t_cfr.`Type_Object` = t_to.id)
 left join pod.normative as t_norm on
    (t_to.cat_normative = t_norm.id))   
) as t1
group by t1.UNOM
order by t1.UNOM;    
   
/*Предствление №4 "Объем генерации ТКО в разрезе МНО"*/

drop view if exists pod.v4;

create or replace
algorithm = UNDEFINED view pod.v4 as
select
	mno.`Id`,
	mno.mno_adress,
	mno.mno_type,
	(sum(v3.`Объем образования отходов, тонн`) / count(mno.`serv_bild_UNOM`) over(partition by mno.`serv_bild_UNOM`)) as `Объем образования отходов, тонн`
from
	pod.mno as mno left join pod.v3 as v3 on (mno.serv_bild_UNOM = v3.`UNOM`)
where mno_type = 1
group by mno.`Id`;

/*Тригеры*/

/*Таблица для лога*/
drop table if exists logs;
CREATE TABLE `logs` (
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Время и дата создания записи',
  `tab_name` varchar(255) default NULL COMMENT 'Название таблицы',
  `id` int(11) DEFAULT NULL COMMENT 'Идентификатор первичного ключа',
  `old_record` TEXT default NULL COMMENT 'Старая запись',
  `new_record` text DEFAULT NULL COMMENT 'Новая запись',
  `action_type` varchar(255) DEFAULT NULL COMMENT 'Действие'
) ENGINE=ARCHIVE DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
;

/*Сами тригеры*/
DELIMITER //
drop trigger if exists check_ar_update //
CREATE TRIGGER check_ar_update AFTER update ON pod.address_register FOR EACH ROW BEGIN
    INSERT INTO pod.logs
   ( created_at,
     tab_name,
     id,
     old_record,
     new_record,
     action_type)
   values (
    now(),
	'pod.address_register',
	new.UNOM,
	concat(ifnull(old.UNOM,'пусто'),'\n',ifnull(old.address,'пусто'),'\n',ifnull(old.bild_obj_type,'пусто'),'\n',ifnull(old.ADM_AREA,'пусто'),'\n',ifnull(old.DISTRICT,'пусто'),'\n',ifnull(old.N_FIAS,'пусто'),'\n',ifnull(old.KAD_N,'пусто'),'\n',ifnull(old.KAD_ZU,'пусто'),'\n',ifnull(old.geoData,'пусто')),
	concat(ifnull(new.UNOM,'пусто'),'\n',ifnull(new.address,'пусто'),'\n',ifnull(new.bild_obj_type,'пусто'),'\n',ifnull(new.ADM_AREA,'пусто'),'\n',ifnull(new.DISTRICT,'пусто'),'\n',ifnull(new.N_FIAS,'пусто'),'\n',ifnull(new.KAD_N,'пусто'),'\n',ifnull(new.KAD_ZU,'пусто'),'\n',ifnull(new.geoData,'пусто')),
	'Изменение'
     );
end //

drop trigger if exists check_ar_insert //
CREATE TRIGGER check_ar_insert AFTER insert ON pod.address_register FOR EACH ROW BEGIN
    INSERT INTO pod.logs
   ( created_at,
     tab_name,
     id,
     new_record,
     action_type)
   values (
    now(),
	'pod.address_register',
	new.UNOM,
	concat(ifnull(new.UNOM,'пусто'),'\n',ifnull(new.address,'пусто'),'\n',ifnull(new.bild_obj_type,'пусто'),'\n',ifnull(new.ADM_AREA,'пусто'),'\n',ifnull(new.DISTRICT,'пусто'),'\n',ifnull(new.N_FIAS,'пусто'),'\n',ifnull(new.KAD_N,'пусто'),'\n',ifnull(new.KAD_ZU,'пусто'),'\n',ifnull(new.geoData,'пусто')),
	'Добавление'
     );
end //

drop trigger if exists check_ar_DELETE //
CREATE TRIGGER check_ar_DELETE AFTER DELETE ON pod.address_register FOR EACH ROW BEGIN
    INSERT INTO pod.logs
   ( created_at,
     tab_name,
     id,
     old_record,
     action_type)
   values (
    now(),
	'pod.address_register',
	old.UNOM,
	concat(ifnull(old.UNOM,'пусто'),'\n',ifnull(old.address,'пусто'),'\n',ifnull(old.bild_obj_type,'пусто'),'\n',ifnull(old.ADM_AREA,'пусто'),'\n',ifnull(old.DISTRICT,'пусто'),'\n',ifnull(old.N_FIAS,'пусто'),'\n',ifnull(old.KAD_N,'пусто'),'\n',ifnull(old.KAD_ZU,'пусто'),'\n',ifnull(old.geoData,'пусто')),
	'Удаление'
     );
end //

drop trigger if exists check_sto_update //
CREATE TRIGGER check_sto_update AFTER update ON pod.sto_register FOR EACH ROW BEGIN
    INSERT INTO pod.logs
   ( created_at,
     tab_name,
     id,
     old_record,
     new_record,
     action_type)
   values (
    now(),
	'pod.sto_register',
	new.Id,
	concat(ifnull(old.Id,'пусто'),'\n',ifnull(old.name,'пусто'),'\n',ifnull(old.IsNetObject,'пусто'),'\n',ifnull(old.TypeObject_id,'пусто'),'\n',ifnull(old.PublicPhone,'пусто'),'\n',ifnull(old.WorkingHours,'пусто'),'\n',ifnull(old.area,'пусто'),'\n',ifnull(old.Build_unom,'пусто')),
	concat(ifnull(new.Id,'пусто'),'\n',ifnull(new.name,'пусто'),'\n',ifnull(new.IsNetObject,'пусто'),'\n',ifnull(new.TypeObject_id,'пусто'),'\n',ifnull(new.PublicPhone,'пусто'),'\n',ifnull(new.WorkingHours,'пусто'),'\n',ifnull(new.area,'пусто'),'\n',ifnull(new.Build_unom,'пусто')),
	'Изменение' 
	);
end //

drop trigger if exists check_sto_insert //
CREATE TRIGGER check_sto_insert AFTER insert ON pod.sto_register FOR EACH ROW BEGIN
    INSERT INTO pod.logs
   ( created_at,
     tab_name,
     id,
     new_record,
     action_type)
   values (
    now(),
	'pod.sto_register',
	new.Id,
	concat(ifnull(new.Id,'пусто'),'\n',ifnull(new.name,'пусто'),'\n',ifnull(new.IsNetObject,'пусто'),'\n',ifnull(new.TypeObject_id,'пусто'),'\n',
	ifnull(new.PublicPhone,'пусто'),'\n',ifnull(new.WorkingHours,'пусто'),'\n',ifnull(new.area,'пусто'),'\n',ifnull(new.Build_unom,'пусто')),
	'Добавление'
     );
end //

drop trigger if exists check_sto_DELETE //
CREATE TRIGGER check_sto_DELETE AFTER DELETE ON pod.sto_register FOR EACH ROW BEGIN
    INSERT INTO pod.logs
   ( created_at,
     tab_name,
     id,
     old_record,
     action_type)
   values (
    now(),
	'pod.sto_register',
	old.Id,
	concat(ifnull(old.Id,'пусто'),'\n',ifnull(old.name,'пусто'),'\n',ifnull(old.IsNetObject,'пусто'),'\n',ifnull(old.TypeObject_id,'пусто'),'\n',
	ifnull(old.PublicPhone,'пусто'),'\n',ifnull(old.WorkingHours,'пусто'),'\n',ifnull(old.area,'пусто'),'\n',ifnull(old.Build_unom,'пусто')),
	'Удаление'
     );
end //

drop trigger if exists check_catering_facilities_register_update //
CREATE TRIGGER check_catering_facilities_register_update AFTER update ON pod.catering_facilities_register FOR EACH ROW BEGIN
    INSERT INTO pod.logs
   ( created_at,
     tab_name,
     id,
     old_record,
     new_record,
     action_type)
   values (
    now(),
	'pod.catering_facilities_register',
	new.Id,
	concat(ifnull(old.Id,'пусто'),'\n',ifnull(old.Build_unom,'пусто'),'\n',ifnull(old.Type_Object,'пусто'),'\n',ifnull(old.name,'пусто'),
	'\n',ifnull(old.PublicPhone,'пусто'),'\n',ifnull(old.SeatsCount,'пусто'),'\n',ifnull(old.IsNetObject,'пусто')),
	concat(ifnull(new.Id,'пусто'),'\n',ifnull(new.Build_unom,'пусто'),'\n',ifnull(new.Type_Object,'пусто'),'\n',ifnull(new.name,'пусто'),
	'\n',ifnull(new.PublicPhone,'пусто'),'\n',ifnull(new.SeatsCount,'пусто'),'\n',ifnull(new.IsNetObject,'пусто')),
	'Изменение' 
	);
end //

drop trigger if exists check_catering_facilities_register_insert //
CREATE TRIGGER check_catering_facilities_register_insert AFTER insert ON pod.catering_facilities_register FOR EACH ROW BEGIN
    INSERT INTO pod.logs
   ( created_at,
     tab_name,
     id,
     new_record,
     action_type)
   values (
    now(),
	'pod.catering_facilities_register',
	new.Id,
	concat(ifnull(new.Id,'пусто'),'\n',ifnull(new.Build_unom,'пусто'),'\n',ifnull(new.Type_Object,'пусто'),'\n',ifnull(new.name,'пусто'),
	'\n',ifnull(new.PublicPhone,'пусто'),'\n',ifnull(new.SeatsCount,'пусто'),'\n',ifnull(new.IsNetObject,'пусто')),
	'Добавление'
     );
end //

drop trigger if exists check_catering_facilities_register_DELETE //
CREATE TRIGGER check_catering_facilities_register_DELETE AFTER DELETE ON pod.catering_facilities_register FOR EACH ROW BEGIN
    INSERT INTO pod.logs
   ( created_at,
     tab_name,
     id,
     old_record,
     action_type)
   values (
    now(),
	'pod.catering_facilities_register',
	old.Id,
	concat(ifnull(old.Id,'пусто'),'\n',ifnull(old.Build_unom,'пусто'),'\n',ifnull(old.Type_Object,'пусто'),'\n',ifnull(old.name,'пусто'),
	'\n',ifnull(old.PublicPhone,'пусто'),'\n',ifnull(old.SeatsCount,'пусто'),'\n',ifnull(old.IsNetObject,'пусто')),
	'Удаление'
     );
end //



