CALL gds.degree.stream('personStatusGraph')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS n, score
WHERE n:Peran
RETURN
n.peran AS status,
score AS degree
ORDER BY degree DESC;


CALL gds.degree.stream('personStatusGraph')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS n, score
WHERE n:Person
RETURN
n.person AS anonymized_person,
score AS degree
ORDER BY degree DESC;




//import
LOAD CSV WITH HEADERS
FROM 'https://drive.google.com/uc?export=download&id=ID_FILE'
AS row

WITH row
WHERE row.target IS NOT NULL
  AND row.url IS NOT NULL
  AND row.status IS NOT NULL
  AND row.peran IS NOT NULL

// ================= PERSON =================
MERGE (p:Person {id: trim(row.target)})

// ================= ARTICLE =================
MERGE (a:Article {url: trim(row.url)})

// ================= STATUS =================
MERGE (s:Status {name: toLower(trim(row.status))})

// ================= PERAN =================
MERGE (r:Peran {name: toLower(trim(row.peran))})

// ================= RELATIONSHIP =================
MERGE (p)-[:DISEBUT_DALAM]->(a)
MERGE (p)-[:MEMILIKI_STATUS]->(s)
MERGE (p)-[:MEMILIKI_PERAN]->(r)



//degree centrality
MATCH (p:Person)-[:DISEBUT_DALAM]->(a:Article)
RETURN
p.id AS person,
count(DISTINCT a.url) AS jumlah_artikel
ORDER BY jumlah_artikel DESC;



//centrality artikel
MATCH (p:Person)-[:DISEBUT_DALAM]->(a:Article)
RETURN
p.id AS person,
count(DISTINCT a.url) AS jumlah_artikel
ORDER BY jumlah_artikel DESC;



//centrality isu
MATCH (p:Person)-[:DISEBUT_DALAM]->(a:Article)
RETURN
a.url AS artikel,
collect(DISTINCT p.id) AS aktor,
count(DISTINCT p) AS jumlah_aktor
ORDER BY jumlah_aktor DESC;



//co-occurrence
MATCH (p1:Person)-[:DISEBUT_DALAM]->(a:Article),
      (p2:Person)-[:DISEBUT_DALAM]->(a)
WHERE p1 <> p2

WITH p1, p2, c, count(*) AS freq
RETURN
p1.id AS person_1,
p2.id AS person_2,
a.url AS artikel,
freq
ORDER BY freq DESC;



//analisis status
MATCH (p:Person)-[:MEMILIKI_STATUS]->(s:Status),
      (p)-[:DISEBUT_DALAM]->(a:Article)
RETURN
s.name AS status,
count(DISTINCT p) AS jumlah_orang
ORDER BY jumlah_orang DESC;



//status isu
MATCH (p:Person)-[:MEMILIKI_STATUS]->(s:Status),
      (p)-[:DISEBUT_DALAM]->(a:Article)-[:MEMBAHAS]->(c:CaseTopic)
RETURN
c.name AS kasus,
s.name AS status,
count(DISTINCT p) AS jumlah_orang
ORDER BY kasus, jumlah_orang DESC;



//status diduga
MATCH (p)-[:DISEBUT_DALAM]->(a:Article)
RETURN
p.id AS person,
a.url AS artikel;



//media domain
MATCH (p:Person)-[:DISEBUT_DALAM]->(a:Article)
WITH p, split(a.url,'/')[2] AS domain
RETURN
domain,
count(DISTINCT p) AS jumlah_tokoh
ORDER BY jumlah_tokoh DESC;



//visualisasi
MATCH (p:Person)-[:DISEBUT_DALAM]->(a:Article)-[:MEMBAHAS]->(c:CaseTopic)
RETURN p,a;

