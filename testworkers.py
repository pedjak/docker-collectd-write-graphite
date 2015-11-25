import collectd
from docker import Client

client = Client(base_url = 'unix://var/run/docker.sock', version='auto')

def configure_callback(conf):
  "register"

def count_testworkers():
  containers = client.containers()
  testworkers=0

  image = 'dse-testworker'
  for c in containers:
    if image in c['Image']:
      testworkers=testworkers+1
  return testworkers
  
def read_callback():
  val = collectd.Values()
  val.plugin = 'testworkers'
  val.type = 'current'
  val.values = [count_testworkers()]
  val.dispatch()

collectd.register_config(configure_callback)
collectd.register_read(read_callback)
