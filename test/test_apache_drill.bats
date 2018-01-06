load test_helper

@test "query from drill shell client returns the correct version" {
  run docker run --net vnet --volumes-from drillbit-1 smizy/apache-drill:${TAG} sqlline -u jdbc:drill:zk=zookeeper-1.vnet --outputformat=csv -e 'SELECT version from sys.version'

  echo "${output}"

  [ $status -eq 0 ]
  [ "${lines[4]}" = "'${VERSION}'" ]
}

@test "query from drill shell client returns the correct result" {
  run docker run --net vnet --volumes-from drillbit-1 smizy/apache-drill:${TAG} sqlline -u jdbc:drill:zk=zookeeper-1.vnet --outputformat=csv -e 'SELECT employee_id, full_name, position_id, position_title FROM cp.`employee.json` LIMIT 5'
  
  echo "${output}"
  
  [ $status -eq 0 ]
  [ "${lines[4]}" = "'1','Sheri Nowmer','1','President'" ]
}

@test "query parquet format data returns the correct result" {
  run docker run --net vnet --volumes-from drillbit-1 smizy/apache-drill:${TAG} sqlline -u jdbc:drill:zk=zookeeper-1.vnet --outputformat=csv -e 'SELECT N_NATIONKEY, N_NAME, N_REGIONKEY FROM dfs.`/usr/local/apache-drill-'${VERSION}'/sample-data/nation.parquet` LIMIT 5'
  
  echo "${output}"
  
  [ $status -eq 0 ]
  [ "${lines[4]}" = "'0','ALGERIA','0'" ]
}
