Hostname "{{ HOST_NAME }}"

FQDNLookup false
Interval 10
Timeout 2
ReadThreads 5

LoadPlugin cpu
LoadPlugin df
LoadPlugin load
LoadPlugin memory
LoadPlugin write_graphite
LoadPlugin processes
LoadPlugin disk

<Plugin processes>
  Process java
</Plugin>

<Plugin df>
  Device "hostfs"
  MountPoint "/.dockerinit"
  IgnoreSelected false
  ReportByDevice false
  ReportReserved true
  ReportInodes true
</Plugin>

<Plugin "write_graphite">
 <Carbon>
   Host "{{ GRAPHITE_HOST }}"
   Port "{{ GRAPHITE_PORT | default("2003") }}"
   EscapeCharacter "_"
   SeparateInstances true
   StoreRates true
   AlwaysAppendDS false
 </Carbon>
</Plugin>

LoadPlugin aggregation

<Plugin "aggregation">
  <Aggregation>
    Plugin "cpu"
    Type "cpu"
    
    GroupBy "Host"
    GroupBy "TypeInstance"
    
    CalculateAverage true
  </Aggregation>
</Plugin>

LoadPlugin "match_regex" # we want to use this for our Matching
<Chain "PostCache">
  <Rule> # Send "cpu" values to the aggregation plugin.
    <Match regex>
      Plugin "^cpu$"
      PluginInstance "^[0-9]+$"
    </Match>
    <Target write>
      Plugin "aggregation"
    </Target>
    Target stop
  </Rule>
Target "write"
</Chain>

LoadPlugin python
<Plugin python>
  ModulePath "/usr/share/collectd"
  Import "testworkers"

</Plugin>
