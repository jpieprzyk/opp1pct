
opp2010 <- read.table("data/opp2010.csv", sep = "\t", header = F, encoding="UTF-8",stringsAsFactors = F)
opp2011 <- read.csv("data/opp2011.csv", sep = "\t", header = F, encoding="UTF-8")
opp2012 <- read.csv("data/opp2012.csv", sep = "\t", header = F, encoding="UTF-8")
opp2013 <- read.csv("data/opp2013.csv", sep = "\t", header = F, encoding="UTF-8")
opp2013u <- read.csv("data/opp2013uzup.csv", sep = "\t", header = F, encoding="UTF-8")
opp2014 <- read.csv("data/opp2014.csv", sep = "\t", header = F, encoding="UTF-8")
opp2015 <- read.csv("data/opp2015.csv", sep = "\t", header = F, encoding="UTF-8")

opp2010$rok <- "2010-01-01"
opp2011$rok <- "2011-01-01"
opp2012$rok <- "2012-01-01"
opp2013$rok <- "2013-01-01"
opp2013u$rok <- "2013-01-01"
opp2014$rok <- "2014-01-01"
opp2015$rok <- "2015-01-01"

opp <- rbind(opp2010, rbind(opp2011, rbind(opp2012, rbind(opp2013, rbind(opp2013u, rbind(opp2014, opp2015))))))

colnames(opp) <- c('krs','nazwa','wartosc','rok')

require(elastic)

connect(es_base = "localhost", es_port = "9200")

index_delete(index = "opp")

index_create(index = "opp")

opp$slowa <- opp$nazwa

mapping_create(index = "opp", type = "opp", body = '
               {
               "opp": {
               "properties": {
               "nazwa": { "type": "string", "index": "not_analyzed" }
               }
               }
               }')

docs_bulk(opp, index = "opp")


