

create database opp;

\c opp


create table stg_opp2010(krs char(10), nazwa varchar(500), wartosc decimal(20,5));
create table stg_opp2011(krs char(10), nazwa varchar(500), wartosc decimal(20,5));
create table stg_opp2012(krs char(10), nazwa varchar(500), wartosc decimal(20,5));
create table stg_opp2013(krs char(10), nazwa varchar(500), wartosc decimal(20,5));
create table stg_opp2013u(krs char(10), nazwa varchar(500), wartosc decimal(20,5));
create table stg_opp2014(krs char(10), nazwa varchar(500), wartosc decimal(20,5));
create table stg_opp2015(krs char(10), nazwa varchar(500), wartosc decimal(20,5));

copy stg_opp2010 FROM '/data/opp2010.tsv' DELIMITER E'\t' CSV;
copy stg_opp2011 FROM '/data/opp2011.tsv' DELIMITER E'\t' CSV;
copy stg_opp2012 FROM '/data/opp2012.tsv' DELIMITER E'\t' CSV;
copy stg_opp2013 FROM '/data/opp2013.tsv' DELIMITER E'\t' CSV;
copy stg_opp2013u FROM '/data/opp2013uzup.tsv' DELIMITER E'\t' CSV;
copy stg_opp2014 FROM '/data/opp2014.tsv' DELIMITER E'\t' CSV;
copy stg_opp2015 FROM '/data/opp2015.tsv' DELIMITER E'\t' CSV;


drop view if exists stg_opp;

create view stg_opp as
  select 2015 rok, krs, nazwa, wartosc from stg_opp2015
  union all
  select 2014 rok, krs, nazwa, wartosc from stg_opp2014
  union all
  select 2013 rok, krs, nazwa, wartosc from stg_opp2013
  union all
  select 2013 rok, krs, nazwa, wartosc from stg_opp2013u
  union all
  select 2012 rok, krs, nazwa, wartosc from stg_opp2012
  union all
  select 2011 rok, krs, nazwa, wartosc from stg_opp2011
  union all
  select 2010 rok, krs, nazwa, wartosc from stg_opp2010
  ;


drop table if exists dim_opp;

create table dim_opp(
  id_opp        serial,
  krs           char(10),
  name          varchar(500),
  nip           varchar(20),
  wojewodztwo   varchar(50),
  powiat        varchar(50),
  gmina         varchar(50),
  miejscowosc   varchar(50),
  animals       boolean,
  down          boolean,
  sport         boolean,
  hospice       boolean,
  homeless      boolean,
  disabled      boolean,
  cancer        boolean,
  skauting      boolean,
  kids          boolean,
  senior        boolean,
  alkohol       boolean,
  drugs         boolean,
  charity       boolean,
  psych         boolean
);

drop table if exists dim_date;
create table dim_date(
  id_date       int,
  tax_total     decimal(20,0),
  tax_deadline  date
);

drop table if exists fund;
create table fund(
  id_date       int,
  id_opp        int,
  amount        decimal(20,5)
);

-- tax_total z zestawien Ministerstwa Finansow
insert into dim_date(id_date, tax_total, tax_deadline) values(2015, 83140145000, '2016-04-30');
insert into dim_date(id_date, tax_total, tax_deadline) values(2014, 78127386000, '2015-04-30');
insert into dim_date(id_date, tax_total, tax_deadline) values(2013, 73751310000, '2014-04-30');
insert into dim_date(id_date, tax_total, tax_deadline) values(2012, 70621939000, '2013-04-30');
insert into dim_date(id_date, tax_total, tax_deadline) values(2011, 67505115000, '2012-04-30');
insert into dim_date(id_date, tax_total, tax_deadline) values(2010, 62487000000, '2011-04-30');

insert into dim_opp(krs, name)
select o.krs, min(o.nazwa) from stg_opp o
group by o.krs ;

update dim_opp set down = true where name like '%DOWNA%';
update dim_opp set sport = true where name like '%SPORT%' or name like '%KULTURY FIZY%';
update dim_opp set animals = true where name like '%ANIMALS%' or name like '%ZWIERZ%' or name like '%KOTÓW%' or name like '% PSY';
update dim_opp set hospice = true where name like '%HOSPICJUM%' and name not like '%KOTÓW%';
update dim_opp set homeless = true where name like '%BEZDOMN%' and name not like '%ZWIERZ%' and name not like '%KOTÓW%';
update dim_opp set disabled = true where name like '%NIEPEŁNOSPRAWN%';
update dim_opp set cancer = true where name like '%RAK%ROLL%' or name like '%NOWOTW%' or name like '%ONKOLOG%';
update dim_opp set skauting = true where name like '%HARCER%';
update dim_opp set kids = true where name like '%DZIECI%';
update dim_opp set senior = true where name like '%STARS%' or name like '%SENIOR%';
update dim_opp set alkohol = true where  name like '%ABSTYNEN%' or name like '%ALKOHOL%' or name like '%TRZE_WO%';
update dim_opp set drugs = true where name like '%NARKO%';
update dim_opp set charity = true where name like '%CHARYTAT%';
update dim_opp set psych = true where name like '%PSYCHI%';

insert into fund
  select rok, id_opp, sum(wartosc) from stg_opp o join dim_opp d on (o.krs = d.krs)
group by rok, id_opp
;
