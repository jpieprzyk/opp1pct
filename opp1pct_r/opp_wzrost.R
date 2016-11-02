require(ggplot2)
require(dplyr)
Sys.setlocale(category = "LC_ALL", locale = "pl_PL.utf-8")

dat <- read.csv(textConnection("
id_date,cnt_opp,prev_cnt_opp,cnt_opp_diff_pct,sum_opp,pit_total,opp_pct_pit
2010,6533,,,400241359.84000,62487000000,0.00640519403779986237
2011,6859,6533,0.04990050512781264350,457315813.63000,67505115000,0.00677453573155160168
2012,7110,6859,0.03659425572240851436,480042179.27000,70621939000,0.00679735201365683262
2013,7423,7110,0.04402250351617440225,508768925.11000,73751310000,0.00689843916141964122
2014,7888,7423,0.06264313619830257308,557563428.71000,78127386000,0.00713659393020009654
2015,8108,7888,0.02789046653144016227,617521600.64000,83140145000,0.00742747803290456133
"), header =T)

head(dat)
require(reshape2)


p1 <- dat %>% 
  ggplot(aes(x = id_date, y = cnt_opp)) + 
  geom_line() +
  #geom_bar(stat = "identity", fill = "#4682b4") +
  scale_y_continuous("") +
  scale_x_continuous("", breaks = unique(dat$id_date)) +
  ggtitle('Darowizny z "1%" jako procent podtak\uf3w PIT\n') + 
  theme_light() + theme(legend.position = 'none')
  
p2 <- dat %>% 
  ggplot(aes(x = id_date, y = sum_opp)) + 
  geom_line() +
  #geom_bar(stat = "identity", fill = "#4682b4") +
  scale_y_continuous("") +
  scale_x_continuous("", breaks = unique(dat$id_date)) +
  ggtitle('Darowizny z "1%" jako procent podtak\uf3w PIT\n') + 
  theme_light() + theme(legend.position = 'none')

library(grid)
library(gridExtra)

grid.arrange(p1, p2, ncol = 1, main = "Wzrost darowizn na organizacje pożytku publicznego")
