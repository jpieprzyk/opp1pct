


-- opp 1 pct w stosunku do sumy PITow
select
  id_date, cnt_opp,
  lag(cnt_opp) over (order by id_date) prev_cnt_opp,
  (1.0 * cnt_opp - lag(cnt_opp) over (order by id_date)) / lag(cnt_opp) over (order by id_date) cnt_opp_diff_pct,
  sum_opp, pit_total, opp_pct_pit
from (
  select
    f.id_date,
    count(distinct krs) cnt_opp,
    sum(amount) sum_opp,
    max(tax_total) pit_total,
    sum(amount) / max(tax_total) opp_pct_pit
  from fund f
  join dim_date dd on (f.id_date = dd.id_date)
  join dim_opp opp on (f.id_opp = opp.id_opp)
  group by f.id_date
) t
order by id_date;
-- coraz wiecej oddajmy na 1 procent
-- choc nadal jest to tylko 0.7% pitow a nie 1%
id_date | cnt_opp | prev_cnt_opp |    cnt_opp_diff_pct    |     sum_opp     |  pit_total  |      opp_pct_pit
---------+---------+--------------+------------------------+-----------------+-------------+------------------------
   2010 |    6533 |              |                        | 400241359.84000 | 62487000000 | 0.00640519403779986237
   2011 |    6859 |         6533 | 0.04990050512781264350 | 457315813.63000 | 67505115000 | 0.00677453573155160168
   2012 |    7110 |         6859 | 0.03659425572240851436 | 480042179.27000 | 70621939000 | 0.00679735201365683262
   2013 |    7423 |         7110 | 0.04402250351617440225 | 508768925.11000 | 73751310000 | 0.00689843916141964122
   2014 |    7888 |         7423 | 0.06264313619830257308 | 557563428.71000 | 78127386000 | 0.00713659393020009654
   2015 |    8108 |         7888 | 0.02789046653144016227 | 617521600.64000 | 83140145000 | 0.00742747803290456133




\f ','
\a



select f.id_date, sum(amount) amount, max(tax_total) pit, sum(amount) / max(amount_total) pct_opp, sum(amount) / max(tax_total) pct_pit
from fund f
join dim_date dd on (f.id_date = dd.id_date)
join dim_opp opp on (f.id_opp = opp.id_opp)
join (
  select id_date, sum(amount) amount_total from fund group by id_date
) ft on (f.id_date = ft.id_date)
where opp.disabled
group by f.id_date
order by f.id_date;


-- spadek dla 'drugs' i dla 'alkohol'
-- stale, choc bardzo duze (38% wszystkiego 1pct) kids
-- zwierzeta, stale (~ 3 % wszystkich )
-- sport ~ 1.2% tendencja lekko spadkowa
-- rosnie dla niepelnosprawnych. doszlo do 10%
-- delikatna tendencja spadkowa dla problemow alkoholowych 0.02%
-- charytatywne 0.8% i rosnie
-- rosnie psychologia i psychiatria (0.08%)
-- hospicja: choc wartosc nieznanie rosnie to procentowy udzial sukcesywnie maleje, jest ok 6%
-- bezdomni: niskie wplaty, choć za 2015 zwiekzyly sie 10krotnie w porownaniu do poprzednich lat (wigilia dla samotnych i bezdomnych)


select f.id_date, sum(amount), max(tax_total), sum(amount) / max(amount_total), sum(amount) / max(tax_total)
from fund f
join dim_date dd on (f.id_date = dd.id_date)
join dim_opp opp on (f.id_opp = opp.id_opp)
join (
  select id_date, sum(amount) amount_total from fund group by id_date
) ft on (f.id_date = ft.id_date)
where name like '%CARITAS%'
group by f.id_date
order by f.id_date;

-- 2% wszystkich opp. tendencja spadkowa


--------------------------------------------------------------------------------

-- ktore organizacje maja duzy przyrost


select
  r1.id_Date, r2.id_date, r1.name, r1.amount, r2.amount, (r2.amount - r1.amount) / r1.amount diff_pct
from (
  select id_date, krs, name, amount
  from fund f join dim_opp opp on (f.id_opp = opp.id_opp)
) r1 join (
  select id_date, krs, name, amount
  from fund f join dim_opp opp on (f.id_opp = opp.id_opp)
  where f.id_date=2015
) r2 on (r1.krs = r2.krs and r1.id_date = r2.id_date -1)
where r1.amount >= 10000 and r2.amount >= 10000
order by diff_pct desc
limit 30;
-- w zeszlym roku sposrod duzych (>=10000) hitem okazala sie (STOWARZYSZENIE ''WIGILIA DLA SAMOTNYCH I BEZDOMNYCH'') 31-krotny wzrost
id_date | id_date |                                                  name                                                   |    amount     |    amount     |      diff_pct
---------+---------+---------------------------------------------------------------------------------------------------------+---------------+---------------+---------------------
   2014 |    2015 | STOWARZYSZENIE ''WIGILIA DLA SAMOTNYCH I BEZDOMNYCH''                                                   |   16545.40000 |  541764.72000 | 31.7441294861411631
   2014 |    2015 | FUNDACJA ONKOLOGICZNA NADZIEJA                                                                          |   12446.23000 |  202392.60000 | 15.2613578569574883
   2014 |    2015 | ''BEZPIECZNE WAKACJE''                                                                                  |   12316.60000 |   98915.36000 |  7.0310605199486871
   2014 |    2015 | FUNDACJA UNITED WAY POLSKA                                                                              |   32414.95000 |  253534.89000 |  6.8215419119881413
   2014 |    2015 | SIEĆ OBYWATELSKA - WATCHDOG POLSKA                                                                      |   22876.20000 |  147946.96000 |  5.4672873991309745


-- ile zbieraja najwieskze organizacje

select
  row_number() over (partition by id_date order by amount desc) rn,
  name,
  amount,
  amount / (sum(amount) over (partition by id_date)) pct_year_total,
  sum(amount) over (partition by id_date order by amount desc rows between unbounded preceding and current row)
    / sum(amount) over (partition by id_date) cumul_amount_pct
from fund as f
join dim_opp as opp on (f.id_opp = opp.id_opp)
where f.id_date = 2015
order by amount desc
limit 30;

-- najwieksza (FUNDACJA DZIECIOM ''ZDĄŻYĆ Z POMOCĄ'') zbiera 23% wszystkich darowizn
-- 5 najwiekszych dostaje 1/3 wszykistkiego
-- 28 najwiekszych dostaje ponad polowe
-- w calym roku 2015 bylo 8108


-- udzial top -n we wszysktich darowiznach
select 'top10' top, id_date, sum(amount) top10_sum, sum(pct_sum_opp) top10_pct from (
select id_date, krs, name, amount, amount / sum_opp pct_sum_opp
from (
select id_date, krs, name, amount, sum(amount) over (partition by id_date) sum_opp, row_number() over (partition by id_date order by amount desc) rn
from fund f join dim_opp opp on (f.id_opp = opp.id_opp)
) t where rn <= 10
) tt group by id_date
order by id_date;

-- nastepuje powolny ale konsekentny wzrost najwiekszych organizacji. top 10 z roku na rok ma coraz wiekszy udzial:
top,id_date,top10_sum,top10_pct
top10,2010,141833286.76000,0.35436939055148898777
top10,2011,168168466.37000,0.36772939259445743823
top10,2012,180175477.64000,0.37533259663555564127
top10,2013,198260713.91000,0.38968715289978532628
top10,2014,218410650.40000,0.39172341504772507304
top10,2015,242586246.83000,0.39283847978529556365

select 'top1' top, id_date, sum(amount) top10_sum, sum(pct_sum_opp) top10_pct from (
select id_date, krs, name, amount, amount / sum_opp pct_sum_opp
from (
select id_date, krs, name, amount, sum(amount) over (partition by id_date) sum_opp, row_number() over (partition by id_date order by amount desc) rn
from fund f join dim_opp opp on (f.id_opp = opp.id_opp)
) t where rn <= 1
) tt group by id_date
order by id_date;

top,id_date,top10_sum,top10_pct
top1,2010,88805662.39000,0.22188027350671815567
top1,2011,108708265.91000,0.23770939615473799596
top1,2012,117182981.43000,0.24410976053854293636
top1,2013,127364965.33000,0.25033951376346865817
top1,2014,136189516.87000,0.24425833879580885900
top1,2015,144082857.97000,0.23332440164145251429

select 'top3' top, id_date, sum(amount) top10_sum, sum(pct_sum_opp) top10_pct from (
select id_date, krs, name, amount, amount / sum_opp pct_sum_opp
from (
select id_date, krs, name, amount, sum(amount) over (partition by id_date) sum_opp, row_number() over (partition by id_date order by amount desc) rn
from fund f join dim_opp opp on (f.id_opp = opp.id_opp)
) t where rn <= 3
) tt group by id_date
order by id_date;

top,id_date,top10_sum,top10_pct
top3,2010,106823523.19000,0.26689776197218508831
top3,2011,129596303.30000,0.28338469704625683010
top3,2012,141072310.44000,0.29387482294686817053
top3,2013,156604706.36000,0.30781106830795686369
top3,2014,172697772.43000,0.30973654930984291529
top3,2015,189991499.92000,0.30766777991748405376


select 'top20' top, id_date, sum(amount) top10_sum, sum(pct_sum_opp) top10_pct from (
select id_date, krs, name, amount, amount / sum_opp pct_sum_opp
from (
select id_date, krs, name, amount, sum(amount) over (partition by id_date) sum_opp, row_number() over (partition by id_date order by amount desc) rn
from fund f join dim_opp opp on (f.id_opp = opp.id_opp)
) t where rn <= 20
) tt group by id_date
order by id_date;

top,id_date,top10_sum,top10_pct
top20,2010,171155361.89000,0.42763037272914738156
top20,2011,201148595.81000,0.43984614092689799731
top20,2012,214494262.70000,0.44682378333125093681
top20,2013,233445507.17000,0.45884387911373945117
top20,2014,256262464.15000,0.45961132124985063031
top20,2015,283800000.16000,0.45957906551911608934

select 'top30' top, id_date, sum(amount) top10_sum, sum(pct_sum_opp) top10_pct from (
select id_date, krs, name, amount, amount / sum_opp pct_sum_opp
from (
select id_date, krs, name, amount, sum(amount) over (partition by id_date) sum_opp, row_number() over (partition by id_date order by amount desc) rn
from fund f join dim_opp opp on (f.id_opp = opp.id_opp)
) t where rn <= 30
) tt group by id_date
order by id_date;

top,id_date,top10_sum,top10_pct
top30,2010,190302568.04000,0.47546952198062469983
top30,2011,222154686.07000,0.48577958480512647736
top30,2012,238442142.33000,0.49671081548000405985
top30,2013,260835017.31000,0.51267875146581591504
top30,2014,286652063.50000,0.51411561221511450234
top30,2015,316641820.33000,0.51276233900454996724
